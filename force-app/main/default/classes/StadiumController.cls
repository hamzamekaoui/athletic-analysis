public with sharing class StadiumController {
    
    @AuraEnabled(Cacheable=true)
    public static List<Stadium__c> getStadiums() {
        return StadiumSelector.getStadiums();
    }
}