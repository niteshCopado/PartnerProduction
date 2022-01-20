import { LightningElement, track, api, wire } from 'lwc';
import getContactList from '@salesforce/apex/ProjectConfigurationController.getContactList';
const DELAY = 300; // dealy apex callout timing in miliseconds

export default class ContactLookup extends LightningElement {
	@api defaultValue;
	@api busy;
	@api isdisable;
	
    input;
    searchKey = ''; // to store input field value
    isSearchLoading = false; // to control loading spinner
    tempResult = []; // to store the list of temp records with <mark> tag
    delayTimeout;
	selectedRecord = {}; // to store selected lookup record in object formate
    hasRecords = false;
	listResult = []; // to store list of returned records
	tempInput = ''; // to store the temp input which is not in our records
	isFirst = true;
	@track isValidEmail = true;

	//Using to set default values at the time of loading
	renderedCallback() {
		if(this.input == null) {
			this.input = this.template.querySelector('lightning-input');
		}

		if(!this.busy){
			if(this.defaultValue.Id != undefined && this.isFirst){
				this.isFirst = false;
				this.selectedRecord = {Id : this.defaultValue.Id, Name: this.defaultValue.Name};
				this.handelSelectRecordHelper();
			}
		}
	}

	// wire function property to fetch search record based on user input
	@wire(getContactList, { searchKey: '$searchKey'})
	 searchResult(value) {
		const { data, error } = value;
		this.isSearchLoading = false;
		this.tempResult = [];
		if (data && !data.isError) {
			this.listResult = data;
			for (let i in this.listResult) {
					let tempObj = {Id : this.listResult[i].Id, Name: this.listResult[i].Name};
					this.tempResult.push(tempObj);
				}
				if(this.searchKey && this.searchKey != 'undefined' && this.searchKey != '') {
					this.hasRecords = this.listResult.length == 0 ? false : true;
				}
				if(!this.hasRecords) {
					this.tempInput = '';
					this.tempInput = `<mark style="background-color:yellow">${this.searchKey}</mark>`;
				}
		 }
		else if (data && data.isError) {
			this.dispatchCustomEvent('error', "Server error while loading the form data.");
		 }
		else if (error) {
			this.dispatchCustomEvent('error', 'Error while loading the form data.');
		}
	};

	// update searchKey property on input field change
	handleKeyChange(event) {
		this.input.setCustomValidity('');
        this.input.reportValidity();

		this.validateEmail(event.target.value);

		// Debouncing this method: Do not update the reactive property as long as this function is
		// being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
		this.isSearchLoading = true;
		window.clearTimeout(this.delayTimeout);
		const searchKey = event.target.value;
		this.showHideLookupDropdown(searchKey);
		this.delayTimeout = setTimeout(() => {
			this.searchKey = searchKey;
		}, DELAY);
	}

	//Using to validate the email address
	validateEmail(searchKey){
		var isValidationError = false;
        var mailformat = /^\w+([\.+-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        var EmailValue = searchKey;
        if(EmailValue != ''){
            if(!EmailValue.match(mailformat)){
                isValidationError = true;
            }
        }
        
        if(isValidationError){
            this.isValidEmail = false;
            return true;
        }else{
            this.isValidEmail = true;
            return false;
        }
	}

	// This method is used to show hide the lookup dropdown before selection of record
	showHideLookupDropdown(searchKey) {
		const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
		const clsList = lookupInputContainer.classList;
		if(searchKey.trim() != '' && !clsList.contains('slds-is-open')) {
			clsList.add('slds-is-open');
		}
		else if(searchKey.trim() == '' && clsList.contains('slds-is-open')){
			clsList.remove('slds-is-open');
		}
	}

	// method to clear selected lookup record
	handleRemove(){
		this.hasRecords = false;
		this.searchKey = '';
		this.selectedRecord = {};
		this.lookupUpdatehandler(undefined); // update value on parent component as well from helper function

		// remove selected pill and display input field again
		const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
		searchBoxWrapper.classList.remove('slds-hide');
		searchBoxWrapper.classList.add('slds-show');
		const pillDiv = this.template.querySelector('.pillDiv');
		pillDiv.classList.remove('slds-show');
		pillDiv.classList.add('slds-hide');
	}

	// method to update selected record from search result
	handelSelectedRecord(event){
		var objId = event.target.getAttribute('data-recid'); // get selected record Id
		let tempSelectedRecord = this.listResult.find(data => data.Id === objId); // find selected record from list of records
		// if selected record found in list, else create a custom option based on user input
		if(tempSelectedRecord) {
			this.selectedRecord = tempSelectedRecord;
		}
		else {
			this.selectedRecord = Object.assign({}, tempSelectedRecord, { /*matchFound: false,*/ Name: objId.replace('<mark style="background-color:yellow">','').replace('</mark>','')});
		}
		this.lookupUpdatehandler(this.selectedRecord); // update value on parent component as well from helper function
		this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
	}

	/*COMMON HELPER METHOD STARTED*/
	handelSelectRecordHelper(){
		this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
		const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
		searchBoxWrapper.classList.remove('slds-show');
		searchBoxWrapper.classList.add('slds-hide');
		const pillDiv = this.template.querySelector('.pillDiv');
		pillDiv.classList.remove('slds-hide');
		pillDiv.classList.add('slds-show');
	}

	// send selected lookup record to parent component using custom event
	lookupUpdatehandler(value){
		const oEvent = new CustomEvent('lookupupdate',
			{
				'detail': {selectedRecord: value}
			}
		);
		this.dispatchEvent(oEvent);
	}

	//returning searchkey is empty or not
	get hasSearchKey(){
		return (this.searchKey && this.searchKey != null && this.searchKey != 'undefined' && this.searchKey != '');
	}

	//Using to dipatch event to parent component
	dispatchCustomEvent(eventName, result) {
		const oEvent = new CustomEvent(eventName,
			{
				'detail': result
			}
		);
		this.dispatchEvent(oEvent);
	}
}