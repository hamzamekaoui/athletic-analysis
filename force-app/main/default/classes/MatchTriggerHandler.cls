public with sharing class MatchTriggerHandler extends TriggerHandler {

    public override void afterInsert() {
        MatchService.handleCompletedMatches(Trigger.new);
    }

    public override void afterUpdate() {
        List<Match__c> matchesToProcess = new List<Match__c>();
        Map<Id, Match__c> newMap = (Map<Id, Match__c>) Trigger.newMap;
        List<Match__c> old =  Trigger.old;
        for (Match__c match : old) {
            if (match.Away_Score__c == null && match.Home_Score__c == null) {
                matchesToProcess.add(newMap.get(match.Id));
            }
        }
        MatchService.handleCompletedMatches(matchesToProcess);
    }

    public override void beforeInsert() {
        MatchService.validateMatches(Trigger.new);
    }

    public override void beforeUpdate() {
        List<Match__c> matchesToProcess = new List<Match__c>();
        Map<Id, Match__c> oldMap = (Map<Id, Match__c>) Trigger.oldMap;
        List<Match__c> newMatches =  Trigger.new;
        for (Match__c match : newMatches) {
            // Only process matches that change groups
            if (match.Group__c != oldMap.get(match.Id).Group__c) {
                matchesToProcess.add(match);
            }
        }
        MatchService.validateMatches(matchesToProcess);
    }
}