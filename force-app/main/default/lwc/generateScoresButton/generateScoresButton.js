import { api, LightningElement } from "lwc";
import LightningConfirm from "lightning/confirm";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import generatePendingScores from '@salesforce/apex/TournamentController.generatePendingScores';

export default class GenerateScoresButton extends LightningElement {
  @api recordId;
  @api invoke() {
    let message = {};
    LightningConfirm.open({
      message: 'Warning: Missing match results from the current round will be automatically generated. Do you want to continue? ',
      variant: 'headerless',
    }).then(async result => {
      if (result) {
        try {
          const isGenerated = await generatePendingScores({ tournamentId: this.recordId });
          if (!isGenerated) {
            message = {
              message: 'Generation of pending scores for the current round is completed, refreshing...',
              variant: 'success'
            }
            setTimeout(() => window.location.reload(), 1500);
          } else {
            message = {
              message: 'Current round scores are already set',
              variant: 'info'
            }
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