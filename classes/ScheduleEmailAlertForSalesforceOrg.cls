global class ScheduleEmailAlertForSalesforceOrg implements Schedulable{
    global void execute(SchedulableContext SC) {
        string Url = System.URL.getSalesforceBaseUrl().toExternalForm();
        List<String> idList = new List<String>();
        List<String> mailToAddresses = new List<String>(); 
        Map<Id,Salesforce_Org__c> SFDCMap = new MAp<Id,Salesforce_Org__c>();
        Group gp = [SELECT (SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE Name = 'Deal Desk & Renewal'];
        for (GroupMember gm : gp.GroupMembers) {
            idList.add(gm.UserOrGroupId);
        }
        List<User> userList = [SELECT Email FROM User WHERE Id IN :idList];
        for(User u : userList) {
            mailToAddresses.add(u.email);
        }
        for(sfFma__FeatureParameterInteger__c  fpiObj : [SELECT Id,sfFma__FullName__c,sfFma__License__r.Name,Is_Checked__c,
                                                         sfFma__License__r.sfLma__Org_Edition__c,sfFma__License__r.Salesforce_Org__c,
                                                         Expiration_Date__c,sfFma__License__r.Salesforce_Org__r.Name,sfFma__License__r.Salesforce_Org__r.Id,sfFma__License__r.Salesforce_Org__r.Account_Status__c FROM sfFma__FeatureParameterInteger__c 
                                                         Where Is_Checked__c=True AND sfFma__License__r.Salesforce_Org__r.Org_Type__c='Production' ]){
                                                                System.debug('@@@@Send Email');
                                                                 Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                                                 mail.setToAddresses(mailToAddresses);
                                                                 mail.setSubject('After 7 Days Salesforce Org Services Expiring');
                                                                 String body = 'Hi,'+ +'<br/>';
                                                                 body += 'Here is the Salesforce Org Details'+ +'<br/>';
                                                                 body += 'Salesforce Org Name :- '+fpiObj.sfFma__License__r.Salesforce_Org__r.Name+ '<br/>';
                                                                 body += 'Salesforce Org Status :- '+fpiObj.sfFma__License__r.Salesforce_Org__r.Account_Status__c+ '<br/>';
                                                                 body += 'License Name :- '+fpiObj.sfFma__License__r.Name+ '<br/>';
                                                                 body += 'Org Edition :- '+fpiObj.sfFma__License__r.sfLma__Org_Edition__c+ '<br/>';
                                                                 body += 'Feature Parameter Full Name :- '+fpiObj.sfFma__FullName__c+ '<br/>';
                                                                 body += 'Expiration Date :- '+fpiObj.Expiration_Date__c+ '<br/>';
                                                                 body += 'Record Link :-'+Url+'/'+fpiObj.sfFma__License__r.Salesforce_Org__r.Id+ '<br/>';
                                                                 body += 'Thanks';
                                                                 mail.setHtmlBody(body);
                                                                 Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                                                             
                                                         }
        for(sfLma__License__c liceObj :[Select id,sfLma__Expiration_Date__c,sfLma__Org_Edition__c,Salesforce_Org__r.Id,Name,Salesforce_Org__r.Account_Status__c,Salesforce_Org__r.Org_Type__c,Salesforce_Org__r.name from sfLma__License__c
                                        where sfLma__Expiration_Date__c !='Does not expire' AND Salesforce_Org__r.Org_Type__c='Production']){
                                            Date startDate = Date.today();
                                            Date endDate = date.valueOf(liceObj.sfLma__Expiration_Date__c);
                                            Integer noOfDays = startDate.daysBetween( endDate );
                                            
                                            system.debug( 'Output is ' + noOfDays );
                                            if(noOfDays == 7){
                                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                                mail.setToAddresses(mailToAddresses);
                                                mail.setSubject('After 7 Days Salesforce Org Services Expiring');
                                                String body = 'Hi,'+ +'<br/>';
                                                body += 'Here is the Salesforce Org Details'+ +'<br/>';
                                                body += 'Salesforce Org Name :- '+liceObj.Salesforce_Org__r.Name+ '<br/>';
                                                body += 'Salesforce Org Status :- '+liceObj.Salesforce_Org__r.Account_Status__c+ '<br/>';
                                                body += 'License Name :- '+liceObj.Name+ '<br/>';
                                                body += 'Org Edition :- '+liceObj.sfLma__Org_Edition__c+ '<br/>';
                                                body += 'Expiration Date :- '+liceObj.sfLma__Expiration_Date__c+ '<br/>';
                                                body += 'Record Link :-'+Url+'/'+liceObj.Salesforce_Org__r.Id+ '<br/>';
                                                body += 'Thanks';
                                                mail.setHtmlBody(body);
                                                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                                            }
                                        }
    }
}