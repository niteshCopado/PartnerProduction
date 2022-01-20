import { LightningElement, api, track } from 'lwc';

export default class ProjectConfigurationPagination extends LightningElement {
    //@api pageRecordsRange;
    @api totalRecords;
    @api currentPageRecords;

    /**
     * Options for records per page.
     */
    @api recordsPerPageOptions = [
        { label: '10 Records/Page', value: '10' },
        { label: '50 Records/Page', value: '50' },
        { label: '100 Records/Page', value: '100' },
        { label: '200 Records/Page', value: '200' },
        { label: '500 Records/Page', value: '500' },
        { label: '1000 Records/Page', value: '1000' },
    ];

    /**
     * Method to reset the current page to page number 1.
     */
    @api
    resetCurrentPage() {
        this.currentPage = 1;
        this.dispatchCustomEventWithPageVars('page', this.currentPage, this.selectedRecordsPerPage);
    }
    @track currentPage = 1;
    @track selectedRecordsPerPage = '100';
    @track pages;

    connectedCallback() {
        this.setDefaultVars();
    }

    renderedCallback() {
        this.disableEnableActions();
    }

    /**
     * Method to check if there are any records or not.
     */
    get hasRecords() {
        return this.totalRecords > 0;
    }

    /**
     * Method to return the page records range of a current page out of total records.
     */
    get pageRecordsRange() {
        let pageRecordStartRange = ((this.currentPage - 1) * this.selectedRecordsPerPage ) + 1;
        let pageRecordEndRange = this.currentPage * this.selectedRecordsPerPage;
        pageRecordEndRange = (pageRecordEndRange > this.currentPageRecords)
                            ? (pageRecordStartRange + this.currentPageRecords - 1) : pageRecordEndRange;
        return pageRecordStartRange + '-' + pageRecordEndRange + ' of ' + this.totalRecords;
    }

    /**
     * Method to return the number of pages for all the records.
     */
    get numberOfPages() {
        this.pages = Math.ceil(this.totalRecords/this.selectedRecordsPerPage);
        return 'of ' + this.pages;
    }

    /**
     * Method to set the default vars for page.
     */
    setDefaultVars() {
        this.dispatchCustomEventWithPageVars('page', this.currentPage, this.selectedRecordsPerPage);
    }

    /**
     * Method to handle the change in option for records per page.
     * @param {object} event 
     */
    handleChange(event) {
        // Reset current page
        this.currentPage = 1;
        this.selectedRecordsPerPage = event.target.value;
        this.dispatchCustomEventWithPageVars('page', this.currentPage, this.selectedRecordsPerPage);
    }

    /**
     * Method to handle the page based on entered page number.
     * @param {object} event 
     */
    handlePage(event) {
        let page = event.target.value;
        let isnum = /^\d+$/.test(page);
        if(!isnum) {
            page = 1;
            if(this.currentPage == page) {
                event.target.value = 1;
            }
        }

        // Set last page if entered page number is greater than overall pages
        if(page > this.pages) {
            if(this.currentPage == this.pages) {
                event.target.value = this.pages;
            }
            else {
                this.currentPage = this.pages;
            }
        }
        // Set first page if entered page number is less than 1
        else if(page < 1) {
            if(this.currentPage == 1) {
                event.target.value = 1;
            }
            else {
                this.currentPage = 1;
            }
        }
        else {
            this.currentPage = page;
        }
        this.dispatchCustomEventWithPageVars('page', this.currentPage, this.selectedRecordsPerPage);
    }

    /**
     * Method to handle the click of buttons of pagination.
     * @param {object} event 
     */
    handleClick(event) {
        let label = event.target.label;
        if (label === "First") {
            this.handleFirst();
        } else if (label === "Previous") {
            this.handlePrevious();
        } else if (label === "Next") {
            this.handleNext();
        } else if (label === "Last") {
            this.handleLast();
        }
        this.dispatchCustomEventWithPageVars('page', this.currentPage, this.selectedRecordsPerPage);
    }

    /**
     * Method to handle the click of Next button of pagination.
     */
    handleNext() {
        this.currentPage = ((this.currentPage + 1) > this.pages ) ? this.pages : (this.currentPage + 1);
    }

    /**
     * Method to handle the click of Previous button of pagination.
     */
    handlePrevious() {
        this.currentPage = ((this.currentPage - 1) <= 0 ) ? 1 : (this.currentPage - 1);
    }

    /**
     * Method to handle the click of First button of pagination.
     */
    handleFirst() {
        this.currentPage = 1;
    }

    /**
     * Method to handle the click of Last button of pagination.
     */
    handleLast() {
        this.currentPage = this.pages;
    }

    /**
     * Method to disable/enable actions of pagination.
     */
    disableEnableActions() {
        let buttons = this.template.querySelectorAll("lightning-button");

        buttons.forEach(bun => {
            if (bun.label === "First") {
                bun.disabled = this.currentPage == '1' ? true : false;
            } else if (bun.label === "Previous") {
                bun.disabled = this.currentPage == '1' ? true : false;
            } else if (bun.label === "Next") {
                bun.disabled = this.currentPage == this.pages ? true : false;
            } else if (bun.label === "Last") {
                bun.disabled = this.currentPage == this.pages ? true : false;
            }
        });
    }

    /**
     * Method to disptach custom event with page vars.
     * @param {string} eventName 
     * @param {number} currentPage 
     * @param {number} pageSize 
     */
    dispatchCustomEventWithPageVars(eventName, currentPage, pageSize) {
        let pageVars = {currentPage: currentPage, pageSize: pageSize};
        this.dispatchCustomEvent(eventName, pageVars);
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
}