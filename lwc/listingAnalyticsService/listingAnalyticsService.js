import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import publishAnalyticsEvent from '@salesforce/apex/ListingAnalyticsService.publishListingEvent';

import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubSub';

export default class ListingAnalyticsService extends LightningElement {

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        registerListener('listingAnalyticsEvent', this.handleReceiveEvent, this);
    }

    handleReceiveEvent(analyticsEvent) {
        
        publishAnalyticsEvent(analyticsEvent)
            .then(result => {
                console.log('Published Event', analyticsEvent);
                //this.dispatchShowToastEvent('Event published', 'event published', 'confirm');
            })
            .catch(e => { 
                console.log('Error publishing event', e);
                //this.dispatchShowToastEvent('Error updating record', e.body.message, 'error');
            });
    }

    dispatchShowToastEvent(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title:title, message:message, variant:variant })
        );
    }
}