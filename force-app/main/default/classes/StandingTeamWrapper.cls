public without sharing class StandingTeamWrapper {

    @AuraEnabled public String teamName;
    @AuraEnabled public String teamCode;
    @AuraEnabled public String teamFlag;
    @AuraEnabled public Integer matchesPlayed;
    @AuraEnabled public Integer wins;
    @AuraEnabled public Integer draws;
    @AuraEnabled public Integer losses;
    @AuraEnabled public Integer goalsFor;
    @AuraEnabled public Integer goalsAgainst;
    @AuraEnabled public Integer goalsDifference;
    @AuraEnabled public Integer points;

    public StandingTeamWrapper(Participation__c standing) {
        this.teamName = standing.Team__r.Name;
        this.teamCode = standing.Team__r.Code__c;
        this.teamFlag = standing.Team__r.Flag__c;
        this.matchesPlayed = (Integer) standing.Matches_Played__c;
        this.wins = (Integer) standing.Wins__c;
        this.draws = (Integer) standing.Draws__c;
        this.losses = (Integer) standing.Losses__c;
        this.goalsFor = (Integer) standing.Goals_For__c;
        this.goalsAgainst = (Integer) standing.Goals_Against__c;
        this.goalsDifference = (Integer) standing.Goal_Difference__c;
        this.points = (Integer) standing.Points__c;
    }

    public static Map<String, List<StandingTeamWrapper>> buildTeamsByGroups(List<Participation__c> standings) {
        standings.sort(new ParticipationCompare());
        Map<String, List<StandingTeamWrapper>> groups = new Map<String, List<StandingTeamWrapper>>();

        for (Participation__c standing : standings) {
            String groupName = standing.Group__r.Name;

            if (!groups.containsKey(standing.Group__r.Name)) {
                groups.put(groupName, new List<StandingTeamWrapper>());
            }

            groups.get(groupName).add(new StandingTeamWrapper(standing));
        }

        return groups;
    }
}