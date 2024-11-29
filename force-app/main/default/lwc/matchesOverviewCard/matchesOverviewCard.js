import {LightningElement, api, wire} from 'lwc';
import getRecentMatches from '@salesforce/apex/MatchController.getRecentMatchesByTeam';
import getUpcomingMatches from '@salesforce/apex/MatchController.getUpcomingMatchesByTeam'
import {MessageContext, subscribe, unsubscribe} from 'lightning/messageService';
import Tournament from '@salesforce/messageChannel/Channel__c';

function getMatchesFromResponse(response) {
    const {data, error} = response;
    if (data !== undefined) {
        return data;
    } else {
        return [];
    }
}

export default class MatchesOverviewCard extends LightningElement {
    subscription = null;
    tournamentId;

    @api recordId;
    @wire(MessageContext) messageContext;
    @wire(getRecentMatches, {tournamentId: '$tournamentId', teamId: '$recordId'}) recentMatchesResponse;
    @wire(getUpcomingMatches, {tournamentId: '$tournamentId', teamId: '$recordId'}) upcomingMatchesResponse;

    connectedCallback() {
        this.subscribeToTournament();
    }

    disconnectedCallback() {
        this.unsubscribeFromTournament();
    }

    unsubscribeFromTournament() {
        unsubscribe(this.subscription);
    }

    subscribeToTournament() {
        this.subscription = subscribe(
            this.messageContext,
            Tournament,
            (message) => {
                this.tournamentId = message.tournamentId;
            });
    }

    get recentMatches() {
        return {
            title: 'Recent Matches',
            matches: getMatchesFromResponse(this.recentMatchesResponse),
            emptyMessage: 'No recent matches found'
        }
    }

    get upcomingMatches() {
        return {
            title: 'Upcoming Matches',
            matches: getMatchesFromResponse(this.upcomingMatchesResponse),
            emptyMessage: 'No upcoming matches found'
        }
    }
}