@isTest
public class TestScheduleEmailAlertForSalesforceOrg {
	@isTest
    public static void unitTest(){
        Test.startTest();
        Account acc = TestDataFactory.createAccount('Fake needed acc', 'EUR');
        insert acc;
        
        Contact con = TestDataFactory.createContact(acc.id,'Fakecon');
        insert con;
        
        Salesforce_Org__c org = TestDataFactory.createSalesforceOrg('Test Method Org');
        org.OrgId__c = '00D1l0000000dkE';
        org.Org_Type__c ='Production';
        insert org;
        
        sfLma__License__c lic = TestDataFactory.createLicense(org.Id,5);
        lic.sfLma__Subscriber_Org_ID__c = '00D1l0000000dkE';
        lic.sfLma__Expiration__c = Date.today()+7;
        lic.sfLma__Org_Type__c = 'Developer Edition';
        insert lic;
        
        sfLma__Package__c pack = TestDataFactory.craetePackage('Copado Deployer');
        pack.sfLma__Developer_Name__c = 'Copado BasePackage';
        insert pack;
        
        sfFma__FeatureParameter__c fpCCM = TestDataFactory.createFeatureParameter('copado__CCM_Licenses_Enabled',
                                                                                  'Integer','copado',
                                                                                  '10.0','LMO to Subscriber', pack.Id);
        insert fpCCM;
        
        
        sfFma__FeatureParameterInteger__c fpi = TestDataFactory.createFeatureParameterInteger('copado__CCM_Licenses_Enabled',lic.Id, fpCCM.Id);   
        fpi.External_Id__c = org.Id + '_' + 'copado__CCM_Licenses_Enabled';
        fpi.Expiration_Date__c = System.Today().AddDays(7);
        fpi.sfFma__Value__c = 0;
        insert fpi;
        List<String> ccTo = new List<String>();
        ccTo.add('rranjan@copado.com');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.settoAddresses(ccTo);
        mail.setSubject('Test');
        mail.setPlainTextBody('Test');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        
        // This test runs a scheduled job at 12 AM daily
        String CRON_EXP = '0 0 0 ? * * *';
        // Schedule the test job
        String jobId = System.schedule('TestScheduledCalculateCurrentARROnQuote', CRON_EXP, new ScheduleEmailAlertForSalesforceOrg());
        Test.stopTest();
    }
}