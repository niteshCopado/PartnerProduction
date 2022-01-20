//This scheduler class will uncheck the 'Is Not Clone Quote' field on Renewal Quote.
global class ScheduleUpdateRenewalQuoteField implements Schedulable {
   
    global void execute(SchedulableContext sc) {     
        
        List<SBQQ__Quote__c> updateQuoteList = new List<SBQQ__Quote__c>(); 
       
        // process each batch of records default size is 200
        List<SBQQ__Quote__c> quoteList = [SELECT Id from SBQQ__Quote__c where SBQQ__Type__c='Renewal' AND SBQQ__Opportunity2__c != null AND Is_Not_Clone_Quote__c = true];      
        
        for(SBQQ__Quote__c quote : quoteList) {            
            quote.Is_Not_Clone_Quote__c = false;  
            updateQuoteList.add(quote);             
        }     
        
        if(!updateQuoteList.isEmpty()) {               
            try {           
                update updateQuoteList ;
            
            } catch(Exception e) {
                System.debug(e);
            }    
        }         
    }  
}