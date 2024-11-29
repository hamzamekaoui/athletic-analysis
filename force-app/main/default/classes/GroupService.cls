public with sharing class GroupService {

    public static void updateStandings(Map<Id, Participation__c> participants, List<Match__c> matches) {
        Logger.info('Updating standing for matches...');
        for (Match__c match : matches) {
            Participation__c homeTeam = participants.get(match.Home_Team__c);
            Participation__c awayTeam = participants.get(match.Away_Team__c);
            if (match.Home_Score__c > match.Away_Score__c) {
                homeTeam.Wins__c++;
                awayTeam.Losses__c++;
            } else if (match.Home_Score__c < match.Away_Score__c) {
                awayTeam.Wins__c++;
                homeTeam.Losses__c++;
            } else {
                homeTeam.Draws__c++;
                awayTeam.Draws__c++;
            }
            homeTeam.Matches_Played__c++;
            homeTeam.Goals_For__c+= match.Home_Score__c;
            homeTeam.Goals_Against__c+= match.Away_Score__c;

            awayTeam.Matches_Played__c++;
            awayTeam.Goals_For__c+= match.Away_Score__c;
            awayTeam.Goals_Against__c+= match.Home_Score__c;
        }
    }
    
    public static void updateParticipantsStatusGroupsResult(List<Participation__c> participations) {
        Map<String, List<Participation__c>> participationsByGroups = new Map<String, List<Participation__c>>();

        for (Participation__c record : participations) {
            if (!participationsByGroups.containsKey(record.Group__c)) {
                participationsByGroups.put(record.Group__c, new List<SObject>());
            }
            participationsByGroups.get(record.Group__c).add(record);
        }

        for (String groupId : participationsByGroups.keySet()) {
            List<Participation__c> participationsToUpdate = participationsByGroups.get(groupId);

            // participants are sorted in an DESC order, third and forth in order are eliminated
            participationsToUpdate.sort(new ParticipationCompare());

            participationsToUpdate.get(2).Is_Eliminated__c = true;
            participationsToUpdate.get(3).Is_Eliminated__c = true;
        }

        Logger.info('Updated teams eliminated for groups stage');
    }

    public static void validateGroups(List<Participation__c> newParticipations) {
        Set<Id> groupIds = new Set<Id>();

        for (Participation__c participation : newParticipations) {
            groupIds.add(participation.Group__c);
        }

        Map<Id, Integer> teamsCountByTeam = new Map<Id, Integer>();

        for (Participation__c participation : ParticipationSelector.getParticipantsByGroups(groupIds)) {
            if (!teamsCountByTeam.containsKey(participation.Group__c)) {
                teamsCountByTeam.put(participation.Group__c, 0);
            }
            teamsCountByTeam.put(participation.Group__c, teamsCountByTeam.get(participation.Group__c) + 1);
        }

        for (Participation__c participation : newParticipations) {
            if (teamsCountByTeam.get(participation.Group__c) >= 4) {
                Logger.warn('Group for participation: ' + participation.Group__c + ' already contains 4 teams');
                participation.addError('Invalid: group already contain 4 teams');
            }
        }
    }

}