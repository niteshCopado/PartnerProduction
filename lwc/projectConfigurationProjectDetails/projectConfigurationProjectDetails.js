import { LightningElement, api } from 'lwc';

export default class ProjectConfigurationProjectDetails extends LightningElement {
    @api projectDetails = {};
	
	//verifyng that user have the permission of Case Tab or NOT
	get showCasesTab() {
        return (this.projectDetails.TeamMemberLogCases || this.projectDetails.TeamMemberViewCasesReport);
    }

	//verifyng that user have the permission of Certification Tab or NOT
    get showCertificationsTab() {
        return (this.projectDetails.TeamMemberViewCertificationsReport);
    }
	
	//Redirecting user on Manage Team Tab
	handleClickTM(){
		this.dispatchCustomEvent('manageteam', 'true');
	}
	
	//Redirecting user on Case Tab
	handleClickCase(){
		this.dispatchCustomEvent('cases', 'true');
	}
	
	//Redirecting user on Certification Tab
	handleClickCert(){
		this.dispatchCustomEvent('certifications', 'true');
	}
	
	//Using to dipatch event to parent component
	dispatchCustomEvent(eventName, result){
		const oEvent = new CustomEvent(eventName,
			{
				'detail': result
			}
		);
		this.dispatchEvent(oEvent);
	}
}