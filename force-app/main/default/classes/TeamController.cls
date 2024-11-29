public with sharing class TeamController {

    @AuraEnabled(Cacheable=true)
    public static List<Team__c> getTeams() {
        return TeamSelector.getTeams();
    }
}