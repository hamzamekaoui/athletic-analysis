import { api, LightningElement } from "lwc";
import LightningConfirm from "lightning/confirm";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import advanceTournament from '@salesforce/apex/TournamentController.advanceTournament'

export default class AdvanceTournamentButton extends LightningElement {
  @api recordId;
  @api invoke() {
    let message = {};
    LightningConfirm.open({
      message: 'Warning: Tournament will progress to the next round. Do you want to continue? ',
      variant: 'headerless',
    }).then(async result => {
      if (result) {
        try {
          const isUpdated = await advanceTournament({ tournamentId: this.recordId });
          if (isUpdated) {
            message = {
              message: 'Tournament progress to the next round is completed, refreshing...',
              variant: 'success'
            };
            setTimeout(() => window.location.reload(), 1500);
          } else {
            message = {
              message: 'Tournament already concluded',
              variant: 'info'
            };
          }
        } catch (error) {
          message = {
            message: error.body.message,
            variant: 'error'
          };
        } finally {
          this.dispatchEvent(new ShowToastEvent(message));
        }
      }
    });
  }
}