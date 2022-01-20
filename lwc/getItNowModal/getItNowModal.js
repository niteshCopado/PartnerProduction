import { LightningElement, api, wire } from 'lwc';
import getAssetsBySection from '@salesforce/apex/ListingAssetService.getAssetsBySection';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { fireEvent } from 'c/pubSub';
import uId from '@salesforce/user/Id';

export default class GetItNowModal extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @api showModal = false;
    @api installAction = false;
    @api downloadAction = false;
    @api listing;
    @api action;
    @api communityname;
    downloadUri;
    sandboxInstallLink;
    productionInstallLink;
    downloadFilename;
    downloadId;
    userId = uId;

    @api
    openModal() {
        this.showModal = true;
    }
    @api
    closeModal() {
        this.showModal = false;
    }

    connectedCallback() {
        let listingId = this.listing.id;
        console.log('Action: ', listingId, this.action);        
        getAssetsBySection({ "listingId": listingId, "section":this.action })
        .then(result => {
            console.log("here is the result... ", result);
            if (result && result.length>0) {
                console.log('One download/install item found');
                if(this.action === 'Download') {
                    //https://<YOUR_SFDC_BASE_URL>/sfc/servlet.shepherd/version/download/068XXXXXXXXXXXX
                    //console.log('URL ===> ', window.location+'/sfc/servlet.shepherd/version/download/'+result[0].ContentVersion_Id__c);
                    this.downloadFilename = 'test';
                    this.downloadAction = true;
                    let currentPageUrl = window.location.href;
                    this.getDownloadUri = currentPageUrl.split('/s/')[0]+'/sfc/servlet.shepherd/version/download/'+result[0].ContentVersion_Id__c;
                    this.downloadId = result[0].ContentVersion_Id__c;
                } else if (this.action === 'Install') {
                    this.downloadFilename = 'test';
                    this.installAction = true;
                    this.getSandboxInstallLink = 'https://test.salesforce.com/packaging/installPackage.apexp?p0='+result[0].ContentVersion_Id__c;
                    this.getProductionInstallLink = 'https://login.salesforce.com/packaging/installPackage.apexp?p0='+result[0].ContentVersion_Id__c;
                } else {
                    console.log('Unsupported action!');
                }
                
            }
        })
        .catch(error => {
            console.log(error);
        });
    }

    handleInstallClickProduction() {
        console.log('Trigger event for production install');
        this.submitEvent(this.action, 'Production', null);
    }
    handleInstallClickSandbox() {
        console.log('Trigger event for sandbox install');
        this.submitEvent(this.action, 'Sandbox', null);
    }

    handleDownloadClick() {
        this.submitEvent(this.action, this.downloadFilename, this.downloadId);
    }

    submitEvent(act, act2, did) {
        let dt = new Date(Date.now()).toISOString().replace('T', ' ');
        fireEvent(this.pageRef, 'listingAnalyticsEvent', {
            dt: dt,
            userId: this.userId,
            action: act,
            action2: act2,
            listingId: this.listing.id,
            docId: did,
            pageSource: null
        });
    }
}