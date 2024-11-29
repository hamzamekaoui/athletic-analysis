public with sharing class TournamentSelector {

    public static Tournament__c getTournamentById(Id tournamentId) {
        return [SELECT Id, Name, Is_Completed__c, Current_Round__c FROM Tournament__c WHERE Id = :tournamentId WITH SECURITY_ENFORCED LIMIT 1];
    }

    public static List<Tournament__c> getTournaments() {
        return [SELECT Id, Name, Is_Completed__c, Current_Round__c FROM Tournament__c WITH SECURITY_ENFORCED];
    }
}