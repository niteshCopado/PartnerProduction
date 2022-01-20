@isTest
private class TestKugamonOrderTriggerHelper {
   
    @isTest 
    public static void testMethod1() {
         
        Account accObj = TestDataFactory.createAccount('KugaHelper', 'EUR');
        insert accObj;
        
        Contact conObj = TestDataFactory.createContact(accObj.id,'TestKugamonOrderTriggerHelper');
        conObj.MailingStreet = 'E5';
        conObj.MailingCity = 'Bengalore';
        conObj.MailingState = 'Karnataka';
        conObj.MailingCountry = 'India';
        Insert conObj;      
        
        Product2 prod = TestDataFactory.createProduct('Copado Standard Edition','Licenses ',null);
        prod.kuga_sub__Renewable__c = true;
        Insert prod; 
        
        //New Opportunity
        Opportunity newOpp = TestDataFactory.createOpportunity(accObj, 'TestNewOpp', 'New Customer');
        newOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New').getRecordTypeId();        
        insert newOpp;  
        
        SBQQ__Quote__c newQuote = TestDataFactory.createCPQuote(newOpp);
        newQuote.SBQQ__Primary__c = true;
        newQuote.Payment_Method__c = 'ACH';
        Insert newQuote;
        
        SBQQ__QuoteLine__c newQLine = TestDataFactory.createCPQQuoteLine(newQuote.Id,prod.Id);
        insert newQLine ; 
        
        Pricebook2 pb = TestDataFactory.createPricebook(); 
        pb.CurrencyIsoCode = 'EUR';
        insert pb;  
        
        kugo2p__KugamonSetting__c testKugamonSetting = TestDataFactory.createKugamonSetting(pb.name);       
        insert testKugamonSetting ; 
        Test.startTest(); 
        Contract cont = TestDataFactory.createDraftContract(accObj.Id,'EUR');
        cont.StartDate = Date.newInstance(2023, 04, 09);
        cont.ContractTerm = 12;       
        insert cont;
              
        kugo2p__SalesOrder__c newOrderObj = TestDataFactory.createKugamonOrder(accObj.id);
        newOrderObj.kugo2p__ContactBilling__c = conObj.id;
        newOrderObj.kugo2p__ContactBuying__c = conObj.id;
        newOrderObj.kugo2p__ContactShipping__c = conObj.id;  
        //newOrderObj.kugo2p__Warehouse__c = wareObj.Id;                   
        newOrderObj.RecordTypeId = Schema.SObjectType.kugo2p__SalesOrder__c.getRecordTypeInfosByName().get('New').getRecordTypeId();            
        newOrderObj.kugo2p__Opportunity__c = newOpp.Id;
        newOrderObj.kugo2p__Competitors__c = 'Testing New Order';
        newOrderObj.kugo2p__PaymentMethod__c = 'Invoice';
        Insert newOrderObj;        
        newOrderObj.kuga_sub__ContractNumber__c = cont.Id;
        newOrderObj.kugo2p__RecordStatus__c = 'Released';      
        update newOrderObj;               
        Test.stopTest();                      
    }
    @isTest
    public static void testMethod2(){      
         
        Account accObj = TestDataFactory.createAccount('TestKugaHelper', 'EUR');
        insert accObj;
        
        Contact conObj = TestDataFactory.createContact(accObj.id,'TestKugamonOrderTriggerHelper');
        conObj.MailingStreet = 'E5';
        conObj.MailingCity = 'Bengalore';
        conObj.MailingState = 'Karnataka';
        conObj.MailingCountry = 'India';
        Insert conObj;        
         
        //Expansion Opportunity
        Opportunity expansionOpp = TestDataFactory.createOpportunity(accObj, ' 1EE', 'Add-on');
        expansionOpp.Value_Prop_ID__c = 'Test';
        expansionOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Expansion').getRecordTypeId();
        insert expansionOpp;
        
        SBQQ__Quote__c expansionQuote = TestDataFactory.createCPQuote(expansionOpp);
        expansionQuote.SBQQ__Primary__c = true;
        expansionQuote.Payment_Method__c = 'ACH';
        Insert expansionQuote;          
        
        Product2 prod2 = TestDataFactory.createProduct('Copado Admin','Licenses ',null);
        Insert prod2;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id=pricebookId, Product2Id=prod2.Id, UnitPrice=5, IsActive=true,CurrencyIsoCode='EUR');
        insert standardPrice; 
           
        Test.startTest();
        
        SBQQ__QuoteLine__c expansionQLine = TestDataFactory.createCPQQuoteLine(expansionQuote.Id,prod2.Id);
        Insert expansionQLine ;  
        
        
        Pricebook2 pb = TestDataFactory.createPricebook(); 
        pb.CurrencyIsoCode = 'EUR';
        insert pb;  
        
        kugo2p__KugamonSetting__c testKugamonSetting = TestDataFactory.createKugamonSetting(pb.name);       
        insert testKugamonSetting ;     
        
        kugo2p__Warehouse__c wareObj = TestDataFactory.createWarehouse('test',testKugamonSetting.id);
        Insert wareObj;
        
        Contract cont = TestDataFactory.createDraftContract(accObj.Id,'EUR');
        cont.StartDate = Date.newInstance(2023, 04, 09);
        cont.ContractTerm = 12;     
        cont.Order_ACV__c = 1000 ; 
        cont.Order_1st_yr_ARR__c = 1000 ; 
        cont.Order_Current_ARR__c = 1000 ; 
        cont.Non_Standard_ACV__c = 1000 ;  
        insert cont;
        Id expansionRecTypeId = Schema.SObjectType.kugo2p__SalesOrder__c.getRecordTypeInfosByName().get('Expansion').getRecordTypeId();
        kugo2p__SalesOrder__c orderObj = TestDataFactory.createKugamonOrder(accObj.id);
        orderObj.kugo2p__ContactBilling__c = conObj.id;
        orderObj.kugo2p__ContactBuying__c = conObj.id;
        orderObj.kugo2p__ContactShipping__c = conObj.id;
        orderObj.kugo2p__Warehouse__c = wareObj.Id;        
        orderObj.RecordTypeId = Schema.SObjectType.kugo2p__SalesOrder__c.getRecordTypeInfosByName().get('Expansion').getRecordTypeId();
        orderObj.kuga_sub__GenerateSubscription__c = true;        
        orderObj.kuga_sub__GenerateRenewalOpportunity__c =true;      
        orderObj.Quote__c = expansionQuote.Id;
        orderObj.kugo2p__Opportunity__c = expansionOpp.Id;
        orderObj.kuga_sub__ContractNumber__c = cont.Id;
        orderObj.kugo2p__RecordStatus__c = 'Released'; 
        Insert orderObj;        
        Update orderObj;               
        Test.stopTest();
    }  
}