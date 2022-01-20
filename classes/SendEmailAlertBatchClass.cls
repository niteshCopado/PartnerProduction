global class SendEmailAlertBatchClass implements Database.Batchable<sObject>{
    
    global Database.queryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id,Capture_Opp_Closed_Won_Date__c,Account.name,Account.Partner_Lead__r.name,Account.Salesforce_RVP__r.firstname,Account.Salesforce_CSM__r.firstname,Account.Salesforce_AE__r.firstname, Account.Partner_Lead__r.email,Account.Salesforce_RVP__r.email,Account.Salesforce_CSM__r.email,Account.Salesforce_AE__r.email FROM opportunity WHERE Recordtype.Name=\'New\' AND StageName =\'Closed Won\' AND (Type =\'New Customer\' OR Type=\'New Business-Add On\') AND Capture_Opp_Closed_Won_Date__c != null');
    }
    
    global void execute (Database.BatchableContext BC, List<Opportunity> oppList){
        for(Opportunity opp : oppList){
            Integer actionDays = 0;
            if(opp.Capture_Opp_Closed_Won_Date__c != Null){
                actionDays = getHourDate(opp.Capture_Opp_Closed_Won_Date__c);
            }
            if(actionDays == 22){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setReplyTo(opp.Account.Partner_Lead__r.email);
                message.setSubject(opp.Account.name);
                message.setSenderDisplayName(opp.Account.Partner_Lead__r.email);
                String body = 'Hi ' +opp.Account.Salesforce_RVP__r.firstname+','+opp.Account.Salesforce_CSM__r.firstname+','+opp.Account.Salesforce_AE__r.firstname+',<br/>';
                body += 'Congratulations!'+opp.Account.name+' purchased Copado this week.<br/><br/>';
                body += 'Are you already familiar with Copado? If not, I would like to get you up to speed about what we do as I would expect conversations about this to arise soon, if not already.<br/><br/>';
                body += 'Thank You <br/> ';
                body += +opp.Account.Partner_Lead__r.name+'';
                
                message.setHtmlBody(body);
                message.toAddresses = new String[] {opp.Account.Partner_Lead__r.email,opp.Account.Salesforce_RVP__r.email,
                    opp.Account.Salesforce_CSM__r.email,opp.Account.Salesforce_AE__r.email};
                        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                
                if(results[0].success){
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send:' +  results[0].errors[0].message);
                }  
            }
            
        }
    }
    
    global void finish(Database.BatchableContext BC){      
        
    }
    //Calculate Hour between two dates.
    public static Integer getHourDate(DateTime createdDate){
        Long dt1Long = createdDate.getTime();
        Long dt2Long = DateTime.now().getTime();
        Long milliseconds = dt2Long - dt1Long;
        Long seconds = milliseconds / 1000;
        Long minutes = seconds / 60;
        Long hours = minutes / 60;
        
        return Integer.valueOf(hours);
        
    }
}