@IsTest
public class CustomerProjectTriggerTest {
	@IsTest
	public static void testUpdateProjectToActive() {
		Id communityProfileId = [SELECT Id FROM Profile WHERE Name = 'CUSTOM Customer Community Login User'].Id;
		Account account = new Account(Name='Test Project Trigger') ;
		insert account;

		Contact contact = new Contact(AccountId=account.Id, FirstName='Test Project Trigger', LastName='Contact', Email='testemailprojectconfiguration@emailtest.com');
		insert contact;

		User user = new User(FirstName=contact.FirstName, LastName=contact.LastName, Email=contact.Email, ContactId=contact.Id,
								Alias='myalias', EmailEncodingKey = 'UTF-8',
								LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US',
								ProfileId=communityProfileId, Country='United States', IsActive=true,
								TimezoneSidKey='America/Los_Angeles', Username='demo1734@handomdemodomainz.djw.cmq');
		insert user;

		// Create project and update it to active
		Test.startTest();

		Project__c project1 = new Project__c(Name='Test Project 1', Account__c=account.Id, IsActive__c=false);
		insert project1;

		Project_Team_Member__c ptmOfProject1 = new Project_Team_Member__c(Customer_Project__c=project1.Id, Contact__c=contact.Id, IsActive__c=true, Is_Super_User__c=true);
		insert ptmOfProject1;

		// Updating the project to active
		project1.IsActive__c = true;
		update project1;

		Test.stopTest();

		List<PermissionSetAssignment> psa = [SELECT Id From PermissionSetAssignment WHERE AssigneeId = : user.Id AND PermissionSet.Name = 'Customer_Project_Access_On_Community'];
		System.assertEquals(1, psa.size());
	}

	@IsTest
	public static void testUpdateProjectToInActive() {
		Id communityProfileId = [SELECT Id FROM Profile WHERE Name = 'CUSTOM Customer Community Login User'].Id;
		Account account = new Account(Name='Test Project Trigger') ;
		insert account;

		Contact contact = new Contact(AccountId=account.Id, FirstName='Test Project Trigger', LastName='Contact', Email='testemailprojectconfiguration@emailtest.com');
		insert contact;

		User user = new User(FirstName=contact.FirstName, LastName=contact.LastName, Email=contact.Email, ContactId=contact.Id,
								Alias='myalias', EmailEncodingKey = 'UTF-8',
								LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US',
								ProfileId=communityProfileId, Country='United States', IsActive=true,
								TimezoneSidKey='America/Los_Angeles', Username='demo1734@handomdemodomainz.djw.cmq');
		insert user;

		// Create project and update it to active
		Test.startTest();

		Project__c project1 = new Project__c(Name='Test Project 1', Account__c=account.Id, IsActive__c=true);
		insert project1;

		Project_Team_Member__c ptmOfProject1 = new Project_Team_Member__c(Customer_Project__c=project1.Id, Contact__c=contact.Id, IsActive__c=true, Is_Super_User__c=true);
		insert ptmOfProject1;

		// Updating the project to active
		project1.IsActive__c = false;
		update project1;

		Test.stopTest();

		List<PermissionSetAssignment> psa = [SELECT Id From PermissionSetAssignment WHERE AssigneeId = : user.Id AND PermissionSet.Name = 'Customer_Project_Access_On_Community'];
		System.assertEquals(0, psa.size());
	}
}