import { LightningElement, track, api } from 'lwc';
export default class ComboboxWithPill extends LightningElement {
    @api fieldname;
	@api label;
    @api placeholder;
    @api pickListValues;

    @track selectedRecord = '';
	@track selectedRecordLabel = '';

	//Using to reset the combobox Pill UI
    @api
    reset(){
        this.selectedRecord = '';
		this.selectedRecordLabel = '';

		// remove selected pill and display input field again
		const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
		searchBoxWrapper.classList.remove('slds-hide');
		searchBoxWrapper.classList.add('slds-show');
		
        const pillDiv = this.template.querySelector('.pillDiv');
		pillDiv.classList.remove('slds-show');
		pillDiv.classList.add('slds-hide');
    }

	//Using to show all the combobox options
    showOption() {
		const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
		const clsList = lookupInputContainer.classList;
		clsList.add('slds-is-open');
	}

	//Using to hide all the combobox options
    hideOption() {
		const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
		const clsList = lookupInputContainer.classList;
        this.delayTimeout = setTimeout(() => {
			clsList.remove('slds-is-open');
		}, 300);
	}

	//Using to select the record and handle the UI
    handelSelectedRecord(event){
		this.selectedRecord = event.target.getAttribute('data-recid'); // get selected record Id
		this.selectedRecordLabel = event.target.getAttribute('data-rec-label'); // get selected record label
		
        this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
		
        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
		searchBoxWrapper.classList.remove('slds-show');
		searchBoxWrapper.classList.add('slds-hide');
		
        const pillDiv = this.template.querySelector('.pillDiv');
		pillDiv.classList.remove('slds-hide');
		pillDiv.classList.add('slds-show');

        this.pillUpdatehandler(this.selectedRecord, event.target.getAttribute('data-fld'));
	}

	//Using to remove selected record
    handleRemove(event){
		this.selectedRecord = '';
		this.selectedRecordLabel = '';

		// remove selected pill and display input field again
		const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
		searchBoxWrapper.classList.remove('slds-hide');
		searchBoxWrapper.classList.add('slds-show');
		
        const pillDiv = this.template.querySelector('.pillDiv');
		pillDiv.classList.remove('slds-show');
		pillDiv.classList.add('slds-hide');

        this.pillUpdatehandler(this.selectedRecord, event.target.getAttribute('data-fld'));
	}

	//Using to push the event for parent component
    pillUpdatehandler(value, fld){
		const oEvent = new CustomEvent('pillupdate',
			{
				'detail': {selectedRecord: value, fieldName : fld}
			}
		);
		this.dispatchEvent(oEvent);
	}
}