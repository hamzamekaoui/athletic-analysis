import { LightningElement } from 'lwc';

const groupKeys = [
    'MP = Matches Played',
    'W = Wins',
    'D = Draws',
    'L = Losses',
    'GF = Goals For',
    'GA = Goals Against',
    'GD = Goal Difference',
    'Pts = Points',
];

export default class GroupLegend extends LightningElement {
    groupKeys = groupKeys;
}