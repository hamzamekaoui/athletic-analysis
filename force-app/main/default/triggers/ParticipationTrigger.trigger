trigger ParticipationTrigger on Participation__c (before insert, before update) {
    new ParticipationTriggerHandler().run();
}