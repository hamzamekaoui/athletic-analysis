public with sharing class MatchService {

    public static void validateMatches(List<Match__c> matchesToSchedule) {
        Set<Id> teamIds = new Set<Id>();
        for (Match__c match : matchesToSchedule) {
            teamIds.add(match.Away_Team__c);
            teamIds.add(match.Home_Team__c);
        }
        List<Match__c> scheduledMatches = MatchSelector.getMatchesByTeams(teamIds);

        Map<Id, Integer> matchesPerTeam = new Map<Id, Integer>();
        Map<Id, Match__c> thirdRoundMatchesPerGroup = new Map<Id, Match__c>();

        for (Match__c match : scheduledMatches) {
            incrementMatchCountInMap(matchesPerTeam, match.Home_Team__c);
            incrementMatchCountInMap(matchesPerTeam, match.Away_Team__c);

            if (TournamentRounds.isThirdRound(match.Round__c)) {
                thirdRoundMatchesPerGroup.put(match.Group__c, match);
            }
        }

        for (Match__c match : matchesToSchedule) {
            Integer homeMatchesCount = matchesPerTeam.get(match.Home_Team__c);
            Integer awayMatchesCount = matchesPerTeam.get(match.Away_Team__c);

            if (homeMatchesCount >= 3 || awayMatchesCount >= 3) {
                Logger.warn('Teams to process are already scheduled for group stage matches');
                match.addError('Invalid: teams are already scheduled for group stage matches');
            } else {
                if (TournamentRounds.isThirdRound(match.Round__c)) {
                    Match__c existingThirdMatch = thirdRoundMatchesPerGroup.get(match.Group__c);
                    if (existingThirdMatch != null && existingThirdMatch.Match_Time__c != match.Match_Time__c) {
                        Logger.warn('Matches of the last round should for the group be scheduled at the same time');
                        match.addError('Invalid: matches of the last round should for the group be scheduled at the same time');
                    }
                }
            }
        }
        Logger.saveLog();
    }
    
    public static void handleCompletedMatches(List<Match__c> matches) {
        Set<Id> participations = new Set<Id>();
        List<Match__c> groupStageMatches = new List<Match__c>();
        List<Match__c> knockoutStageMatches = new List<Match__c>();

        for (Match__c match : matches) {
            if (match.Home_Score__c == null || match.Away_Score__c == null) {
                continue;
            }
            participations.add(match.Home_Team__c);
            participations.add(match.Away_Team__c);
            if (TournamentRounds.isGroupStage(match.Round__c)) {
                groupStageMatches.add(match);
            } else {
                knockoutStageMatches.add(match);
            }
        }

        Map<Id, Participation__c> participants = new Map<Id, Participation__c>(
                ParticipationSelector.getParticipantsByTournamentTeams(participations)
        );

        if (!groupStageMatches.isEmpty()) {
            Logger.debug('Group stage matches found, updating standings...');
            GroupService.updateStandings(participants, groupStageMatches);
        }

        if (!knockoutStageMatches.isEmpty()) {
            Logger.debug('Knockout stage matches found, updating eliminations...');
            updateKnockout(participants, knockoutStageMatches);
        }

        if (!participants.values().isEmpty()) {
            update participants.values();
        }

        Logger.saveLog();
    }

    public static List<Match__c> scheduleTournamentMatches(Tournament__c tournament, List<Participation__c> participations, List<Stadium__c> stadiums) {
        List<Match__c> matches = new List<Match__c>();

        Logger.info('Scheduling matches for tournament: ' + tournament.Id);

        ScheduleHelper scheduler = new ScheduleHelper(System.now());

        matches.addAll(generateGroupStageMatches(tournament, participations, scheduler, stadiums));
        Logger.debug('Scheduled group stage matches for tournament: ' + tournament.Id);

        matches.addAll(generateKnockoutStageMatches(tournament, 'Round of 16', 8, scheduler, stadiums));
        Logger.debug('Scheduled Round of 16 matches for tournament: ' + tournament.Id);

        matches.addAll(generateKnockoutStageMatches(tournament, 'Quarter Finals', 4, scheduler, stadiums));
        Logger.debug('Scheduled Quarter Finals matches for tournament: ' + tournament.Id);

        matches.addAll(generateKnockoutStageMatches(tournament, 'Semi Finals', 2, scheduler, stadiums));
        Logger.debug('Scheduled Semi Finals matches for tournament: ' + tournament.Id);

        matches.addAll(generateKnockoutStageMatches(tournament, 'Finals', 2, scheduler, stadiums));
        Logger.debug('Scheduled Finals matches for tournament: ' + tournament.Id);

        return matches;
    }

    public static List<Match__c> generateGroupStageMatches(Tournament__c tournament, List<Participation__c> participations, ScheduleHelper scheduler, List<Stadium__c> stadiums) {
        List<Match__c> matches = new List<Match__c>();
        List<List<Integer>> combinations = new List<List<Integer>> {
                new List<Integer> {0, 1, 2, 3},
                new List<Integer> {0, 2, 1, 3},
                new List<Integer> {0, 3, 1, 2}
        };

        Map<Id ,List<Id>> groups = new Map<Id, List<Id>>();

        for (Participation__c participation: participations) {
            if (!groups.containsKey(participation.Group__c)) {
                groups.put(participation.Group__c, new List<Id>());
            }
            groups.get(participation.Group__c).add(participation.Id);
        }

        List<String> rounds = TournamentRounds.getGroupStageRoundNames();

        for (Id groupId : groups.keySet()) {
            List<Id> teams = groups.get(groupId);
            for (Integer i = 0; i < combinations.size(); i++) {
                Datetime matchTime = scheduler.getNextSchedule();
                for (Integer j = 0; j < combinations[i].size(); j += 2) {
                    Integer homeTeamPosition = combinations[i][j];
                    Integer awayTeamPosition = combinations[i][j + 1];
                    matches.add(
                            new Match__c(
                                    Home_Team__c = teams.get(homeTeamPosition),
                                    Away_Team__c = teams.get(awayTeamPosition),
                                    Group__c = groupId,
                                    Round__c = rounds.get(i),
                                    Tournament__c = tournament.Id,
                                    Match_Time__c = matchTime,
                                    Stadium__c = getRandomStadium(stadiums).Id
                            )
                    );
                }
            }
        }
        return matches;
    }

    public static List<Match__c> generateKnockoutStageMatches(Tournament__c tournament, String roundName, Integer matchCount, ScheduleHelper scheduler, List<Stadium__c> stadiums) {
        List<Match__c> matches = new List<Match__c>();
        for (Integer i = 0; i < matchCount; i++) {
            matches.add(new Match__c(
                    Tournament__c = tournament.Id,
                    Round__c = roundName,
                    Match_Time__c = scheduler.getNextSchedule(),
                    Stadium__c = getRandomStadium(stadiums).Id
            ));
        }

        return matches;
    }

    public static void updateKnockout(Map<Id, Participation__c> participants, List<Match__c> matches) {
        for (Match__c match : matches) {
            Participation__c homeTeam = participants.get(match.Home_Team__c);
            Participation__c awayTeam = participants.get(match.Away_Team__c);
            if (match.Home_Score__c > match.Away_Score__c) {
                awayTeam.Is_Eliminated__c = true;
            } else {
                homeTeam.Is_Eliminated__c = true;
            }
        }
    }

    public static void updateMatchesForKnockoutRound(Boolean isFinalRoundNext, List<Match__c> matches, List<Participation__c> participations) {
        assignTeamsToMatchesForKnockoutRound(isFinalRoundNext, matches, participations);
        update matches;
    }

    public static List<Match__c> assignTeamsToMatchesForKnockoutRound(Boolean isFinalRoundNext, List<Match__c> matches, List<Participation__c> participations) {
        List<Participation__c> winners = new List<Participation__c>();
        List<Participation__c> losers = new List<Participation__c>();

        List<Participation__c> participationsToConsider = new List<Participation__c>();

        for (Participation__c participation : participations) {
            if (participation.Is_Eliminated__c == false) {
                winners.add(participation);
            } else {
                losers.add(participation);
            }
        }

        if (isFinalRoundNext) {
            participationsToConsider.addAll(losers);
        }

        participationsToConsider.addAll(winners);

        for (Integer i = 0; i < matches.size(); i++) {
            matches.get(i).Home_Team__c = participationsToConsider.get(i * 2).Id;
            matches.get(i).Away_Team__c = participationsToConsider.get((i * 2)+ 1).Id;
        }

        return matches;
    }

    public static List<Match__c> randomizeMatchesScores(Boolean enforceWinner, List<Match__c> matches) {
        for (Match__c match : matches) {
            generateScoresForMatch(enforceWinner, match);
        }
        return matches;
    }

    public static void generateScoresForMatch(Boolean enforceWinner, Match__c match) {
        Integer homeScore = generateScore();
        Integer awayScore = generateScore();

        // Enforce a winner, in Knockout stage we can't have teams end on a draw
        if (enforceWinner) {
            while (homeScore == awayScore) {
                homeScore = generateScore();
                awayScore = generateScore();
            }
        }

        match.Home_Score__c = homeScore;
        match.Away_Score__c = awayScore;
    }

    private static Integer generateScore() {
        return Math.round(Math.random() * 10);
    }

    private static Stadium__c getRandomStadium(List<Stadium__c> stadiums) {
        Integer position = Integer.valueOf(Math.random() * stadiums.size());
        return stadiums.get(position);
    }

    private static void incrementMatchCountInMap(Map<Id, Integer> matchesPerTeam, Id teamId) {
        if (!matchesPerTeam.containsKey(teamId)) {
            matchesPerTeam.put(teamId, 0);
        }
        matchesPerTeam.put(teamId, matchesPerTeam.get(teamId) + 1);
    }
}