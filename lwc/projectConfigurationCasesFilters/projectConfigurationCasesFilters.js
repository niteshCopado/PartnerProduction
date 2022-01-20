import { LightningElement, track } from 'lwc';
const DELAY = 300;

export default class ProjectConfigurationCasesFilters extends LightningElement {
    @track tags = {};
    @track selectedFilterDate = 'ClosedDate';
    delayTimeout;

    /**
     * Date type options for filters based on date.
     */
    filterDateTypeOptions = [
        {label: "Case Opened Date", value: 'CreatedDate'},
        {label: "Case Closed Date", value: 'ClosedDate'},
        {label: "Last Case Comment Time", value: 'Last_Case_Comment_Time__c'}
    ]

    /**
     * Case status options for filters.
     */
    filterStatusOptions = [
        {label: "Closed", value: 'Closed'},
        {label: "Opened", value: 'Opened'},
        {label: "New", value: 'New'},
        {label: "Needs Requirements", value: 'Needs Requirements'},
        {label: "In Progress", value: 'In Progress'},
        {label: "Awaiting Customer Feedback", value: 'Awaiting Customer Feedback'},
        {label: "Escalated", value: 'Escalated'},
        {label: "On Hold", value: 'On Hold'},
        {label: "Hold - awaiting Feedback", value: 'Hold - awaiting Feedback'},
        {label: "Complete", value: 'Complete'},
        {label: "Canceled", value: 'Canceled'}
    ]

    //<----- Methods Used for filtering start ------>

    /**
     * Method to handle selection of combobox-with-pill option.
     * @param {object} event 
     */
    handleSelection(event) {
        if(event.detail && event.detail.fieldName && event.detail.selectedRecord && event.detail.fieldName != ''){
            this.tags[event.detail.fieldName] = event.detail.selectedRecord;
        }
        else if(event.detail && event.detail.fieldName && event.detail.selectedRecord == '' &&
        event.detail.fieldName != '' && this.tags.hasOwnProperty(event.detail.fieldName)){
            delete this.tags[event.detail.fieldName];
            if(event.detail.fieldName == 'filterDateType') {
                if(this.tags.hasOwnProperty('startDate')) {
                    let startDateInput = this.template.querySelector('[data-id="startDate"]');
                    startDateInput.value = null;
                    delete this.tags['startDate'];
                }
                if(this.tags.hasOwnProperty('endDate')) {
                    let endDateInput = this.template.querySelector('[data-id="endDate"]');
                    endDateInput.value = null;
                    delete this.tags['endDate'];
                }
            }
        }
        this.dispatchCustomEvent('filtered',this.tags);
	}

    /**
     * Method to handle the search based on lightning-input.
     * @param {object} event 
     */
    handleChangeSearch(event){
        const eveName = event.target.name;
        const eveValue = event.target.value;
        if(eveValue && eveValue.trim() === '') {
            event.target.value = null;
        }
        if(eveName) {
            if(eveValue && eveValue != '') {
                this.tags[eveName] = eveValue;
                this.dispatchCustomEventWithTimeOut('filtered',this.tags);
            }
            else if(this.tags.hasOwnProperty(eveName)) {
                delete this.tags[eveName];
                this.dispatchCustomEventWithTimeOut('filtered',this.tags);
            }
        }
    }

    /**
     * Method to clear all the filters.
     */
    clearFilters() {
        this.tags = {};
        var inputs = this.template.querySelectorAll('lightning-input');
		inputs.forEach(function(element){
            element.value = null;
		},this);
        this.template.querySelectorAll('c-combobox-with-pill').forEach(element => {
            element.reset();
        });
        this.dispatchCustomEvent('filtered',this.tags);
    }

    //<----- Method Used for filtering end ------>

    /**
     * Method to dispatch the custom event with timeout.
     * @param {string} eventName 
     * @param {object} result 
     */
    dispatchCustomEventWithTimeOut(eventName, result) {
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.dispatchCustomEvent(eventName,result);
        }, DELAY);
    }

    /**
     * Method to dispatch the custom event.
     * @param {string} eventName 
     * @param {object} result 
     */
    dispatchCustomEvent(eventName, result) {
		const oEvent = new CustomEvent(eventName,
			{
				'detail': result
			}
		);
		this.dispatchEvent(oEvent);
	}

    /**
     * Method to show the date filters of Start Date and End Date.
     */
    get showDateFilters() {
        return !this.tags.hasOwnProperty('filterDateType');
    }
}