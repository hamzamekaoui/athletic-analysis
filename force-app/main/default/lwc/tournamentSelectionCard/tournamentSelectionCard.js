import { LightningElement, api, wire } from "lwc";
import { MessageContext, publish } from 'lightning/messageService';
import getTournamentList from '@salesforce/apex/TournamentController.getTournamentListForTeam';
import Channel from '@salesforce/messageChannel/Channel__c';

export default class TournamentGroup extends LightningElement {
    options = [];

    @api recordId;
    @wire(MessageContext) messageContext;

    @wire(getTournamentList, {teamId: '$recordId'})
    wiredData({ data, error }) {
        if (error) {
            console.error(error);
        } else if (data !== undefined) {
            console.log(data)
            this.options = this.options = data.map((tournament) => ({ label: tournament.name, value: tournament.id }));
        }
    }

    handleChange(event) {
        const tournament = event.detail.value;
        publish(this.messageContext, Channel, {tournamentId: tournament});
    }
}