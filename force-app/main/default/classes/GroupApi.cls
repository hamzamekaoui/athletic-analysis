@RestResource(UrlMapping='/tournaments/*/groups/')
global with sharing class GroupApi {

    @HttpGet
    global static GroupResponse doGet() {
        RestRequest request = RestContext.request;
        String[] uriParts = request.requestURI.split('/');
        String tournamentId = uriParts[uriParts.size() - 2];
        Map<String, List<StandingTeamWrapper>> groups = StandingTeamWrapper.buildTeamsByGroups(ParticipationSelector.getTournamentStandings(tournamentId));
        return new GroupResponse(groups);
    }

    global class GroupResponse {
        public final Map<String, List<StandingTeamWrapper>> groups;

        public GroupResponse(Map<String, List<StandingTeamWrapper>> groups) {
            this.groups = groups;
        }
    }
}