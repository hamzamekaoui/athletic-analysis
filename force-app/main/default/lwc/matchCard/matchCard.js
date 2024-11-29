import { LightningElement, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

export default class MatchCard extends NavigationMixin(LightningElement) {
    @api match;

    matchHolder = 'TBD';

    get score() {
        const isMatchSet = (this.match.homeScore != null) && (this.match.awayScore != null);
        return isMatchSet && (`${this.match.homeScore} - ${this.match.awayScore}`);
    }

    get isHomeTeamSet() {
        return (this.match.homeCode != null) && (this.match.homeFlag != null);
    }

    get isAwayTeamSet() {
        return (this.match.awayCode != null) && (this.match.awayFlag != null);
    }

    get style() {
        let matchClasses = 'slds-grid slds-grid_vertical slds-grid_align-space slds-var-p-around_medium slds-box slds-theme_shade slds-var-m-around_small slds-align_absolute-center match';
        if (this.match.isFinal) {
            matchClasses = matchClasses.concat(' final')
        }
        return matchClasses;
    }

    handleClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.match.id,
                actionName: "view"
            }
        });
    }
}