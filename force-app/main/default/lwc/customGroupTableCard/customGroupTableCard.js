import { LightningElement, api } from 'lwc';

const columns = [
    {
        label: 'Team', 
        type: 'teamWithFlag',
        typeAttributes: {
            code: { fieldName: "teamCode" },
            flag: { fieldName: "teamFlag" },
        },
        hideDefaultActions: true,
        initialWidth: 80
    },
    { 
        label: 'MP', 
        fieldName: 'matchesPlayed',
        hideDefaultActions: true,
    },
    {
        label: 'W', 
        fieldName:'wins',
        hideDefaultActions: true,
    },
    { 
        label: 'D', 
        fieldName: 'draws',
        hideDefaultActions: true,
    },
    { 
        label: 'L', 
        fieldName: 'losses',
        hideDefaultActions: true, 
    },
    { 
        label: 'GF', 
        fieldName: 'goalsFor',
        hideDefaultActions: true,
    },
    { 
        label: 'GA', 
        fieldName: 'goalsAgainst',
        hideDefaultActions: true,
    },
    { 
        label: 'GD', 
        fieldName: 'goalsDifference',
        hideDefaultActions: true,
    },
    { 
        label: 'Pts', 
        fieldName: 'points',
        hideDefaultActions: true,
    },
];

export default class CustomGroupTableCard extends LightningElement {
    columns = columns;

    @api group;

    get name() {
        return this.group.name;
    }

    get data() {
        return this.group.standing;
    }
}