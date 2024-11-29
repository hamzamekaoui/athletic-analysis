public without sharing class MatchWrapper {

    @AuraEnabled public Id id;
    @AuraEnabled public String homeTeam;
    @AuraEnabled public String homeCode;
    @AuraEnabled public String homeFlag;
    @AuraEnabled public String awayTeam;
    @AuraEnabled public String awayCode;
    @AuraEnabled public String awayFlag;
    @AuraEnabled public Integer homeScore;
    @AuraEnabled public Integer awayScore;
    @AuraEnabled public String stadium;
    @AuraEnabled public String round;
    @AuraEnabled public Datetime matchTime;

    public MatchWrapper(Match__c match) {
        this.id = match.Id;
        this.homeTeam = match.Home_Team__r.Team__r.Name;
        this.homeCode = match.Home_Team__r.Team__r.Code__c;
        this.homeFlag = match.Home_Team__r.Team__r.Flag__c;
        this.awayTeam = match.Away_Team__r.Team__r.Name;
        this.awayCode = match.Away_Team__r.Team__r.Code__c;
        this.awayFlag = match.Away_Team__r.Team__r.Flag__c;
        this.homeScore = (Integer) match.Home_Score__c;
        this.awayScore = (Integer) match.Away_Score__c;
        this.stadium = match.Stadium__r.Name;
        this.round = match.Round__c;
        this.matchTime = match.Match_Time__c;
    }

    public static List<MatchWrapper> buildMatchesList(List<Match__c> matches) {
        List<MatchWrapper> wrapper = new List<MatchWrapper>();
        for (Match__c match : matches) {
            wrapper.add(new MatchWrapper(match));
        }
        return wrapper;
    }
}