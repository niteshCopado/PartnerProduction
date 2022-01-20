trigger SetContractToExpiredReplacement on Contract (after insert, after update) {
    
    Set<Contract> toBeActivated = new Set<Contract>();
    Set<Contract> toBeExpired = new Set<Contract>();
    Set<Id> accId = new Set<Id>();
    Set<Id> contractIds = new set<Id>();
    
   if(trigger.isInsert) {  
       for(Contract c: trigger.new){
           if(c.AccountId != null){
                accId.add(c.AccountId);
           }
        }
         
        For(Contract contract: [Select id, EndDate from Contract where AccountId=:accId ORDER BY EndDate DESC LIMIT 1]){
            toBeActivated.add(contract);
        }
        
        System.debug('To be activated');
        
         For(Contract contract: [Select id, EndDate from Contract where AccountId=:accId and Status != 'Expired']){
            toBeExpired.add(contract);
        }
    
        if(toBeExpired.size() > 1){
            toBeExpired.removeAll(toBeActivated);
            for(Contract c: toBeExpired){
                c.Status = 'Expired - Replacement';
            }
            
            List<Contract> listToUpdate = new List<Contract>(toBeExpired);
            update (listToUpdate);
            System.debug('Updated');
        }
       
            
        for(Contract c: trigger.new) {            
           if(c.kuga_sub__RenewalOpportunity__c != null){               
                contractIds.add(c.Id);
           }
        } 
        if(!contractIds.isEmpty()) {
            ContractHelper.UpdateRenewalQuote(contractIds);
        }  
    }   
    else if(trigger.isUpdate) { 
        for(Contract c: trigger.new) {  
           if(c.kuga_sub__RenewalOpportunity__c != null && c.Order_ACV__c != trigger.oldMap.get(c.Id).Order_ACV__c) {               
                contractIds.add(c.Id);
           }
        } 
        if(!contractIds.isEmpty()) {
            ContractHelper.UpdateRenewalQuote(contractIds);
        }  
    }
}