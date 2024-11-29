public with sharing class MatchController {

    @AuraEnabled(Cacheable=true)
    public static List<MatchWrapper> getRecentMatchesByTeam(Id tournamentId, Id teamId) {
        Logger.info('Getting recent matches for team: ' + teamId + ', part of tournament: ' + tournamentId);
        Id participationId = ParticipationSelector.getParticipationByTournamentAndTeam(tournamentId, teamId).Id;
        List<Match__c> matches = MatchSelector.getRecentMatchesByTeam(tournamentId, participationId);
        Logger.saveLog();
        return MatchWrapper.buildMatchesList(matches);
    }

    @AuraEnabled(Cacheable=true)
    public static List<MatchWrapper> getUpcomingMatchesByTeam(Id tournamentId, Id teamId) {
        Logger.info('Getting upcoming matches for team: ' + teamId + ', part of tournament: ' + tournamentId);
        Id participationId = ParticipationSelector.getParticipationByTournamentAndTeam(tournamentId, teamId).Id;
        List<Match__c> matches = MatchSelector.getUpcomingMatchesByTeam(tournamentId, participationId);
        Logger.saveLog();
        return MatchWrapper.buildMatchesList(matches);
    }

    @AuraEnabled(Cacheable=true)
    public static List<MatchWrapper> getKnockoutStageMatches(Id tournamentId, Id teamId) {
        List<String> knockoutRounds = TournamentRounds.getKnockoutStageRoundNames();

        List<Match__c> matches = new List<Match__c>();

        if (teamId != null) {
            Participation__c participation = ParticipationSelector.getParticipationByTournamentAndTeam(tournamentId, teamId);
            Logger.info('Getting knockout matches for team: ' + participation.Id + ', part of tournament: ' + participation.Tournament__c);
            matches = MatchSelector.getMatchesByRoundsAndTeam(participation.Tournament__c, participation.Id, knockoutRounds);
        } else {
            Logger.info('Getting knockout matches for tournament: ' + tournamentId);
            matches = MatchSelector.getMatchesByTournamentAndRounds(tournamentId, knockoutRounds);
        }

        Logger.saveLog();
        return MatchWrapper.buildMatchesList(matches);
    }
}