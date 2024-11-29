public with sharing class TournamentController {

    @AuraEnabled(Cacheable=true)
    public static List<TournamentWrapper> getTournamentListForTeam(Id teamId) {
        Logger.info('Getting tournaments of team: ' + teamId);

        List<Participation__c> participations = ParticipationSelector.getTournamentsForParticipation(teamId);
        List<TournamentWrapper> tournaments = TournamentWrapper.buildTournamentsListFromParticipations(participations);

        Logger.saveLog();

        return tournaments;
    }

    // Setting 'Cacheable' to false because we're doing DML (otherwise DML LIMIT is set to 0)
    @AuraEnabled(Cacheable=false)
    public static Id createTournament(String tournamentTitle, Map<String, List<Id>> groupTeams, List<Stadium__c> stadiums) {
        Tournament__c tournament = TournamentService.createTournament(tournamentTitle, groupTeams, stadiums);
        return tournament.Id;
    }

    // Setting 'Cacheable' to false because we're doing DML (otherwise DML LIMIT is set to 0)
    @AuraEnabled(Cacheable=false)
    public static Boolean advanceTournament(Id tournamentId) {
        return TournamentService.advanceToNextRound(tournamentId);
    }

    // Setting 'Cacheable' to false because we're doing DML (otherwise DML LIMIT is set to 0)
    @AuraEnabled(Cacheable=false)
    public static Boolean generatePendingScores(Id tournamentId) {
        return TournamentService.generatePendingScoresForCurrentRound(tournamentId);
    }
}