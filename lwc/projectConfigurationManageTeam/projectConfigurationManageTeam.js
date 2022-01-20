import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMembersList from '@salesforce/apex/ProjectConfigurationController.getMembersList';
import getPTM from '@salesforce/apex/ProjectConfigurationController.getPTM';
import createUpdatePTM from '@salesforce/apex/ProjectConfigurationController.createUpdatePTM';
import invitePTM from '@salesforce/apex/ProjectConfigurationController.invitePTM';
import { refreshApex } from '@salesforce/apex';
import Id from '@salesforce/user/Id';

export default class ProjectConfigurationManageTeam extends LightningElement {
    @api projId;
    @api isEdit;
    @api projectDetails;
    
    @track members;
    @track errorMsg = '';
    @track showModelBox = false;
    @track ptmRecId = '';
    @track conId = '';
    @track isactive = false;
    @track issuper = false;
    @track manageteam = false;
    @track logcase = false;
    @track viewcasereport = false;
    @track viewcertreport = false;
    @track isUpdate = false;
    @track isInvite = false;
    @track userEmail = '';
    @track editValue = {};
    @track isBusy = false;
    @track isCurrentUser = false;
    @track currentUserId = Id;

    // Actions defined for Project Team Members Data list
    actions = [ { label: 'Edit', name: 'edit' } ];

    // Columns defined for Project Team Members Data list
    columns = [
        { label: 'Name', fieldName: 'Profile_Pic_URL__c', type:'profileImage', typeAttributes: { name: { fieldName: 'Contact_Name__c' } }},
        { label: 'Manage Team', fieldName: 'Manage_Team__c', type:'boolean'},
        { label: 'Log Cases', fieldName: 'Log_Case__c', type:'boolean'},
        { label: 'View Case Reports', fieldName: 'View_Case_Report__c', type:'boolean'},
        { label: 'View Certification Reports', fieldName: 'View_Certification_Report__c', type:'boolean'},
        { label: 'Active Team Member', fieldName: 'IsActive__c', type:'boolean'}
    ];
    
    //Used to things to do when component loaded successfully
    connectedCallback(){
        if(this.isEdit){
            this.columns.push({ type: 'action', typeAttributes: { rowActions: this.actions } });
        }

        this.resetFrom();
    }

    // Used to reset the UI
    resetFrom(){
        this.errorMsg = '';
        this.ptmRecId = '';
        this.conId = '';
        this.isactive = false;
        this.issuper = false;
        this.manageteam = false;
        this.logcase = false;
        this.viewcasereport = false;
        this.viewcertreport = false;
        this.isUpdate = false;
        this.isInvite = false;
        this.userEmail = '';
        this.editValue = {};
        this.isBusy = false;
        this.isCurrentUser = false;
    }

    // Wired method used to get all the list of PTM when intially loaded and when refresh Apex method called
    @wire(getMembersList, {recId : '$projId'})
    getMembers(value) {
        this.wiredActivities = value;
        const { data, error } = value; // destructure the provisioned value
        if (data && !data.isError) {
            this.members = data;
        }
        else if (data && data.isError) {
            this.errorMsg = 'There is an error while fetching data.';
         }
        else if (error) {
            this.errorMsg = 'There is an error while fetching data.';
        }
    };

    // Handle the edit action when trying to edit the record and display edit form with existing values
    handleRowAction(event){
        this.ptmRecId = event.detail.row.Id;
        this.isUpdate = true;
        this.isBusy = true;

        //Fetch existing record detail
        getPTM({recId : this.ptmRecId})
        .then(result => {
            this.isactive = result.IsActive__c;
            this.issuper = result.Is_Super_User__c;
            this.logcase = result.Log_Case__c;
            this.manageteam = result.Manage_Team__c;
            this.viewcasereport = result.View_Case_Report__c;
            this.viewcertreport = result.View_Certification_Report__c;
            this.conId = result.Contact__c;
            this.editValue = {Id : result.Contact__c, Name : result.Contact_Name__c};
            this.isBusy = false;
            this.showModelBox = true;

            if(this.currentUserId == result.User__c){
                this.isCurrentUser = true;
            }
        })
        .catch(error => {
            this.errorMsg = 'There is an error while fatching record.';
            this.isBusy = false;
            this.showModelBox = true;
        });
    }

    // Show the popup model for create new PTM
    openModal(){
        this.showModelBox = true;
        this.resetFrom();
    }

    // Close the popup model for create new PTM
    closeModal(){
        this.showModelBox = false;
        this.resetFrom();
    }

    // getting the selected Contact value from lokkup
    contactChangedHandler(event){
        this.conId = event.target.value;
    }

    // getting the selected checkbox value of IsActive checkbox
    activeChangedHandler(event){
        this.isactive = event.target.checked;
    }

    // getting the selected checkbox value of IsSuperUser checkbox
    superChangedHandler(event){
        this.issuper = event.target.checked;
        this.manageteam = event.target.checked;
        this.logcase = event.target.checked;
        this.viewcasereport = event.target.checked;
        this.viewcertreport = event.target.checked;
    }

    // getting the selected checkbox value of ManageTeam checkbox
    manageTeamChangedHandler(event){
        this.manageteam = event.target.checked;
    }

    // getting the selected checkbox value of LogCase checkbox
    logCaseChangedHandler(event){
        this.logcase = event.target.checked;
    }

    // getting the selected checkbox value of ViewCaseReport checkbox
    viewCaseReportChangedHandler(event){
        this.viewcasereport = event.target.checked;
    }

    // getting the selected checkbox value of ViewCertReport checkbox
    viewCertReportChangedHandler(event){
        this.viewcertreport = event.target.checked;
    }

    // Used to create/Update Project Team Member
    createPTM(){
        if(this.conId == ''){
            this.errorMsg = 'Please Select Contact.';
            return;
        }

        var fields = {'Id' : this.ptmRecId, 'Customer_Project__c' : this.projId, 'Contact__c' : this.conId, 'IsActive__c' : this.isactive, 'Is_Super_User__c' : this.issuper, 'Manage_Team__c' : this.manageteam, 'Log_Case__c' : this.logcase, 'View_Case_Report__c' : this.viewcasereport, 'View_Certification_Report__c' : this.viewcertreport};

        createUpdatePTM({ isUpdate: this.isUpdate, recData : fields })
        .then((result) => {
            refreshApex(this.wiredActivities);
            this.closeModal();

            //toast message
            const event = new ShowToastEvent({
                title: 'Congratulations!!!',
                message: 'Project Team Member record saved successfully.',
                variant: 'success'
            });
            this.dispatchEvent(event);
        })
        .catch((error) => {
            if(error.body.pageErrors[0].statusCode.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                this.errorMsg = error.body.pageErrors[0].message;
            }else{
                this.errorMsg = 'There is an error while saving record.';
            }
        });
    }

    // Used to search the contact on lookup
    handleSearch(event) {
        const selectedContact = event.detail.selectedRecord;

        if(selectedContact == undefined){
            this.isInvite = false;
            this.userEmail = '';
            this.conId = '';
        }
        
        if(selectedContact.Id != undefined){
            this.conId = selectedContact.Id;
            this.isInvite = false;
            this.userEmail = '';
        }else{
            this.isInvite = true;
            this.userEmail = selectedContact.Name;
            this.conId = '';
        }
    }

    // Showing error message on UI when we have error in searching the contact data from Lookup
    handleErrorSearch(event){
        this.errorMsg = 'There is an error while fetching data.';
    }

    // Calling the apex method to Invite the user for joining the community
    inviteUser(event){
        invitePTM({ emailId: event.target.name })
        .then((result) => {
            this.closeModal();

            //toast message
            const event = new ShowToastEvent({
                title: 'Congratulations!!!',
                message: 'User Invited Successfully.',
                variant: 'success'
            });
            this.dispatchEvent(event);
        })
        .catch((error) => {
            this.errorMsg = 'There is an error while inviting user.';
        });
    }
}