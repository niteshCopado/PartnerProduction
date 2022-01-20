/**
 * Controller Test class for Project Configurations on community
 */
@IsTest
public class ProjectConfigurationControllerTest {
	@testSetup
	static void setup(){
		Id communityProfileId = [SELECT Id FROM Profile WHERE Name = 'CUSTOM Customer Community Login User'].Id;

		Account account = new Account(Name='Test Project Configuration Account') ;
		insert account;

		Contact contact = new Contact(AccountId=account.Id, FirstName='Test Project Configuration', LastName='Contact', Email='testemailprojectconfiguration@emailtest.com');
		Contact contact1 = new Contact(AccountId=account.Id, FirstName='Test Project Configuration', LastName='Contact 1', Email='testemailprojectconfiguration1@emailtest.com');
		insert contact;
		insert contact1;

		User user = new User(FirstName=contact.FirstName, LastName=contact.LastName, Email=contact.Email, ContactId=contact.Id,
								Alias='myalias', EmailEncodingKey = 'UTF-8',
								LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US',
								ProfileId=communityProfileId, Country='United States', IsActive=true,
								TimezoneSidKey='America/Los_Angeles', Username='demo1734@handomdemodomainz.djw.cmq');

		insert user;
		Project__c project1 = new Project__c(Name='Test Project 1', Account__c=account.Id, IsActive__c=true);
		insert project1;
		Project__c project2 = new Project__c(Name='Test Project 2', Account__c=account.Id, IsActive__c=true);
		insert project2;

		Project_Team_Member__c ptmOfProject1 = new Project_Team_Member__c(Customer_Project__c=project1.Id, Contact__c=contact.Id, IsActive__c=true, Is_Super_User__c=true);
		insert ptmOfProject1;

		Project_Team_Member__c ptmOfProject2 = new Project_Team_Member__c(Customer_Project__c=project2.Id, Contact__c=contact.Id, IsActive__c=true, View_Case_Report__c=true);
		insert ptmOfProject2;
	}

	/**
	 * Test method for getting user projects based on permissions in project team member records.
	 */
	@IsTest
	public static void testGetUserProjects() {
		User communityUser = [SELECT Id From User Where Username='demo1734@handomdemodomainz.djw.cmq'];
		System.runAs(communityUser){
			List<CommunityWrapper.PicklistEntry> projects = (List<CommunityWrapper.PicklistEntry>) ProjectConfigurationController.getUserProjects().result;
			System.assertEquals(2, projects.size());
		}
	}

	/**
	 * Test method for getting user projects details along with it's permissions in project team member records.
	 */
	@IsTest
	public static void testGetUserProjectDetailsAndPermissions() {
		User communityUser = [SELECT Id From User Where Username='demo1734@handomdemodomainz.djw.cmq'];
		System.runAs(communityUser){
			List<CommunityWrapper.PicklistEntry> projects = (List<CommunityWrapper.PicklistEntry>) ProjectConfigurationController.getUserProjects().result;
			CommunityWrapper.UserProjectDetails projectDetails = (CommunityWrapper.UserProjectDetails) ProjectConfigurationController.getUserProjectDetailsAndPermissions(projects[0].value).result;
			System.assertEquals(1, projectDetails.NumberOfActiveTeamMembers);
			System.assertEquals(true, projectDetails.TeamMemberIsActive);
			System.assertEquals(true, projectDetails.TeamMemberIsSuperUser);
			System.assertEquals(true, projectDetails.TeamMemberManageTeam);
			System.assertEquals(true, projectDetails.TeamMemberLogCases);
			System.assertEquals(true, projectDetails.TeamMemberViewCasesReport);
			System.assertEquals(true, projectDetails.TeamMemberViewCertificationsReport);
		}
	}

	/**
	 * Test method for getting cases and it's count corresponding to a project.
	 */
	@IsTest
	public static void testGetCasesAndGetAllCasesCount() {
		User communityUser = [SELECT Id From User Where Username='demo1734@handomdemodomainz.djw.cmq'];
		String projectId = '';
		System.runAs(communityUser){
			Map<String, String> filterTags = new Map<String, String>();
			List<CommunityWrapper.PicklistEntry> projects = (List<CommunityWrapper.PicklistEntry>) ProjectConfigurationController.getUserProjects().result;
			projectId = projects[0].value;
			createCommunityCaseWithProject(projectId);
			List<CommunityWrapper.CaseDetails> caseList = (List<CommunityWrapper.CaseDetails>) ProjectConfigurationController.getCases(projectId, 100, 1, filterTags, 'ImpactedArea', 'DESC').result;
			System.assertEquals(1, caseList.size());

			Integer casesCount = (Integer) ProjectConfigurationController.getAllCasesCount(projectId, filterTags).result;
			System.assertEquals(1, casesCount);

			filterTags.put('searchText', 'text which need to search');
			filterTags.put('status', 'New');
			filterTags.put('filterDateType', 'CreatedDate');
			filterTags.put('startDate', '2021-01-01');
			filterTags.put('endDate', '2021-01-10');
			filterTags.put('createdBy', 'Test User');
			List<CommunityWrapper.CaseDetails> caseListWithFilters = (List<CommunityWrapper.CaseDetails>) ProjectConfigurationController.getCases(projectId, 100, 1, filterTags, 'ImpactedArea', 'DESC').result;
			System.assertEquals(0, caseListWithFilters.size());
		}
	}

	/**
	 * Test method for getting projects with log case access on project team member record.
	 */
	@IsTest
	public static void testGetUserProjectsWithLogCaseAccess() {
		User communityUser = [SELECT Id From User Where Username='demo1734@handomdemodomainz.djw.cmq'];
		System.runAs(communityUser) {
			List<CommunityWrapper.PicklistEntry> userProjectsWithLogCaseAccessOptions = ProjectConfigurationController.getUserProjectsWithLogCaseAccess();
			System.assertEquals(1, userProjectsWithLogCaseAccessOptions.size());
		}
	}

	/**
	 * Test method for getting project team members list corresponding to a project and for getting project team member corresponding to Id.
	 */
	@IsTest
	public static void testGetMembersListAndGetPTM() {
		User communityUser = [SELECT Id From User Where Username='demo1734@handomdemodomainz.djw.cmq'];
		System.runAs(communityUser){
			List<CommunityWrapper.PicklistEntry> projects = (List<CommunityWrapper.PicklistEntry>) ProjectConfigurationController.getUserProjects().result;
			List<Project_Team_Member__c> projectTeamMembers = ProjectConfigurationController.getMembersList(projects[0].value);
			System.assertEquals(1, projectTeamMembers.size());

			Project_Team_Member__c ptm = ProjectConfigurationController.getPTM(projectTeamMembers[0].Id);
			System.assertNotEquals(null, ptm);
		}
	}

	/**
	 * Method to test the contact list corresponding to a Email.
	 */
	@IsTest
	public static void testGetContactList() {
		User communityUser = [SELECT Id From User Where Username='demo1734@handomdemodomainz.djw.cmq'];
		System.runAs(communityUser){
			List<Contact> contactList = ProjectConfigurationController.getContactList('testemailprojectconfiguration1@emailtest.com');
			System.assertEquals(1, contactList.size());
		}
	}

	/**
	 * Method to test the create/update of project team member corresponding to a project.
	 */
	@IsTest
	public static void testCreateUpdatePTM() {
		User communityUser = [SELECT Id From User Where Username='demo1734@handomdemodomainz.djw.cmq'];
		System.runAs(communityUser){
			Contact contact = [Select Id From Contact WHERE Email = 'testemailprojectconfiguration@emailtest.com'];
			List<CommunityWrapper.PicklistEntry> projects = (List<CommunityWrapper.PicklistEntry>) ProjectConfigurationController.getUserProjects().result;
			List<Project_Team_Member__c> projectTeamMembers = ProjectConfigurationController.getMembersList(projects[1].value);

			Map<String, Object> recData = new Map<String, Object>();
			recData.put('Contact__c', contact.Id);
			recData.put('Id', projectTeamMembers[0].Id);
			recData.put('IsActive__c', false);
			recData.put('Is_Super_User__c', false);
			recData.put('Log_Case__c', false);
			recData.put('View_Case_Report__c', true);
			recData.put('View_Certification_Report__c', false);
			recData.put('Manage_Team__c', true);
			recData.put('Customer_Project__c', projects[1].value);
			Project_Team_Member__c ptm = ProjectConfigurationController.createUpdatePTM(true, recData);

			CommunityWrapper.UserProjectDetails projectDetails = (CommunityWrapper.UserProjectDetails) ProjectConfigurationController.getUserProjectDetailsAndPermissions(projects[1].value).result;
			System.assertEquals(null, projectDetails);
		}
	}

	/**
	 * Method to test the invite project team member functionality.
	 */
	@IsTest
	public static void testInvitePTM() {
		User communityUser = [SELECT Id From User Where Username='demo1734@handomdemodomainz.djw.cmq'];
		System.runAs(communityUser){
			ProjectConfigurationController.invitePTM('testemailprojectconfiguration@emailInvite.com');
		}
	}

	/**
	 * Method to test the certification name.
	 */
	@IsTest
	public static void testgetCertNames() {
		User communityUser = [SELECT Id, ContactId From User Where Username='demo1734@handomdemodomainz.djw.cmq'];
		Contact conObj = [SELECT Id, Email From Contact Where Id = :communityUser.ContactId];
		String projectId = '';

		Academy_Certification_Program__c certificationProgram = TestDataFactory.createCertificationProgram();
		INSERT certificationProgram;

		System.runAs(communityUser){
			List<String> certList = ProjectConfigurationController.getCertNames();
			System.assertEquals(1, certList.size());
		}
	}

	/**
	 * Method to test the certification list corresponding to account on project.
	 */
	@IsTest
	public static void testGetCertsList() {
		User communityUser = [SELECT Id, ContactId From User Where Username='demo1734@handomdemodomainz.djw.cmq'];
		Contact conObj = [SELECT Id, Email From Contact Where Id = :communityUser.ContactId];
		String projectId = '';

		Academy_Certification_Program__c certificationProgram = TestDataFactory.createCertificationProgram();
		INSERT certificationProgram;

		System.runAs(communityUser){
			Academy_Certification_Student__c  certificationStudent = TestDataFactory.createCertificationStudent(conObj);
			INSERT certificationStudent;

			Academy_Certification__c  certificate = TestDataFactory.createCertification(certificationStudent.Id,certificationProgram.Id);
			INSERT certificate;

			Academy_Certification_Examination__c  exam = TestDataFactory.createCertificationExam(certificationProgram.Id,certificate.Id, certificationStudent.Id);
			INSERT exam;

			certificate.Certification_Examination__c = exam.Id;
			update certificate;

			List<CommunityWrapper.PicklistEntry> projects = (List<CommunityWrapper.PicklistEntry>) ProjectConfigurationController.getUserProjects().result;
			projectId = projects[0].value;

			List<Academy_Certification__c> certList = ProjectConfigurationController.getCertsList(projectId, 'Expired', 'Test Project', 'TestCertificateProgram', 'Expired', '', '', '');
			System.assertEquals(1, certList.size());
		}
	}

	/**
	 * Method to create a community case with project.
	 */
	private static void createCommunityCaseWithProject(String projectId) {
		CommunitySupportCaseController.CaseFormResponseWrap newCase = new CommunitySupportCaseController.CaseFormResponseWrap();
		// Get impacted area for case from custom metadata
		CommunityWrapper.ResponseWrap impactedAreaResponse = CustomStringSearchLookupController.getImpactedAreas('test','copadoSupport','Case_Impacted_Areas__mdt');
		List <CommunityWrapper.CustomSobject> returnList = (List <CommunityWrapper.CustomSobject>) impactedAreaResponse.result;
		// Set attachements
		List<CommunityWrapper.relatedFile> files = new List<CommunityWrapper.relatedFile>();
		CommunityWrapper.relatedFile file1 = new CommunityWrapper.relatedFile();
		file1.PathOnClient = 'Test File';
		file1.Title = 'Test File';
		file1.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
		files.add(file1);

		// Set the values for case form response
		newCase.impactedArea = returnList[0];
		newCase.subject = 'Test Subject';
		newCase.description = 'Test Description';
		newCase.orgId = 'Test OrgId';
		newCase.productionDeployment = 'Yes';
		newCase.loginAccessGranted = 'No';
		newCase.percentageUsersAffected = '20-40%';
		newCase.isAffectDataIntegrity = 'No';
		newCase.haveWorkaround = 'No';
		newCase.isAffectCriticalFunctionality = 'No';
		newCase.files = files;
		newCase.project = projectId;
		CommunityWrapper.ResponseWrap response = CommunitySupportCaseController.saveInputsOfCaseForm('copadoSupport', JSON.Serialize(newCase));
	}
    
    /**
	 * Test method for getting case details.
	 */
	@IsTest
	public static void testGetCaseDetail() {
		User communityUser = [SELECT Id From User Where Username='demo1734@handomdemodomainz.djw.cmq'];
		System.runAs(communityUser){
            Map<String, String> filterTags = new Map<String, String>();
			List<CommunityWrapper.PicklistEntry> projects = (List<CommunityWrapper.PicklistEntry>) ProjectConfigurationController.getUserProjects().result;
			String projectId = projects[0].value;
			createCommunityCaseWithProject(projectId);
			List<CommunityWrapper.CaseDetails> caseList = (List<CommunityWrapper.CaseDetails>) ProjectConfigurationController.getCases(projectId, 100, 1, filterTags, 'ImpactedArea', 'DESC').result;
			String caseId = caseList[0].Id;

            CommunityWrapper.CaseFieldSetWrap csDetail = ProjectConfigurationController.getCaseDetail(caseId);
			System.assertNotEquals(null, csDetail.textAreaFieldsMap);
		}
	}
}