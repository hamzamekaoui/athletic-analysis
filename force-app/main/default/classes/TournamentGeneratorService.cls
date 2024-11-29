public without sharing class TournamentGeneratorService {

    public static void generateRandomTournament(List<Team__c> teams) {
        Tournament__c tournament = TournamentDataFactory.generateTournament();
        Logger.debug('Generated tournament: ' + tournament.Name);

        List<Group__c> groups = TournamentDataFactory.generateGroups(tournament, 8);
        Logger.debug('Generated tournament groups');

        List<Stadium__c> stadiums = TournamentDataFactory.generateStadiums(8);
        Logger.debug('Generated stadiums');

        List<Participation__c> participations = setupParticipations(tournament, groups, teams);
        Logger.debug('Generated tournament participations');

        // Converting List to Map for easy access of elements
        Map<Id, Participation__c> participationsByIdsMap = new Map<Id, Participation__c>();
        for (Participation__c participation : participations) {
            participationsByIdsMap.put(participation.Id, participation);
        }

        // ALL tournament matches
        List<Match__c> matches = setupMatches(tournament, participations, stadiums);

        Logger.debug('Progressing the tournament throughout the rounds...');

        progressTournamentThroughTheGroupStage(tournament, matches, participationsByIdsMap);
        Logger.debug('Tournament is progressed to the: ROUND OF 16');

        for (String round : TournamentRounds.getKnockoutStageRoundNames()) {
            progressTournamentThroughTheKnockoutStage(tournament, matches, participationsByIdsMap);
            Logger.debug('Tournament is progressed to the: ' + round);
        }

        Logger.debug('Finished tournament generation...committing results');

        tournament.Is_Completed__c = true;

        update tournament;
        update matches;
        update participations;
    }

    private static Map<String, List<Id>> setupTeamsByGroupNameMap(List<Group__c> groups, List<Team__c> teams) {
        Map<String, List<Id>> teamsByGroup = new Map<String, List<Id>>();

        Integer maxTeamsPerGroup = teams.size() / groups.size();
        Integer currentTeamInGroupCount = 0;
        Integer currentGroupIndex = 0;

        for (Team__c team : teams) {
            if (currentTeamInGroupCount >= maxTeamsPerGroup) {
                currentGroupIndex++;
                currentTeamInGroupCount = 0;
            }

            String groupName = groups.get(currentGroupIndex).Name;
            if (!teamsByGroup.containsKey(groupName)) {
                teamsByGroup.put(groupName, new List<Id>());
            }
            teamsByGroup.get(groupName).add(team.Id);

            currentTeamInGroupCount++;
        }

        return teamsByGroup;
    }

    private static List<Participation__c> setupParticipations(Tournament__c tournament, List<Group__c> groups, List<Team__c> teams) {
        Map<String, List<Id>> teamsByGroup = setupTeamsByGroupNameMap(groups, teams);

        List<Participation__c> participations = TournamentService.setupTournament(tournament, groups, teamsByGroup);

        // Insert participations to get "real" Id
        insert participations;

        return participations;
    }


    private static List<Match__c> setupMatches(Tournament__c tournament, List<Participation__c> participations, List<Stadium__c> stadiums) {
        List<Match__c> matches = MatchService.scheduleTournamentMatches(tournament, participations, stadiums);

        // Insert matches to get "real" Id
        insert matches;

        return matches;
    }

    private static void progressTournamentThroughTheGroupStage(Tournament__c tournament, List<Match__c> matches, Map<Id, Participation__c> participationsByIdsMap) {
        tournament.Current_Round__c = TournamentRounds.toString(TournamentRounds.Round.ROUND_3);
        
        String nextRound = TournamentRounds.getNextRound(tournament.Current_Round__c);
        List<Match__c> nextRoundMatches = new List<Match__c>();

        List<Match__c> matchesToUpdate = new List<Match__c>();
        for (Match__c match : matches) {
            if (TournamentRounds.isGroupStage(match.Round__c)) {
                MatchService.generateScoresForMatch(false, match);
                matchesToUpdate.add(match);
            } else if (nextRound == match.Round__c) {
                nextRoundMatches.add(match);
            }
        }

        GroupService.updateStandings(participationsByIdsMap, matchesToUpdate);

        GroupService.updateParticipantsStatusGroupsResult(participationsByIdsMap.values());

        Boolean isFinal = TournamentRounds.isFinal(nextRound);

        MatchService.assignTeamsToMatchesForKnockoutRound(isFinal, nextRoundMatches, participationsByIdsMap.values());

        tournament.Current_Round__c = nextRound;
    }

    private static void progressTournamentThroughTheKnockoutStage(Tournament__c tournament, List<Match__c> matches, Map<Id, Participation__c> participationsByIdsMap) {
        String nextRound = TournamentRounds.getNextRound(tournament.Current_Round__c);
        List<Match__c> nextRoundMatches = new List<Match__c>();

        List<Participation__c> participationsToUpdate = new List<Participation__c>();
        List<Match__c> matchesToUpdate = new List<Match__c>();

        for (Match__c match : matches) {
            if (match.Round__c.equals(tournament.Current_Round__c)) {
                MatchService.generateScoresForMatch(true, match);
                participationsToUpdate.add(participationsByIdsMap.get(match.Home_Team__c));
                participationsToUpdate.add(participationsByIdsMap.get(match.Away_Team__c));
                matchesToUpdate.add(match);
            } else if (nextRound.equals(match.Round__c)) {
                nextRoundMatches.add(match);
            }
        }

        MatchService.updateKnockout(participationsByIdsMap, matchesToUpdate);

        Boolean isFinal = TournamentRounds.isFinal(nextRound);

        MatchService.assignTeamsToMatchesForKnockoutRound(isFinal, nextRoundMatches, participationsToUpdate);

        if (!TournamentRounds.isFinal(tournament.Current_Round__c)) {
            tournament.Current_Round__c = nextRound;
        }
    }
}