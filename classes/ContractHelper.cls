//This class is called from SetContractToExpiredReplacement trigger
public class ContractHelper {

     //This method updates Renewal Quote and Renewal opportunity's Renewal ACV field from Contract's Order ACV field.
    public static void UpdateRenewalQuote(set<Id> contractIds) { 
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        List<SBQQ__Quote__c> updateList = new List<SBQQ__Quote__c>();
        List<Opportunity> updateOpptyList = new List<Opportunity>();
        
        for(Contract con : [Select Id, Order_ACV__c, kuga_sub__RenewalOpportunity__c, kuga_sub__RenewalOpportunity__r.SBQQ__PrimaryQuote__c, 
                                    kuga_sub__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.Renewal_ACV__c, kuga_sub__RenewalOpportunity__r.isClosed,
                                    kuga_sub__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.ACV__c,
                                    kuga_sub__RenewalOpportunity__r.Renewal_ACV__c, 
                                    kuga_sub__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Status__c
                                    from Contract where Id IN: contractIds AND
                                    kuga_sub__RenewalOpportunity__r.RecordTypeId=:recordTypeId AND
                                    kuga_sub__RenewalOpportunity__r.SBQQ__PrimaryQuote__c != null]) {            
          
              if(con.Order_ACV__c != null) {                   
                  if(con.kuga_sub__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Status__c == 'Draft') {
                      SBQQ__Quote__c quote = new SBQQ__Quote__c(Id=con.kuga_sub__RenewalOpportunity__r.SBQQ__PrimaryQuote__c);                 
                      quote.Renewal_ACV__c = con.Order_ACV__c;      
                      updateList.add(quote);  
                      if(con.kuga_sub__RenewalOpportunity__r.isClosed == false) {                  
                          Opportunity opp = new Opportunity(Id=con.kuga_sub__RenewalOpportunity__c);
                          opp.Renewal_ACV__c = con.Order_ACV__c; 
                          //system.debug('****************'+opp.SBQQ__PrimaryQuote__r.ACV__c+opp.Renewal_ACV__c+opp.Quote_ACV__c);
                          /*if(opp.SBQQ__PrimaryQuote__r.ACV__c != null) {
                              opp.Incremental_ACV__c = opp.SBQQ__PrimaryQuote__r.ACV__c - opp.Renewal_ACV__c; 
                          } else {
                              opp.Incremental_ACV__c = 0 - opp.Renewal_ACV__c; 
                          }  */                           
                          updateOpptyList.add(opp);
                      } 
                  }              
              }                         
        }        
        if(updateList.size()>0 && !updateList.isEmpty()) {
             try {           
                update updateList;                    
             } catch(Exception e) {
                    System.debug(e);
             }               
        }  
        
        if(updateOpptyList.size()>0 && !updateOpptyList.isEmpty()) {
             try {           
                update updateOpptyList;                    
             } catch(Exception e) {
                    System.debug(e);
             }               
        }      
    }
}