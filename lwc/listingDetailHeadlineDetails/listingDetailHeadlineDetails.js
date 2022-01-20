import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubSub';
import uId from '@salesforce/user/Id';

export default class ListingDetailHeadlineDetails extends LightningElement {
    @api record;
    @api communityname;
    @wire(CurrentPageReference) pageRef;
    userId = uId;

    handleGetItNowClick() {
        let dt = new Date(Date.now()).toISOString().replace('T', ' ');
        fireEvent(this.pageRef, 'listingAnalyticsEvent', {
            dt: dt,
            userId: this.userId,
            action: 'Click',
            action2: this.record.fields.Get_It_Now_Action__c.value,
            listingId: this.record.id,
            docId: null,
            pageSource: null
        });
        const modal = this.template.querySelector('c-get-it-now-modal');
        modal.openModal();
    }

    get pricingHeader(){
        if (this.record.fields.Price__c.value=='Free') return 'Free';
        else return '';
    }
}