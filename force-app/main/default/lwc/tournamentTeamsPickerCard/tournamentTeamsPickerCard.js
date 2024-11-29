import { LightningElement, api, wire, track } from 'lwc';
import getTeams from '@salesforce/apex/TeamController.getTeams';

const TEAMS_SELECTION_COUNT = 32;

const columns = [
    {
        label: 'Name',
        fieldName: "Name",
        type: 'text',
        sortable: true,
        hideDefaultActions: true,
    },
    {
        label: 'Code',
        fieldName: "Code__c",
        type: 'text',
        sortable: true,
        hideDefaultActions: true,
    }
];

export default class TournamentTeamsPickerCard extends LightningElement {
    teams = [];
    columns = columns;
    maxCount = TEAMS_SELECTION_COUNT;
    
    @api selectedTeams = [];

    @wire(getTeams)
    wiredData({ data, error }) {
        if (error) {
            console.error(error);
        } else if (data !== undefined) {
            this.teams = data;
        }
    }
    
    handleRowSelection(event) {
        this.selectedTeams = event.detail.selectedRows;
    }

    @api
    validate() {
        if (this.selectedTeams.length !== TEAMS_SELECTION_COUNT) {
            return {
                isValid: false,
                errorMessage: `Please select exactly ${TEAMS_SELECTION_COUNT} teams before proceeding.`
            }
        } else {
            return {
                isValid: true,
            }
        }
    }
}