public with sharing class GroupController {

    @AuraEnabled(Cacheable=true)
    public static List<String> getGroupNames() {
        return new List<String> {'Group A', 'Group B', 'Group C', 'Group D', 'Group E', 'Group F', 'Group G', 'Group H'};
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, List<StandingTeamWrapper>> getStandings(Id tournamentId) {
        Logger.info('Getting standing for tournament: ' + tournamentId);
        List<Participation__c> participations = ParticipationSelector.getTournamentStandings(tournamentId);
        Logger.saveLog();
        return StandingTeamWrapper.buildTeamsByGroups(participations);
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, List<StandingTeamWrapper>> getStandingByTeam(Id tournamentId, Id teamId) {
        Logger.info('Getting standing for team: ' + teamId + ', part of tournament: ' + tournamentId);
        Participation__c currentTeam = ParticipationSelector.getParticipationByTournamentAndTeam(tournamentId, teamId);
        Logger.info('Getting standing for tournament: ' + currentTeam.Tournament__c + ' for group: ' + currentTeam.Group__c);
        List<Participation__c> participations = ParticipationSelector.getTournamentTeamStanding(currentTeam.Tournament__c, currentTeam.Group__c);
        Logger.saveLog();
        return StandingTeamWrapper.buildTeamsByGroups(participations);
    }
}