public without sharing class TournamentDataFactory {
    
    public static Tournament__c generateTournament() {
        Tournament__c tournament = new Tournament__c(Name = 'Tournament ' + System.now().toString());

        // Insert tournament to get "real" Id
        insert tournament;

        return tournament;
    }

    public static List<Team__c> generateTeams(Integer count) {
        List<Team__c> teams = new List<Team__c>();

        for (Integer i = 1; i <= count; i++) {
            String teamName = 'Team ' + i;
            teams.add(new Team__c(Name = teamName, Flag__c = 'https://flagcdn.com/un.svg', Code__c = i.toString()));
        }

        // Insert teams to get "real" Id
        insert teams;

        return teams;
    }

    public static List<Stadium__c> generateStadiums(Integer count) {
        List<Stadium__c> stadiums = new List<Stadium__c>();

        for (Integer i = 1; i <= count; i++) {
            String stadiumName = 'Stadium ' + i;
            stadiums.add(new Stadium__c(Name=stadiumName, Country__c='Country'));
        }

        // Insert stadiums to get "real" Id
        insert stadiums;

        return stadiums;
    }

    public static Group__c generateGroup(Tournament__c tournament) {
        Group__c tournamentGroup = new Group__c(Name = 'Group', Tournament__c = tournament.Id);

        // Insert group to get "real" Id
        insert tournamentGroup;

        return tournamentGroup;
    }

    public static List<Group__c> generateGroups(Tournament__c tournament, Integer count) {
        List<Group__c> groups = new List<Group__c>();

        for (Integer i = 1; i <= count; i++) {
            String groupName = 'Group ' + i;
            groups.add(new Group__c(Name = groupName, Tournament__c = tournament.Id));
        }

        // Insert groups to get "real" Id
        insert groups;

        return groups;
    }
}