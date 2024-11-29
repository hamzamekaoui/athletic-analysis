import { api, LightningElement, track, wire } from "lwc";
import getKnockoutMatches from '@salesforce/apex/MatchController.getKnockoutStageMatches'
import { MessageContext, subscribe, unsubscribe } from "lightning/messageService";
import Channel from '@salesforce/messageChannel/Channel__c';

export default class TeamKnockout extends LightningElement {
    subscription = null;
    tournamentId;
    matchesByRound = [];
    @api recordId;
    @wire(MessageContext) messageContext;

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
            Channel,
            (message) => {
                this.tournamentId = message.tournamentId;
            });
    }

    @wire(getKnockoutMatches, { tournamentId: '$tournamentId', teamId: '$recordId' })
    wiredData({ data, error }) {
        if (error) {
            console.log(error);
        } else {
            const rounds = {}
            const matches = data || [];

            matches.forEach((match, index) => {
                if (!rounds[match.round]) {
                    rounds[match.round] = [];
                }
                const matchToAdd = { ...match }
                if (match.round === 'Finals' && index === matches.length - 1) {
                    matchToAdd.isFinal = true;
                }
                rounds[match.round].push(matchToAdd);
            });

            this.matchesByRound = Object.entries(rounds).map(([name, matches]) => ({ name, matches }));
        }
    }
}