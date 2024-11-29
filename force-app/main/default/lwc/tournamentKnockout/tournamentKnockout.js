import { LightningElement, api, wire } from 'lwc';
import getKnockoutMatches from '@salesforce/apex/MatchController.getKnockoutStageMatches'

export default class TournamentKnockout extends LightningElement {
    @api recordId;

    matchesByRound = [];

    @wire(getKnockoutMatches, { tournamentId: '$recordId' })
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