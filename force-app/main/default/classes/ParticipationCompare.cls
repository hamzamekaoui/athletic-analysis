public without sharing class ParticipationCompare implements Comparator<Participation__c> {

    // We calculate the fields (Points, GD) because Formula fields don't have a value until insert and fetched
    public Integer compare(Participation__c current, Participation__c other) {
        if (calculatePoints(current) != calculatePoints(other)) {
            return (calculatePoints(current) > calculatePoints(other)) ? -1 : 1;
        }

        if (calculateGD(current) != calculateGD(other)) {
            return (calculateGD(current) > calculateGD(other)) ? -1 : 1;
        }

        if (current.Goals_For__c != other.Goals_For__c) {
            return (current.Goals_For__c > other.Goals_For__c) ? -1 : 1;
        }

        return 0;
    }

    private static Integer calculatePoints(Participation__c participation) {
        return (Integer) ((participation.Wins__c * 3) + participation.Draws__c);
    }

    private static Integer calculateGD(Participation__c participation) {
        return (Integer) (participation.Goals_For__c - participation.Goals_Against__c);
    }
}