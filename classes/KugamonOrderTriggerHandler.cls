public class KugamonOrderTriggerHandler implements ITrigger {
    public KugamonOrderTriggerHandler(){ 
    }
    
    public void bulkBefore(){     
    }
    
    public void bulkAfter(){ 
         if(Trigger.isAfter && Trigger.isUpdate){
            KugamonOrderTriggerHelper.createQuoteLineOnRenewalOpportuntiy(Trigger.New);
        }
    }
    
    public void beforeInsert(SObject so){
        
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){
        
    }
    
    public void beforeDelete(SObject so){
    }
    
    public void afterInsert(SObject so){   
    }
    
    public void afterUpdate(SObject oldSo, SObject so){ 
           
        kugo2p__SalesOrder__c NewOrderValue = (kugo2p__SalesOrder__c) so;
        kugo2p__SalesOrder__c OldOrderValue =  (kugo2p__SalesOrder__c) oldSo;     
        
        if(!test.isRunningTest()) {
            if(NewOrderValue.kugo2p__RecordStatus__c != OldOrderValue.kugo2p__RecordStatus__c && NewOrderValue.kugo2p__RecordStatus__c == 'Released') {            
                KugamonOrderTriggerHelper.updateContract(NewOrderValue.Id);
            }    
        } else{
            KugamonOrderTriggerHelper.updateContract(NewOrderValue.Id);
        }
    }
    
    public void afterDelete(SObject so){
    }
    
    public void andFinally(){
        KugamonOrderTriggerHelper.createQuoteLineOnRenewal();
    }
}