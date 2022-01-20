@isTest
private class SchUpdateRenewalQuoteFieldTest{
    
    @testSetup
    static void setupMethod() {     
       
        Account a = new Account(Name='My Account');
        insert a;
        
        Contact con = new Contact(FirstName='Test', LastName='Test', AccountId=a.Id);
        insert con;
        
        Id RecdTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        Opportunity o = new Opportunity(Name='My Opp', AccountId=a.Id, RecordTypeId = RecdTypeId, StageName='Marketing Qualification', CloseDate=Date.today(), CurrencyIsoCode='EUR', Main_Problems__c='Problem', Amount = 99.0,LeadSource = 'Advertisement');       
        insert o;       
               
        Id usrId = userinfo.getUserId();
        Date endDate = system.Today().addYears(1);
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c = a.Id,SBQQ__Opportunity2__c=o.id,SBQQ__SalesRep__c=usrId,SBQQ__Primary__c=true,SBQQ__PrimaryContact__c=con.Id,SBQQ__StartDate__c=system.today(),SBQQ__EndDate__c = endDate,SBQQ__Type__c='Renewal',Is_Not_Clone_Quote__c=true);
        insert quote;       
    }
    
    static testMethod void UpdateRenewalQuoteFieldMethod(){
        Test.startTest();
        ScheduleUpdateRenewalQuoteField cb = New ScheduleUpdateRenewalQuoteField();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>([SELECT Id from SBQQ__Quote__c where SBQQ__Type__c='Renewal' AND Is_Not_Clone_Quote__c = true]);      
        
        cb.execute(null);
    }
}