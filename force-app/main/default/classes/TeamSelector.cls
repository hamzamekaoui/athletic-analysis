public with sharing class TeamSelector {

    public static List<Team__c> getTeams() {
        return [SELECT Id, Name, Flag__c, Code__c FROM Team__c WITH SECURITY_ENFORCED];
    }
}