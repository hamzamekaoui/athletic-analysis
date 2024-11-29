public with sharing class ParticipationSelector {

    public static List<Participation__c> getTournamentsForParticipation(Id teamId) {
        return [
                SELECT
                        Tournament__r.Id,
                        Tournament__r.Name,
                        Tournament__r.Current_Round__c,
                        Tournament__r.Is_Completed__c
                FROM Participation__c
                WHERE Team__c = :teamId
                WITH SECURITY_ENFORCED
        ];
    }

    public static List<Participation__c> getTournamentStandings(Id tournamentId) {
        return [
                SELECT
                        Id,
                        Team__r.Name,
                        Team__r.Code__c,
                        Team__r.Flag__c,
                        Group__r.Name,
                        Matches_Played__c,
                        Wins__c,
                        Draws__c,
                        Losses__c,
                        Goals_For__c,
                        Goals_Against__c,
                        Goal_Difference__c,
                        Points__c
                FROM Participation__c
                WHERE Tournament__c = :tournamentId
                WITH SECURITY_ENFORCED
                ORDER BY Points__c DESC
        ];
    }

    public static Participation__c getParticipationByTournamentAndTeam(Id tournamentId, Id teamId) {
        return [
                SELECT
                        Id,
                        Tournament__c,
                        Group__c
                FROM Participation__c
                WHERE Team__c = :teamId
                AND Tournament__c = :tournamentId
                WITH SECURITY_ENFORCED
                LIMIT 1
        ];
    }

    public static List<Participation__c> getParticipantsByTournamentTeams(Set<Id> participations) {
        return [
                SELECT
                        Id,
                        Matches_Played__c,
                        Wins__c,
                        Losses__c,
                        Draws__c,
                        Goals_For__c,
                        Goals_Against__c,
                        Points__c,
                        Group__c,
                        Is_Eliminated__c
                FROM Participation__c
                WHERE Id IN :participations
                WITH SECURITY_ENFORCED
        ];
    }

    public static List<Participation__c> getParticipantsByGroups(Set<Id> groups) {
        return [
                SELECT
                        Id,
                        Team__c,
                        Group__c
                FROM Participation__c
                WHERE Group__c IN :groups
                WITH SECURITY_ENFORCED
        ];
    }

    public static List<Participation__c> getTournamentTeamStanding(Id tournamentId, Id groupId) {
        return [
                SELECT
                        Id,
                        Team__r.Name,
                        Team__r.Code__c,
                        Team__r.Flag__c,
                        Group__r.Name,
                        Matches_Played__c,
                        Wins__c,
                        Draws__c,
                        Losses__c,
                        Goals_For__c,
                        Goals_Against__c,
                        Goal_Difference__c,
                        Points__c
                FROM Participation__c
                WHERE Tournament__c = :tournamentId
                AND Group__c =: groupId
                WITH SECURITY_ENFORCED
                ORDER BY Points__c DESC
        ];
    }
}