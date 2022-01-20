import { LightningElement, wire, track, api } from 'lwc';
import supportIcons from '@salesforce/resourceUrl/Community';
import getUserProjects from '@salesforce/apex/ProjectConfigurationController.getUserProjects';
import getUserProjectDetailsAndPermissions from '@salesforce/apex/ProjectConfigurationController.getUserProjectDetailsAndPermissions';

export default class ProjectConfigurationHeader extends LightningElement {
    projectConfigurationLogo = supportIcons + '/CommunityResources/projectIcons/ProjectConfiguration.png';
    projectSummaryLogo;
    manageTeamLogo;
    casesLogo;
    certificationsLogo;

    _selectedTab;

    /**
     * Getter and Setter for selected tab
     */
    @api
    get selectedTab(){
        return this._selectedTab;
    }
    //Set method use to setup selected tab.
    set selectedTab(value){
        this._selectedTab = value;
        this.setIcons(this._selectedTab);
    }

    isBusy = true;
    projectsLoaded = false;
    projectDetailsAndPermsLoaded = false;
    @track status = {
        hasError: false,
        errorMessage: ''
    };
    @track userProjects = [];
    selectedProjectId = '';
    @track userProjectDetailsAndPermissions;

    constructor() {
		super();
		this.setIcons(this._selectedTab);
	}

    /**
     * Wire function property to fetch active projects for active project team member.
     * @param {object} value 
     */
	@wire(getUserProjects)
	getUserProjects(value) {
		const { data, error } = value; // destructure the provisioned value
		if (data && !data.isError) {
			this.userProjects = data.result;
            this.projectsLoaded = true;
            // Set default project Id
            this.setDefaultProject();
            this.unsetBusyForProjectsAndProjectPerms();
		}
		else if (data && data.isError) {
            this.status = {
                hasError: true,
                errorMessage: "Server error while loading the projects data."
            };
			this.dispatchCustomEvent('error', this.status.errorMessage);
            this.unsetBusyForProjectsAndProjectPerms();
		 }
		else if (error) {
            this.status = {
                hasError: true,
                errorMessage: 'Error while loading the projects data.'
            };
			this.dispatchCustomEvent('error', this.status.errorMessage);
            this.unsetBusyForProjectsAndProjectPerms();
		}
	};

    /**
     * Wire function property to fetch active projects for active project team member.
     * @param {object} value 
     */
	@wire(getUserProjectDetailsAndPermissions,{userProjectId: '$selectedProjectId'})
	getUserProjectDetailsAndPermissions(value) {
		const { data, error } = value; // destructure the provisioned value
		if (data && !data.isError) {
			this.userProjectDetailsAndPermissions = data.result;
            // Open the Project Details, based on selected project
            this.handleProjectDetails();
            this.projectDetailsAndPermsLoaded = true;
            this.unsetBusyForProjectsAndProjectPerms();
		}
		else if (data && data.isError) {
            this.status = {
                hasError: true,
                errorMessage: "Server error while loading the projects permissions."
            };
            this.dispatchCustomEvent('error', this.status.errorMessage);
            this.unsetBusyForProjectsAndProjectPerms();
		 }
		else if (error) {
			this.status = {
                hasError: true,
                errorMessage: 'Error while loading the projects permissions.'
            };
			this.dispatchCustomEvent('error', this.status.errorMessage);
            this.unsetBusyForProjectsAndProjectPerms();
		}
	};

    /**
     * Check user has access to Projects
     */
    get hasRecords() {
        return this.userProjects.length > 0 && !this.isBusy && !this.status.hasError;
    }

    /**
     * Check user has don't have access to Projects
     */
    get hasNoRecords() {
        return this.userProjects.length == 0 && !this.isBusy && !this.status.hasError;
    }

    /**
     * Show case tab based on permissions of user corresponding to a Project.
     */
    get showCasesTab() {
        return (this.userProjectDetailsAndPermissions && 
                (this.userProjectDetailsAndPermissions.TeamMemberLogCases || 
                this.userProjectDetailsAndPermissions.TeamMemberViewCasesReport));
    }

    /**
     * Show certifications tab based on permissions of user corresponding to a Project.
     */
    get showCertificationsTab() {
        return (this.userProjectDetailsAndPermissions && this.userProjectDetailsAndPermissions.TeamMemberViewCertificationsReport);
    }

    /**
     * Set default project.
     */
    setDefaultProject() {
        if(this.userProjects.length > 0 && this.userProjects[0] && this.userProjects[0].value && this.selectedProjectId == '') {
            this.selectedProjectId = this.userProjects[0].value;
        }
    }

    /**
     * Set icon of selected tab.
     * @param {string} selectedTab 
     */
    setIcons(selectedTab) {
        this.projectSummaryLogo = supportIcons + '/CommunityResources/projectIcons/ProjectSummary.png';
        this.manageTeamLogo = supportIcons + '/CommunityResources/projectIcons/ManageTeam.png';
        this.casesLogo = supportIcons + '/CommunityResources/projectIcons/Cases.png';
        this.certificationsLogo = supportIcons + '/CommunityResources/projectIcons/Certifications.png';
		if(selectedTab == 'projectdetails') {
			this.projectSummaryLogo = supportIcons + '/CommunityResources/projectIcons/ProjectSummary1.png';
		}
		else if(selectedTab == 'manageteam') {
			this.manageTeamLogo = supportIcons + '/CommunityResources/projectIcons/ManageTeam1.png';
		}
		else if(selectedTab == 'cases') {
			this.casesLogo = supportIcons + '/CommunityResources/projectIcons/Cases1.png';
		}
        else if(selectedTab == 'certifications') {
			this.certificationsLogo = supportIcons + '/CommunityResources/projectIcons/Certifications1.png';
		}
	}

    /**
     * Handle project change in dropdown of projects.
     * @param {object} event 
     */
    handleChange(event) {
        this.dispatchCustomEvent('projectchange', 'true');
        this.isBusy = true;
        this.selectedProjectId = event.target.value;
    }

    /**
     * Method to set the isBusy var to false if projects and projects permissions are loaded from server,
     * or if there is any error
     */
    unsetBusyForProjectsAndProjectPerms() {
        if((this.projectsLoaded && this.projectDetailsAndPermsLoaded ) || this.status.hasError) {
            this.isBusy = false;
        }
    }

    /**
     * Handle Manage Team tab selection.
     */
    handleManageTeam() {
        this.dispatchCustomEvent('manageteam', 'true');
    }

    /**
     * Handle Cases tab selection.
     */
    handleCases() {
        this.dispatchCustomEvent('cases', 'true');
    }

    /**
     * Handle Certifications tab selection.
     */
    handleCertifications() {
        this.dispatchCustomEvent('certifications', 'true');
    }

    /**
     * Handle Project Details tab selection.
     */
    handleProjectDetails() {
        if(this.userProjectDetailsAndPermissions) {
            let projectDetails = {
                show: true,
                projectDetails: this.userProjectDetailsAndPermissions
            };
            this.dispatchCustomEvent('projectdetails', projectDetails);
        }
    }

    /**
     * Method to dispatch custom event.
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