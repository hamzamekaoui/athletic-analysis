public with sharing class MatchSelector {

    private static final Set<String> DISPLAY_FIELDS = new Set<String> {
            'Home_Team__r.Team__r.Name',
            'Home_Team__r.Team__r.Code__c',
            'Home_Team__r.Team__r.Flag__c',
            'Home_Score__c',
            'Away_Team__r.Team__r.Name',
            'Away_Team__r.Team__r.Code__c',
            'Away_Team__r.Team__r.Flag__c',
            'Away_Score__c',
            'Match_Time__c',
            'Round__c',
            'Stadium__r.Name'
    };

    public static List<Match__c> getMatchesByTeams(Set<Id> teamIds) {
        return [
                SELECT
                        Home_Team__c,
                        Away_Team__c,
                        Group__c,
                        Round__c,
                        Match_Time__c
                FROM Match__c
                WHERE (Home_Team__c IN :teamIds OR Away_Team__c IN :teamIds)
                AND Group__c != NULL
                WITH SECURITY_ENFORCED
        ];
    }

    public static List<Match__c> getUnsettledMatchesByTournamentAndRound(Id tournamentId, String round) {
        return [
                SELECT
                        Id,
                        Home_Team__c,
                        Home_Score__c,
                        Away_Team__c,
                        Away_Score__c
                FROM Match__c
                WHERE Round__c = :round
                AND Tournament__c = :tournamentId
                AND (Home_Score__c = NULL AND Away_Score__c = NULL)
                WITH SECURITY_ENFORCED
        ];
    }

    public static List<Match__c> getMatchesByTournamentAndRounds(Id tournamentId, Set<String> rounds) {
        return [
                SELECT
                        Home_Team__c,
                        Home_Score__c,
                        Away_Team__c,
                        Away_Score__c,
                        Round__c
                FROM Match__c
                WHERE Tournament__c = :tournamentId AND Round__c = : rounds
                WITH SECURITY_ENFORCED
        ];
    }

    public static List<Match__c> getUpcomingMatchesByTeam(Id tournamentId, Id teamId) {
        return Database.query('SELECT ' + String.join(DISPLAY_FIELDS, ',') +
                ' FROM Match__c' +
                ' WHERE Tournament__c = :tournamentId' +
                ' AND (Home_Team__c = :teamId OR Away_Team__c = :teamId)' +
                ' AND (Home_Score__c = NULL AND Away_Score__c = NULL)' +
                ' WITH SECURITY_ENFORCED' +
                ' ORDER BY Match_Time__c ASC' +
                ' LIMIT 3'
        );
    }

    public static List<Match__c> getRecentMatchesByTeam(Id tournamentId, Id teamId) {
        return Database.query('SELECT ' + String.join(DISPLAY_FIELDS, ',') +
                ' FROM Match__c' +
                ' WHERE Tournament__c = :tournamentId' +
                ' AND (Home_Team__c = :teamId OR Away_Team__c = :teamId)' +
                ' AND (Home_Score__c <> NULL AND Away_Score__c <> NULL)' +
                ' WITH SECURITY_ENFORCED' +
                ' ORDER BY Match_Time__c DESC' +
                ' LIMIT 3'
        );
    }

    public static List<Match__c> getMatchesByRoundsAndTeam(Id tournamentId, Id participationId, List<String> rounds) {
        return Database.query('SELECT ' + String.join(DISPLAY_FIELDS, ',') +
                ' FROM Match__c' +
                ' WHERE Tournament__c = :tournamentId' +
                ' AND Round__c IN :rounds' +
                ' AND (Home_Team__c = :participationId OR Away_Team__c = :participationId)' +
                ' WITH SECURITY_ENFORCED' +
                ' ORDER BY Match_Time__c ASC'
        );
    }

    public static List<Match__c> getMatchesByTournamentAndRounds(Id tournamentId, List<String> round) {
        return Database.query('SELECT ' + String.join(DISPLAY_FIELDS, ',') +
                ' FROM Match__c' +
                ' WHERE Tournament__c = :tournamentId' +
                ' AND Round__c IN :round' +
                ' WITH SECURITY_ENFORCED' +
                ' ORDER BY Match_Time__c ASC'
        );
    }

    public static List<Match__c> getMatchesByTournament(Id tournamentId) {
        return Database.query('SELECT ' + String.join(DISPLAY_FIELDS, ',') +
                ' FROM Match__c' +
                ' WHERE Tournament__c = :tournamentId' +
                ' WITH SECURITY_ENFORCED'
        );
    }
}