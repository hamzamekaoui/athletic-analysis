@RestResource(UrlMapping='/tournaments/')
global with sharing class TournamentApi {

    @HttpGet
    global static TournamentResponse doGet() {
        return new TournamentResponse(TournamentWrapper.buildTournamentsList(TournamentSelector.getTournaments()));
    }

    global class TournamentResponse {
        global List<TournamentWrapper> tournaments;

        public TournamentResponse(List<TournamentWrapper> tournaments) {
            this.tournaments = tournaments;
        }
    }
}