import { LightningElement, track } from 'lwc';

export default class ProjectConfigurationLayout extends LightningElement {
    showError;
    errorMessage = '';
    showBottomBorder;
    selectedTab;
    @track navigationTabs = {
        showManageTeam: false,
        showProjectDetails: false,
        showCases: false,
        showCertifications: false
    }
    @track projectDetails = {};

    /**
     * Handle manage team click
     * @param event 
     */
    handleManageTeam(event) {
        this.reset();
        this.navigationTabs.showManageTeam = event.detail;
        this.selectedTab = 'manageteam';
        this.showBottomBorder = true;
    }

    /**
     * Handle cases tab click
     * @param event 
     */
    handleCases(event) {
        this.reset();
        this.navigationTabs.showCases = event.detail;
        this.selectedTab = 'cases';
        this.showBottomBorder = true;
    }

    /**
     * Handle certifications tab click
     * @param event 
     */
    handleCertifications(event) {
        this.reset();
        this.navigationTabs.showCertifications = event.detail;
        this.selectedTab = 'certifications';
        this.showBottomBorder = true;
    }

    /**
     * Handle Project Details tab click
     * @param event 
     */
    handleProjectDetails(event) {
        this.reset();
        this.navigationTabs.showProjectDetails = event.detail.show;
        this.selectedTab = 'projectdetails';
        this.projectDetails = event.detail.projectDetails;
        this.showBottomBorder = true;
    }

    /**
     * Handle Project change in dropdown
     */
    handleProjectChange() {
        this.reset();
    }

    /**
     * Handle error
     * @param event 
     */
    handleError(event) {
        this.errorMessage = event.detail;
        this.showError = true;
    }

    /**
     * Reset vars
     */
    reset() {
        this.navigationTabs = {
            showManageTeam: false,
            showProjectDetails: false,
            showCases: false,
            showCertifications: false
        }
        this.showBottomBorder = false;
    }
}