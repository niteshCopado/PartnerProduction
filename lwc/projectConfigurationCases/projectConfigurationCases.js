import { LightningElement, api, track, wire } from 'lwc';
import getAllCasesCount from '@salesforce/apex/ProjectConfigurationController.getAllCasesCount';
import getCases from '@salesforce/apex/ProjectConfigurationController.getCases';

export default class ProjectConfigurationCases extends LightningElement {
    @api projectDetails;
    @track isBusy = true;
    @track cases = [];
    @track totalCases;
    @track showHideFilters = false;
    @track filterButtonText = 'Show Filters';
    @track tags = {};
    // Sorting variables
    @track sortBy = 'CaseNumber';
    @track sortDirection = 'asc';
    // Pagination variables
    @track pageSize;
    @track currentPage;
    errorMsg;
    columns = [
        {label: 'Case Number', fieldName: 'CaseURL', type: 'url', typeAttributes: {label: { fieldName: 'CaseNumber' }, target: '_blank'}, sortable : true},
        // { label: 'Case Number', fieldName: 'CaseNumber', type: 'text', sortable : true},
        { label: 'Impacted Area', fieldName: 'ImpactedArea', type:'text', sortable : true},
        { label: 'Subject', fieldName: 'Subject', type:'text', sortable : true},
        { label: 'Status', fieldName: 'Status', type:'text', sortable : true},
        { label: 'Date/Time Opened', fieldName: 'CreatedDate', type:'date', typeAttributes: {  
                                                                            day: 'numeric',  
                                                                            month: 'short', 
                                                                            year: 'numeric',  
                                                                            hour: '2-digit',
                                                                            minute: '2-digit', 
                                                                            hour12: true},
                                                                            sortable : true},
        { label: 'Date/Time Closed', fieldName: 'ClosedDate', type:'date', typeAttributes: {  
                                                                            day: 'numeric',  
                                                                            month: 'short', 
                                                                            year: 'numeric',  
                                                                            hour: '2-digit',
                                                                            minute: '2-digit', 
                                                                            hour12: true},
                                                                            sortable : true},
        { label: 'Last Case Comment Time', fieldName: 'LastCaseCommentTime', type:'date', typeAttributes: {  
                                                                            day: 'numeric',  
                                                                            month: 'short', 
                                                                            year: 'numeric',  
                                                                            hour: '2-digit',
                                                                            minute: '2-digit', 
                                                                            hour12: true},
                                                                            sortable : true},
        { label: 'Created By', fieldName: 'CreatedBy', type:'text', sortable : true}
    ];

    /**
     * Wire function to fetch the cases corresponding to a Project.
     * @param {object} value 
     */
    @wire(getCases, {projectId : '$projectDetails.Id', pageSize: '$pageSize', page: '$currentPage', tags: '$tags', sortBy: '$sortBy', sortDirection: '$sortDirection'})
    getCases(value) {
        const { data, error } = value; // destructure the provisioned value
        if (data && !data.isError) {
            this.isBusy = false;
            this.cases = data.result;
        }
        else if (data && data.isError) {
            this.isBusy = false;
			this.errorMsg = "Server error while loading the Cases data.";
        }
        else if (error) {
            this.isBusy = false;
            this.errorMsg = 'Error while loading the Cases data.';
        }
    };

    /**
     * Wire function to get the cases count corresponding to a Project.
     * @param {object} value 
     */
    @wire(getAllCasesCount, {projectId : '$projectDetails.Id', tags: '$tags'})
    getAllCasesCount(value) {
        const { data, error } = value; // destructure the provisioned value
        if (data && !data.isError) {
            this.totalCases = data.result;
        }
        else if (data && data.isError) {
			this.errorMsg = "Server error while loading the Cases data.";
        }
        else if (error) {
            this.errorMsg = 'Error while loading the Cases data.';
        }
    };

    /* Filtering data table start */

    /**
     * Handle show/hide filters.
     */
    handleShowHideFilters() {
        if(this.showHideFilters) {
            this.showHideFilters = false;
            this.filterButtonText = 'Show Filters';
        }
        else if(!this.showHideFilters) {
            this.showHideFilters = true;
            this.filterButtonText = 'Hide Filters';
        }
    }

    /**
     * Handle the filteration of records.
     * @param {object} event 
     */
    handleFiltered(event) {
        this.setBusy();
        // Reset current page in filtering
        this.template.querySelector('c-project-configuration-pagination').resetCurrentPage();
        this.tags = {};
        this.tags = event.detail;
    }
    /* Filtering data table end */

    /* Sorting data table start */

    /**
     * Handle sorting
     * @param {object} event 
     */
    doSorting(event) {
        this.setBusy();
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
    }
    /* Sorting data table end */

    /* Pagination methods start */

    /**
     * Handle pagination
     * @param {object} event 
     */
    handlePage(event) {
        let pageVars = event.detail;
        if(this.currentPage != pageVars.currentPage || this.pageSize != pageVars.pageSize) {
            this.setBusy();
        }
        this.currentPage = pageVars.currentPage;
        this.pageSize = pageVars.pageSize;
    }
    /* Pagination methods end */

    /**
     * Check whether there are case records or not corresponding to a Project.
     */
    get hasRecords() {
        return (this.cases.length > 0 && !this.isBusy);
    }

    /**
     * To get the number of cases on a page.
     */
    get currentPageRecords() {
        return this.cases.length;
    }

    /**
     * URL for contact-support page, along with Project Id query param.
     */
    get contactSupportURL() {
        return "/s/contactsupport?cp=" + this.projectDetails.Id;
    }

    /**
     * Method to set the busy equals to true.
     */
    setBusy() {
        this.isBusy = true;
    }
}