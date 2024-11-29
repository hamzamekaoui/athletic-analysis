@RestResource(UrlMapping='/tournaments/*/matches/')
global with sharing class MatchApi {

    @HttpGet
    global static MatchResponse doGet() {
        RestRequest request = RestContext.request;
        String[] uriParts = request.requestURI.split('/');
        String tournamentId = uriParts[uriParts.size() - 2];
        List<Match__c> matches = MatchSelector.getMatchesByTournament(tournamentId);
        return new MatchResponse(MatchWrapper.buildMatchesList(matches));
    }

    global class MatchResponse {
        public final List<MatchWrapper> matches;

        public MatchResponse(List<MatchWrapper> matches) {
            this.matches = matches;
        }
    }
}