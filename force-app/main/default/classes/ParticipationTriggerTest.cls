@IsTest
private class ParticipationTriggerTest {

    @IsTest
    static void testMaxTeamsAllowedPerGroup() {
        Tournament__c tournament = TournamentDataFactory.generateTournament();
        Group__c tournamentGroup = TournamentDataFactory.generateGroup(tournament);
        List<Team__c> teams = TournamentDataFactory.generateTeams(5);

        Test.startTest();

        List<Participation__c> participations = new List<Participation__c>();

        for (Integer i = 0; i < 4; i++) {
            participations.add(new Participation__c(Tournament__c = tournament.Id, Team__c = teams.get(i).Id, Group__c = tournamentGroup.Id));
        }

        // should pass because we insert 4 teams to the same group
        insert participations;

        Participation__c fifthTeam = new Participation__c(Team__c = teams.get(4).Id, Group__c = tournamentGroup.Id);

        try {
            insert fifthTeam;
        } catch (Exception e) {
            System.assert(e.getMessage().contains('group already contain 4 teams'));
        }

        Test.stopTest();
    }
}