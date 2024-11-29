import { api, LightningElement, wire } from 'lwc';
import getStandings from '@salesforce/apex/GroupController.getStandings';

export default class GroupStageStandings extends LightningElement {

    @api recordId;
    standingGroups = [];

    @wire(getStandings, { tournamentId: '$recordId' })
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