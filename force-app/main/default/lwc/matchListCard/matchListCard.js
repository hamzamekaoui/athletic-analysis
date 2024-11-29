import { LightningElement, api } from 'lwc';

export default class MatchListCard extends LightningElement {
    @api title;
    @api matches;
    @api emptyMessage;

    get isEmpty() {
        return (this.matches === undefined || this.matches.length === 0)
    }
}