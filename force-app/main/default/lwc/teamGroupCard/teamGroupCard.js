import { LightningElement, api, wire } from 'lwc';
import getStandingByTeam from '@salesforce/apex/GroupController.getStandingByTeam'
import {MessageContext, subscribe, unsubscribe} from "lightning/messageService";
import Tournament from '@salesforce/messageChannel/Channel__c';

export default class TeamGroupCard extends LightningElement {
    subscription = null;
    tournamentId;
    standingGroups = [];

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
            Tournament,
            (message) => {
                this.tournamentId = message.tournamentId;
            });
    }

    @wire(getStandingByTeam, {tournamentId: '$tournamentId', teamId: '$recordId'})
    wiredData({ data, error }) {
        if (error) {
            console.error(error);
        } else if (data !== undefined) {
            const groupNames = Object.keys(data).sort();
            this.standingGroups = groupNames.map(groupName => ({
                name: groupName,
                standing: data[groupName]
            }));
        }
    }
}