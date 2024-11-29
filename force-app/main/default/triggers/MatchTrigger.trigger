trigger MatchTrigger on Match__c (after insert, after update, before insert, before update) {
    new MatchTriggerHandler().run();
}