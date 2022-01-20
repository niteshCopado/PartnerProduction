import { LightningElement, track, api, wire } from 'lwc';
import getCertsList from '@salesforce/apex/ProjectConfigurationController.getCertsList';
import getCertNames from '@salesforce/apex/ProjectConfigurationController.getCertNames';

const DELAY = 300;

export default class ProjectConfigurationCertifications extends LightningElement {
    
    //Certification List Datatable columns
    columns = [
        { label: 'User Name', fieldName: 'Student_Name__c', type:'text', sortable : true},
        { label: 'Certification Name', fieldName: 'Program_Name__c', type:'text', sortable : true},
        { label: 'Status', fieldName: 'Status__c', type:'text', sortable : true},
        { label: 'Certification Earned Date', fieldName: 'Earned_Date__c', type:'date', sortable : true},
        { label: 'Certification Expiring Date', fieldName: 'Expiration_Date__c', type:'date', sortable : true}
    ];

    // Certification Status picklist option used in filter
    statusPickListValues = [
        {label: "Valid", value: 'Valid'},
        {label: "Expired", value: 'Expired'}
    ];

    // Certification Date Type picklist option used in filter
    filterDateTypeOptions = [
        {label: "Earned Date", value: 'Earned Date'},
        {label: "Expiring Date", value: 'Expiring Date'}
    ];

    @api projId;
    @track data;
    @track errorMsg = '';
    @track isLoading = false;
    @track showHideFilters = false;
    @track filterButtonText = 'Show Filters';
    @track certPickListValues = [];

    //Variables used for seraching
    @track searchAll = '';
    @track userName = '';
    @track certName = '';
    @track certStatus = '';
    @track dateType = '';
    @track startDate = '';
    @track endDate = '';
    @track isDateDisable = true;

    //Variables used for sorting
    @track defaultSortDirection = 'asc';
    @track sortDirection = 'asc';
    @track sortedBy;
    @track errorMsg = '';

    //Variables used for pagination
    @track totalRecords; // The List of Complete Records
    @track pageNo = 1; // by default will always be 1
    @track recordsperpage = '10'; // The no of records needs to be displayed in a single page
    @track totalPages = 1;
    @track recordsToDisplay;
    @track startRecord;
    @track endRecord;
    @track end = false;
    @track pagelinks = [];

    // Wired method to get all Certification name
    @wire(getCertNames)
    getCertificatesName(value) {
        this.isLoading = true;
        const { data, error } = value; // destructure the provisioned value
        if (data && !data.isError) {            
            if(data.length > 0){
                const allCert = [];
                data.forEach(function (item, index) {
                    allCert.push({label: item, value: item});
                });
                this.certPickListValues = allCert;
            }
            
            this.errorMsg = '';
            this.isLoading = false;
        }
        else if (data && data.isError) {
            this.errorMsg = 'There is an error while fetching data.';
            this.isLoading = false;
         }
        else if (error) {
            this.errorMsg = 'There is an error while fetching data.';
            this.isLoading = false;
        }
    };

    // Wired method to get all Certification list initialy and recall when filter changed
    @wire(getCertsList, {recId : '$projId', searchAll : '$searchAll', userName : '$userName', certName : '$certName',
                        certStatus : '$certStatus', dateType : '$dateType', startDate : '$startDate', endDate : '$endDate'})
    getCertificates(value) {
        this.isLoading = true;
        const { data, error } = value; // destructure the provisioned value
        if (data && !data.isError) {            
            if(data.length > 0){
                this.data = data;
            }else{
                this.data = null;
                this.recordsToDisplay = null;
            }
            
            this.errorMsg = '';
            this.isLoading = false;
            this.setRecordsToDisplay();
        }
        else if (data && data.isError) {
            this.errorMsg = 'There is an error while fetching data.';
            this.isLoading = false;
         }
        else if (error) {
            this.errorMsg = 'There is an error while fetching data.';
            this.isLoading = false;
        }
    };

    //Used for handle the visibility of the filters on UI
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

    //<----- Method Used for pagination Start ------>
    // Used to create drop down that How many records per we can show
    get recordsPerPageOptions() {
        return [
            { label: '10 Records/Page', value: '10' },
            { label: '50 Records/Page', value: '50' },
            { label: '100 Records/Page', value: '100' },
            { label: '200 Records/Page', value: '200' },
            { label: '500 Records/Page', value: '500' },
            { label: '1000 Records/Page', value: '1000' },
        ];
    }

    //Handle to control which records we needs to display on UI based on pagination
    setRecordsToDisplay() {
        this.pagelinks = [];
        this.totalRecords = this.data.length;
        this.pageNo = 1;
        this.totalPages = Math.ceil(this.totalRecords / this.recordsperpage);
        this.preparePaginationList();

        for (let i = 1; i <= this.totalPages; i++) {
            this.pagelinks.push(i);
        }
    }

    //Preparing how many page will create
    preparePaginationList() {
        let begin = (this.pageNo - 1) * parseInt(this.recordsperpage);
        let end = parseInt(begin) + parseInt(this.recordsperpage);
        this.recordsToDisplay = this.data.slice(begin, end);

        this.startRecord = begin + parseInt(1);
        this.endRecord = end > this.totalRecords ? this.totalRecords : end;
        this.end = end > this.totalRecords ? true : false;

        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.disableEnableActions();
        }, DELAY);
    }

    // Moving the page based on action
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
    }

    // Moving on next page
    handleNext() {
        this.pageNo += 1;
        this.preparePaginationList();
    }

    // Moving on previous page
    handlePrevious() {
        this.pageNo -= 1;
        this.preparePaginationList();
    }

    // Moving on first page
    handleFirst() {
        this.pageNo = 1;
        this.preparePaginationList();
    }

    // Moving on last page
    handleLast() {
        this.pageNo = this.totalPages;
        this.preparePaginationList();
    }

    // Handle to unable and disable buttons of the pagination
    disableEnableActions() {
        let buttons = this.template.querySelectorAll("lightning-button");

        buttons.forEach(bun => {
            if (bun.label === this.pageNo) {
                bun.disabled = true;
            } else {
                bun.disabled = false;
            }

            if (bun.label === "First") {
                bun.disabled = this.pageNo === 1 ? true : false;
            } else if (bun.label === "Previous") {
                bun.disabled = this.pageNo === 1 ? true : false;
            } else if (bun.label === "Next") {
                bun.disabled = this.pageNo === this.totalPages ? true : false;
            } else if (bun.label === "Last") {
                bun.disabled = this.pageNo === this.totalPages ? true : false;
            }
        });
    }

    // Changing total no of records on the PAge to Display
    handleChange(event) {
        this.recordsperpage = event.target.value;
        this.setRecordsToDisplay();
    }

    get pageRecordsRange() {
        return this.startRecord + '-' + this.endRecord + ' of ' + this.totalRecords;
    }

    get numberOfPages() {
        return 'of ' + Math.ceil(this.totalRecords/this.recordsperpage);
    }

    // Moving on Specific page
    handlePage(event) {
        let page = event.target.value;
        if(page > this.totalPages) {
            this.pageNo = this.totalPages;
        }
        else if(page < 1) {
            this.pageNo = 1;
        }
        else {
            this.pageNo = page;
        }
        this.preparePaginationList();
    }
    //<----- Method Used for pagination End ------>
    

    //<----- Method Used for sorting Start ------>
    //Its genaric method of sorting. based on param its sorts the data list
    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    //Used to Sort the Data list
    handlesort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        this.setRecordsToDisplay();
    }
    //<----- Method Used for sorting End ------>


    //<----- Method Used for filter start ------>
    //Identifing that on based on which field we have to filter the data from Data list
    handleChangeSearch(event){
        const eveName = event.target.name;

        if(eveName == 'all'){
            this.searchAll = event.target.value;
        }
        if(eveName == 'username'){
            this.userName = event.target.value;
        }
        if(eveName == 'certName'){
            this.certName = event.target.value;
        }
        if(eveName == 'status'){
            this.certStatus = event.target.value;
        }
        if(eveName == 'filterDateType'){
            this.dateType = event.target.value;
        }
        if(eveName == 'startDate'){
            this.startDate = event.target.value;
        }
        if(eveName == 'endDate'){
            this.endDate = event.target.value;
        }
    }

    //Reset the filter UI
    clearSearch(){
        this.searchAll = '';
        this.userName = '';
        this.certName = '';
        this.certStatus = '';
        this.dateType = '';
        this.startDate = '';
        this.endDate = '';
        this.isDateDisable = true;
        this.template.querySelectorAll('c-combobox-with-pill').forEach(element => {
            element.reset();
        });
    }

    //Controlling the dropdown fields used in filter
    handleSelection(event) {
        if(event.detail.fieldName == 'certName'){
            this.certName = event.detail.selectedRecord;
        }
        if(event.detail.fieldName == 'certStatus'){
            this.certStatus = event.detail.selectedRecord;
        }
        if(event.detail.fieldName == 'dateType'){
            this.dateType = event.detail.selectedRecord;
            if(event.detail.selectedRecord == ''){
                this.isDateDisable = true;
                this.startDate = '';
                this.endDate = '';
            }else{
                this.isDateDisable = false;
            }
        }
	}
    //<----- Method Used for filter end ------>
}