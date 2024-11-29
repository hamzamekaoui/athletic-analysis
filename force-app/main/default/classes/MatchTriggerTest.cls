@IsTest
private class MatchTriggerTest {

    @IsTest
    static void testMaxMatchesAllowedPerTeam() {
        Tournament__c tournament = TournamentDataFactory.generateTournament();
        Group__c tournamentGroup = TournamentDataFactory.generateGroup(tournament);
        List<Team__c> teams = TournamentDataFactory.generateTeams(2);
        
        List<Participation__c> participations = new List<Participation__c> {
                new Participation__c(Tournament__c = tournament.Id, Team__c = teams.get(0).Id, Group__c = tournamentGroup.Id),
                new Participation__c(Tournament__c = tournament.Id, Team__c = teams.get(1).Id, Group__c = tournamentGroup.Id)
        };

        insert participations;

        Test.startTest();

        List<Match__c> matches = new List<Match__c>();

        for (Integer i = 0; i < 3; i++) {
            matches.add(
                    new Match__c(
                            Tournament__c = tournament.Id,
                            Home_Team__c = participations.get(0).Id,
                            Away_Team__c = participations.get(1).Id,
                            Match_Time__c = System.now(),
                            Round__c = '1',
                            Group__c = tournamentGroup.Id
                    )
            );
        }

        // should pass because we schedule 3 matches for the same team
        insert matches;

        Match__c forthMatch = new Match__c(
            Tournament__c = tournament.Id,
            Home_Team__c = participations.get(0).Id,
            Away_Team__c = participations.get(1).Id,
            Match_Time__c = System.now(),
            Round__c = '1',
            Group__c = tournamentGroup.Id
        );

        try {
            insert forthMatch;
        } catch (Exception e) {
            System.assert(e.getMessage().contains('teams are already scheduled for group stage matches'));
        }

        Test.stopTest();
    }

    @IsTest
    static void testThirdMatchesAreScheduledSameTime() {
        Tournament__c tournament = TournamentDataFactory.generateTournament();
        Group__c tournamentGroup = TournamentDataFactory.generateGroup(tournament);
        List<Team__c> teams = TournamentDataFactory.generateTeams(2);
        
        List<Participation__c> participations = new List<Participation__c> {
                new Participation__c(Tournament__c = tournament.Id, Team__c = teams.get(0).Id, Group__c = tournamentGroup.Id),
                new Participation__c(Tournament__c = tournament.Id, Team__c = teams.get(1).Id, Group__c = tournamentGroup.Id)
        };

        insert participations;

        Test.startTest();

        Datetime matchTime = System.now();

        Match__c firstMatchOfThirdRound = new Match__c(
            Tournament__c = tournament.Id,
            Home_Team__c = participations.get(0).Id,
            Away_Team__c = participations.get(1).Id,
            Match_Time__c = matchTime,
            Round__c = '3',
            Group__c = tournamentGroup.Id
        );

        
        insert firstMatchOfThirdRound;

        Match__c secondMatchOfThirdRound = new Match__c(
            Tournament__c = tournament.Id,
            Home_Team__c = participations.get(0).Id,
            Away_Team__c = participations.get(1).Id,
            Match_Time__c = matchTime.addDays(1),
            Round__c = '3',
            Group__c = tournamentGroup.Id
        );

        try {
            insert secondMatchOfThirdRound;
        } catch (Exception e) {
            System.assert(e.getMessage().contains('matches of the last round should for the group be scheduled at the same time'));
        }

        Test.stopTest();
    }
}