import LightningDatatable from 'lightning/datatable';
import teamWithFlagTemplate from './templates/teamWithFlag.html';

export default class GroupDataTypes extends LightningDatatable {
    static customTypes = { // MUST: keep name as customTypes
        teamWithFlag: {
            template: teamWithFlagTemplate,
            standardCellLayout: true,
            typeAttributes: ['code', 'flag']
        }
    };
}