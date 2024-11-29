import { LightningElement, api, wire, track } from 'lwc';
import getStadiums from '@salesforce/apex/StadiumController.getStadiums';

const STADIUMS_SELECTION_COUNT = 8;

const columns = [
    {
        label: 'Name',
        fieldName: "Name",
        type: 'text',
        sortable: true,
        hideDefaultActions: true,
    },
    {
        label: 'Country',
        fieldName: "Country__c",
        type: 'text',
        sortable: true,
        hideDefaultActions: true,
    }
];

export default class TournamentStadiumsPickerCard extends LightningElement {
    stadiums = [];
    columns = columns;
    maxCount = STADIUMS_SELECTION_COUNT;
    
    @api selectedStadiums = [];

    @wire(getStadiums)
    wiredData({ data, error }) {
        if (error) {
            console.error(error);
        } else if (data !== undefined) {
            this.stadiums = data;
        }
    }

    handleRowSelection(event) {
        this.selectedStadiums = event.detail.selectedRows;
    }

    @api
    validate() {
        if (this.selectedStadiums.length < STADIUMS_SELECTION_COUNT) {
            return {
                isValid: false,
                errorMessage: `Please select exactly at least ${STADIUMS_SELECTION_COUNT} stadiums before proceeding.`
            }
        } else {
            return {
                isValid: true,
            }
        }
    }
}