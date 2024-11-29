public without sharing class TournamentGeneratorBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext context) {
        Logger.debug('Starting : TournamentGeneratorBatch');

        List<Team__c> teams = TournamentDataFactory.generateTeams(32);
        Logger.debug('Generated teams: ' + teams.size());

        return Database.getQueryLocator('SELECT Id FROM Team__c WITH SECURITY_ENFORCED ORDER BY Id DESC LIMIT 32');
    }

    public void execute(Database.BatchableContext context, List<Team__c> teams) {
        Logger.debug('Executing : TournamentGeneratorBatch');
        TournamentGeneratorService.generateRandomTournament(teams);
    }

    public void finish(Database.BatchableContext context) {
        Logger.debug('Finished : TournamentGeneratorBatch');
        Logger.saveLog();
    }
}