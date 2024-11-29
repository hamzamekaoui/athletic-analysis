import { LightningElement, api } from 'lwc';

export default class TeamWithFlag extends LightningElement {
    @api code;
    @api flag;
    @api flagToRight;

    get containerClass() {
        const gridStyle = (this.flagToRight) ? 'slds-grid_reverse' : 'slds-grid';
        return `slds-grid ${gridStyle}`;
    }
}