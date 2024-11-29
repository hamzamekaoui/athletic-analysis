public with sharing class TournamentService {

    public static Tournament__c createTournament(String tournamentTitle, Map<String, List<Id>> groupTeams, List<Stadium__c> stadiums) {
        Tournament__c tournament = new Tournament__c(Name = tournamentTitle, Current_Round__c = '1');

        // Insert tournament to get "real" Id
        insert tournament;

        Logger.info('Persisted tournament: ' + tournament.Id);

        List<Group__c> groups = new List<Group__c>();

        for (String groupName : groupTeams.keySet()) {
            groups.add(new Group__c(
                    Name = groupName,
                    Tournament__c = tournament.Id
            ));
        }

        // Insert groups to get "real" Id
        insert groups;

        Logger.info('Persisted groups for tournament: ' + tournament.Id);

        List<Participation__c> participations = setupTournament(tournament, groups, groupTeams);

        // Insert participations to get "real" Id
        insert participations;

        List<Match__c> matches = MatchService.scheduleTournamentMatches(tournament, participations, stadiums);

        insert matches;

        Logger.saveLog();

        return tournament;
    }

    public static List<Participation__c> setupTournament(Tournament__c tournament, List<Group__c> groups, Map<String, List<Id>> groupTeams) {
        List<Participation__c> participations = new List<Participation__c>();

        // Map to store group Ids by group name since from the request we identify teams by group names and not Ids
        Map<String, Id> groupNamesToIds = new Map<String, Id>();
        for (Group__c groupRecord : groups) {
            groupNamesToIds.put(groupRecord.Name, groupRecord.Id);
        }

        for (String groupName : groupTeams.keySet()) {
            Id groupId = groupNamesToIds.get(groupName);
            List<Id> teams = groupTeams.get(groupName);

            for (Id team : teams) {
                participations.add(new Participation__c(
                        Tournament__c = tournament.Id,
                        Group__c = groupId,
                        Team__c = team,
                        Draws__c = 0,
                        Wins__c = 0,
                        Losses__c = 0,
                        Goals_For__c = 0,
                        Goals_Against__c = 0,
                        Matches_Played__c = 0
                ));
            }
        }

        Logger.debug('Completed setup of participations for tournament: ' + tournament.Id);

        return participations;
    }

    public static Boolean generatePendingScoresForCurrentRound(Id tournamentId) {
        Logger.info('Generating score for pending matches for tournament : ' + tournamentId);
        Tournament__c tournament = TournamentSelector.getTournamentById(tournamentId);
        List<Match__c> matches = MatchSelector.getUnsettledMatchesByTournamentAndRound(tournament.Id, tournament.Current_Round__c);
        Boolean enforceWinner = TournamentRounds.isKnockoutStage(tournament.Current_Round__c);

        MatchService.randomizeMatchesScores(enforceWinner, matches);

        if (!matches.isEmpty()) {
            if (TournamentRounds.isFinal(tournament.Current_Round__c)) {
                Logger.info('Setting tournament: ' + tournamentId + ' to completed, no matches left to update');
                tournament.Is_Completed__c = true;
            }
            update matches;
            update tournament;
        }

        Logger.saveLog();

        return matches.isEmpty();
    }

    public static Boolean advanceToNextRound(Id tournamentId) {
        Logger.info('Advancing to the next round for tournament : ' + tournamentId);
        Tournament__c tournament = TournamentSelector.getTournamentById(tournamentId);

        // Tournament is completed, returning false to notify that no changes has been done
        if (tournament.Is_Completed__c) {
            Logger.info('Tournament is already completed : ' + tournamentId);
            return false;
        }

        String nextRound = TournamentRounds.getNextRound(tournament.Current_Round__c);

        Boolean isFinalRoundNext = TournamentRounds.isFinal(nextRound);

        List<Match__c> matches = MatchSelector.getMatchesByTournamentAndRounds(tournament.Id, new Set<String> {tournament.Current_Round__c, nextRound});

        List<Match__c> matchesForNextRound = new List<Match__c>();

        Set<Id> participantsIds = new Set<Id>();
        for (Match__c match : matches) {
            if (match.Round__c == nextRound) {
                matchesForNextRound.add(match);
            } else {
                if (match.Home_Score__c == null || match.Away_Score__c == null) {
                    Logger.error('Cannot progress tournament: ' + tournamentId + ' with unsettled matches');
                    throw new AuraHandledException('Cannot progress to next round, please settle the scores for the matches first');
                }
                participantsIds.add(match.Home_Team__c);
                participantsIds.add(match.Away_Team__c);
            }
        }

        List<Participation__c> participations = ParticipationSelector.getParticipantsByTournamentTeams(participantsIds);

        if (TournamentRounds.isGroupStage(tournament.Current_Round__c) && TournamentRounds.isKnockoutStage(nextRound)) {
            GroupService.updateParticipantsStatusGroupsResult(participations);
            MatchService.updateMatchesForKnockoutRound(isFinalRoundNext, matchesForNextRound, participations);
        }

        if (TournamentRounds.isKnockoutStage(tournament.Current_Round__c)) {
            MatchService.updateMatchesForKnockoutRound(isFinalRoundNext, matchesForNextRound, participations);
        }

        update participations;

        tournament.Current_Round__c = nextRound;

        update tournament;

        Logger.info('Advanced tournament: ' + tournamentId + 'to :' + nextRound);
        Logger.saveLog();

        return true;
    }
}