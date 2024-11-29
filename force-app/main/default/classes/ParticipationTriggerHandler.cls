public with sharing class ParticipationTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        GroupService.validateGroups(Trigger.new);
    }

    public override void beforeUpdate() {
        List<Participation__c> participationsToProcess = new List<Participation__c>();
        Map<Id, Participation__c> oldMap = (Map<Id, Participation__c>) Trigger.oldMap;
        List<Participation__c> newParticipations =  Trigger.new;
        for (Participation__c participation : newParticipations) {
            // Process only participations that change groups
            if (participation.Group__c != oldMap.get(participation.Id).Group__c) {
                participationsToProcess.add(participation);
            }
        }
        GroupService.validateGroups(participationsToProcess);
    }
}