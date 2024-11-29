public with sharing class StadiumSelector {

    public static List<Stadium__c> getStadiums() {
        return [SELECT Id, Name, Country__c FROM Stadium__c WITH SECURITY_ENFORCED];
    }
}