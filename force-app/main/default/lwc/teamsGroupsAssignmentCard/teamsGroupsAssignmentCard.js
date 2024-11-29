import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import createTournament from '@salesforce/apex/TournamentController.createTournament';
import getGroupNames from '@salesforce/apex/GroupController.getGroupNames';

export default class TeamsGroupsAssignmentCard extends NavigationMixin(LightningElement) {
    options = []

    @api tournamentTitle;
    @api selectedTeams;
    @api selectedStadiums;
    @track groups = [];

    connectedCallback() {
        getGroupNames()
          .then((groupNames) => {
            this.options = this.selectedTeams.map(team => ({
                label: team.Name,
                value: team.Id
            }));

            this.groups = groupNames.map(group => ({
                name: group,
                availableOptions: [...this.options],
                selectedValues: []
            }));
          })
          .catch((error) => console.error(error));
    }

    handleChange(event) {
        const groupName = event.target.name;
        const selectedIds = event.detail.value;

        const currentGroup = this.groups.find(group => group.name === groupName);
        currentGroup.selectedValues = selectedIds;

        const selectedInOther = new Set(
          this.groups
            .filter(group => group.name !== groupName)
            .flatMap(group => group.selectedValues)
        );

        this.groups.forEach(group => {
            if (group.name === groupName) {
                group.availableOptions = this.options.filter(option => !selectedInOther.has(option.value));
            } else {
                const selectedInCurrentAndOthers = new Set([
                  ...selectedIds,
                  ...this.groups
                    .filter(c => c.name !== groupName && c.name !== group.name)
                    .flatMap(c => c.selectedValues)
                ]);

                group.availableOptions = this.options.filter(option => !selectedInCurrentAndOthers.has(option.value))
            }
        });
    }

    handleClick() {
        // Validate team assignment before sending request
        const totalSelected = this.groups.flatMap(group => group.selectedValues).length;

        if (totalSelected < this.selectedTeams.length) {
            this.dispatchEvent(new ShowToastEvent({
                message: 'Please make sure all available teams are assigned',
                variant: 'error'
            }));
            return;
        }

        // Not using the Map object because it doesn't serialize to the expected format Apex is awaiting (even though both are Maps -_-)
        const teamsByGroup = {};

        this.groups.forEach(group => {
            teamsByGroup[group.name] = group.selectedValues
        });

        createTournament({
            tournamentTitle: this.tournamentTitle,
            groupTeams:  teamsByGroup,
            stadiums: this.selectedStadiums
        }).then((tournamentId)  => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Tournament Created!',
                message: `Tournament ${this.tournamentTitle} is created successfully`,
                variant: 'success'
            }));

            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: tournamentId,
                    actionName: "view"
                }
            });
        });
    }
}