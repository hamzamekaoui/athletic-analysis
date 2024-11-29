import { LightningElement, api } from "lwc";

export default class knockoutTree extends LightningElement {
    @api matchesByRound;

    get isKnockoutValid() {
        return (this.matchesByRound && this.matchesByRound.length > 0);
    }
}