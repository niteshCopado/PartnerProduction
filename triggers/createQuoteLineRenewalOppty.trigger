trigger createQuoteLineRenewalOppty on SBQQ__Quote__c (after insert, after update) {
    
    if(trigger.isInsert) {
        set<Id> opptyId = new set<Id>();    
        for(SBQQ__Quote__c quote : trigger.new) {    
            if(quote.SBQQ__Opportunity2__c != null && quote.Is_Not_Clone_Quote__c == true && quote.SBQQ__Type__c == 'Renewal') {                       
                opptyId.add(quote.SBQQ__Opportunity2__c);
            }           
        }    
        if(!opptyId.isEmpty()) {
            RenewalOpportunityHelper.RenewalOpportunityDetails(opptyId,trigger.newMap.keyset()); 
        }  
    }
    else if(trigger.isUpdate) {
        for(SBQQ__Quote__c quote : trigger.new) {    
            if(quote.SBQQ__Primary__c == true && quote.SBQQ__Opportunity2__c != null && quote.SBQQ__Type__c == 'Renewal' && quote.Renewal_ACV__c != null && quote.SBQQ__Status__c == 'Draft' && quote.SBQQ__Status__c != trigger.oldMap.get(quote.Id).SBQQ__Status__c) {                       
                RenewalOpportunityHelper.updateRenewalACVOnOpp(trigger.new); 
            }
        }   
    }    
}