import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubSub';
import uId from '@salesforce/user/Id';

export default class ListingResultRow extends NavigationMixin(LightningElement) {
    @api row;
    @wire(CurrentPageReference) pageRef;
    userId = uId;

    handleClick(event) {
        let elemnt = event.currentTarget;
        let recordId = elemnt.dataset.id;

        
        let dt = new Date(Date.now()).toISOString().replace('T', ' ');
        fireEvent(this.pageRef, 'listingAnalyticsEvent', {
            dt: dt,
            userId: this.userId,
            action: 'Page View',
            action2: null,
            listingId: recordId,
            docId: null,
            pageSource: null
        });

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'listing-detail',
            },
            state: {
                'recordId': recordId
            }
        });
    }
}