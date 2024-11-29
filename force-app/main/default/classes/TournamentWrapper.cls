public without sharing class TournamentWrapper {

    @AuraEnabled public Id id;
    @AuraEnabled public String name;
    @AuraEnabled public String currentRound;
    @AuraEnabled public Boolean isCompleted;

    public TournamentWrapper(Tournament__c tournament) {
        this.id = tournament.Id;
        this.name = tournament.Name;
        this.currentRound = tournament.Current_Round__c;
        this.isCompleted = tournament.Is_Completed__c;
    }

    public TournamentWrapper(Participation__c participation) {
        this.id = participation.Tournament__r.Id;
        this.name = participation.Tournament__r.Name;
        this.currentRound = participation.Tournament__r.Current_Round__c;
        this.isCompleted = participation.Tournament__r.Is_Completed__c;
    }

    public static List<TournamentWrapper> buildTournamentsList(List<Tournament__c> tournaments) {
        List<TournamentWrapper> wrapper = new List<TournamentWrapper>();
        for (Tournament__c tournament : tournaments) {
            wrapper.add(new TournamentWrapper(tournament));
        }
        return wrapper;
    }

    public static List<TournamentWrapper> buildTournamentsListFromParticipations(List<Participation__c> tournaments) {
        List<TournamentWrapper> wrapper = new List<TournamentWrapper>();
        for (Participation__c tournament : tournaments) {
            wrapper.add(new TournamentWrapper(tournament));
        }
        return wrapper;
    }
}