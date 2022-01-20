public class KugamonOrderTriggerHelper {
    public static List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
    public static List<SBQQ__QuoteLine__c> updateListOfRenewalQuote = new List<SBQQ__QuoteLine__c>();
    public static Map<Id,SBQQ__QuoteLine__c> quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
    public static Map<Id,SBQQ__QuoteLine__c> quoteLineListMap = new Map<Id,SBQQ__QuoteLine__c>();
    //By using this method create new line and subscription for renewal opportunity
    public static void createQuoteLineOnRenewalOpportuntiy(List<kugo2p__SalesOrder__c> newOrderList){
        Set<String> oppIdSet = new Set<String>();         
        Map<String,SBQQ__Quote__c> opptyQuoteMap = new Map<String,SBQQ__Quote__c>();
        Map<String,String> contractRenewalOppMap = new Map<String,String>();
       
        Id expRecordTypeId = Schema.SObjectType.kugo2p__SalesOrder__c.getRecordTypeInfosByName().get('Expansion').getRecordTypeId();
       
        for(kugo2p__SalesOrder__c orderObj : newOrderList){
            if(orderObj.RecordTypeId == expRecordTypeId && orderObj.kugo2p__RecordStatus__c == 'Released'){
                oppIdSet.add(orderObj.kugo2p__Opportunity__c);
                oppIdSet.add(orderObj.kuga_sub__RenewalOpportunity__c);                
            }
        }        
        if(oppIdSet.Size()>0 && oppIdSet != null){

        
            for(SBQQ__Quote__c quoteObj :[Select Id,SBQQ__Opportunity2__c,(SELECT SBQQ__Quote__c,SBQQ__Product__r.name,SBQQ__Product__c,SBQQ__Quantity__c,SBQQ__PricingMethod__c,
                                                                        PS_Is_Licence__c,SBQQ__Renewal__c,SBQQ__ProrateMultiplier__c,SBQQ__SegmentIndex__c,SBQQ__ListPrice__c,
                                                                        Net_Unit_Price__c,SBQQ__BlockPrice__c,SBQQ__ContractedPrice__c,SBQQ__CustomerPrice__c,SBQQ__Dimension__c,
                                                                        SBQQ__GenerateContractedPrice__c,SBQQ__MaximumPrice__c,SBQQ__MinimumPrice__c,SBQQ__NetPrice__c,
                                                                        SBQQ__OriginalPrice__c,SBQQ__PartnerPrice__c,SBQQ__PreviousSegmentPrice__c,SBQQ__PricebookEntryId__c,
                                                                        SBQQ__PriceEditable__c,SBQQ__ProratedListPrice__c,SBQQ__ProratedPrice__c,SBQQ__RegularPrice__c,
                                                                        SBQQ__SpecialPrice__c,SBQQ__SpecialPriceDescription__c,SBQQ__SpecialPriceType__c,SBQQ__SubscriptionTargetPrice__c,
                                                                        SBQQ__UnproratedNetPrice__c,SBQQ__SubscriptionPricing__c,SBQQ__SubscriptionScope__c,SBQQ__DefaultSubscriptionTerm__c,SBQQ__RenewedSubscription__c,
                                                                        SBQQ__SubscriptionTerm__c,SBQQ__Discount__c,SBQQ__DiscountSchedule__c,SBQQ__DiscountTier__c,SBQQ__TermDiscountSchedule__c,
                                                                        SBQQ__TermDiscountTier__c,SBQQ__AllowAssetRefund__c,SBQQ__BillingFrequency__c,
                                                                        CurrencyIsoCode,SBQQ__EndDate__c,SBQQ__SubscriptionBase__c,SBQQ__SubscriptionCategory__c,
                                                                        SBQQ__ProductSubscriptionType__c,SBQQ__SegmentKey__c,SBQQ__SegmentLabel__c,
                                                                        SBQQ__SubscriptionType__c,SBQQ__Uplift__c ,SBQQ__StartDate__c,SBQQ__UpliftAmount__c FROM SBQQ__LineItems__r) From SBQQ__Quote__c
                                        Where SBQQ__Primary__c = true AND SBQQ__Opportunity2__c IN:oppIdSet ]){
                                            
                                            opptyQuoteMap.put(quoteObj.SBQQ__Opportunity2__c,quoteObj);                       
                                        }
        }
        for(kugo2p__SalesOrder__c orderObj2 : newOrderList ){
            if(orderObj2.RecordTypeId == expRecordTypeId){
                List<SBQQ__QuoteLine__c> listOfExpansionQuote = new List<SBQQ__QuoteLine__c>();
                List<SBQQ__QuoteLine__c> listOfRenewalQuote = new List<SBQQ__QuoteLine__c>();
               
                if(opptyQuoteMap.containskey(orderObj2.kuga_sub__RenewalOpportunity__c)){
                    listOfRenewalQuote = opptyQuoteMap.get(orderObj2.kuga_sub__RenewalOpportunity__c).SBQQ__LineItems__r;                    
                }
                if(opptyQuoteMap.containskey(orderObj2.kugo2p__Opportunity__c)){
                    listOfExpansionQuote = opptyQuoteMap.get(orderObj2.kugo2p__Opportunity__c).SBQQ__LineItems__r;
                } 
                        
                if(listOfRenewalQuote.Size()>0 && listOfExpansionQuote.Size() >0){
                    for(SBQQ__QuoteLine__c lineObj :listOfExpansionQuote){
                        Boolean isMatch = false;
                        for(SBQQ__QuoteLine__c lineObj2 :listOfRenewalQuote){
                            if(lineObj.SBQQ__Product__c == lineObj2.SBQQ__Product__c){
                                lineObj2.SBQQ__Quantity__c = lineObj.SBQQ__Quantity__c;
                                isMatch = true;
                                updateListOfRenewalQuote.add(lineObj2);
                                quoteLineMap.putAll(updateListOfRenewalQuote);
                            }
                        }                       
                        if(!isMatch){
                            SBQQ__QuoteLine__c quoteLineObj = lineObj.Clone();    
                            quoteLineObj.SBQQ__Quote__c = opptyQuoteMap.get(orderObj2.kuga_sub__RenewalOpportunity__c).id;
                            quoteLineList.add(quoteLineObj);
                            //system.debug('#Step1'+ quoteLineList);
                            //quoteLineListMap.putAll(quoteLineList);
                        } 
                    }
                }
            }
        } 
        
            
    }

    public static void createQuoteLineOnRenewal(){
       System.debug('#####'+quoteLineList );
       if(!quoteLineList.isEmpty()){    
            if(!Test.isRunningtest()) {        
                Upsert quoteLineList;  
            }         
        }       
        if(!quoteLineMap.isEmpty()){   
            system.debug('@@@@@'+quoteLineMap );
            Update quoteLineMap.values();             
        }  
    }
    
    @future
    //This method is used to update the Contract when an Order gets Released.
    public static void updateContract(Id orderId){
        Map<Id, kugo2p__SalesOrder__c> orderIdAndOrder = new Map<Id,kugo2p__SalesOrder__c> ([Select Id, kugo2p__Opportunity__c, Current_ARR__c, Non_Standard_ACV__c,kugo2p__RecordStatus__c,RecordTypeId,
                                    kugo2p__Opportunity__r.ACV__c, kugo2p__Opportunity__r.TCV__c, kuga_sub__ContractNumber__c, 
                                    kuga_sub__ContractNumber__r.Order_ACV__c, kuga_sub__ContractNumber__r.Order_1st_yr_ARR__c, 
                                    kuga_sub__ContractNumber__r.Order_Current_ARR__c, kuga_sub__ContractNumber__r.Non_Standard_ACV__c, 
                                    Quote_ACV__c, X1st_yr_ARR__c
                                    from kugo2p__SalesOrder__c where Id=:orderId]); 
     
        Id newRecTypeId = Schema.SObjectType.kugo2p__SalesOrder__c.getRecordTypeInfosByName().get('New').getRecordTypeId();
        Id renewalRecTypeId = Schema.SObjectType.kugo2p__SalesOrder__c.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        Id expansionRecTypeId = Schema.SObjectType.kugo2p__SalesOrder__c.getRecordTypeInfosByName().get('Expansion').getRecordTypeId();
      
        List<Contract> updateList = new List<Contract>();
        List<Opportunity> updateOpptyList = new List<Opportunity>();        
        
        if(orderIdAndOrder != null && orderIdAndOrder.size()>0 && orderIdAndOrder.containsKey(orderId) && orderIdAndOrder.get(orderId).kugo2p__RecordStatus__c == 'Released' && orderIdAndOrder.get(orderId).kuga_sub__ContractNumber__c != null && orderIdAndOrder.get(orderId).RecordTypeId == newRecTypeId) {
          
            Contract cont = new Contract(Id=orderIdAndOrder.get(orderId).kuga_sub__ContractNumber__c);
            //cont.Opportunity__c = orderIdAndOrder.get(orderId).kugo2p__Opportunity__c;            
            cont.ACV_New__c = orderIdAndOrder.get(orderId).kugo2p__Opportunity__r.ACV__c;
            cont.TCV_New__c = orderIdAndOrder.get(orderId).kugo2p__Opportunity__r.TCV__c;
            cont.Order_ACV__c = orderIdAndOrder.get(orderId).Quote_ACV__c;
            cont.Order_1st_yr_ARR__c = orderIdAndOrder.get(orderId).X1st_yr_ARR__c;
            cont.Order_Current_ARR__c = orderIdAndOrder.get(orderId).Current_ARR__c;
            cont.Non_Standard_ACV__c = orderIdAndOrder.get(orderId).Non_Standard_ACV__c;            
            updateList.add(cont);            
            Opportunity oppObj = new Opportunity(Id=orderIdAndOrder.get(orderId).kugo2p__Opportunity__c);
            oppObj.ContractId = orderIdAndOrder.get(orderId).kuga_sub__ContractNumber__c;
            updateOpptyList.add(oppObj);
        }
        
        else if(orderIdAndOrder != null && orderIdAndOrder.size()>0 && orderIdAndOrder.containsKey(orderId) && orderIdAndOrder.get(orderId).kugo2p__RecordStatus__c == 'Released' && orderIdAndOrder.get(orderId).kuga_sub__ContractNumber__c != null && orderIdAndOrder.get(orderId).RecordTypeId == renewalRecTypeId) {
            
            Contract cont = new Contract(Id=orderIdAndOrder.get(orderId).kuga_sub__ContractNumber__c);
            //cont.Opportunity__c = orderIdAndOrder.get(orderId).kugo2p__Opportunity__c;
            cont.ACV_New__c = orderIdAndOrder.get(orderId).kugo2p__Opportunity__r.ACV__c;
            cont.TCV_New__c = orderIdAndOrder.get(orderId).kugo2p__Opportunity__r.TCV__c;
            cont.Order_ACV__c = orderIdAndOrder.get(orderId).Quote_ACV__c;
            cont.Order_1st_yr_ARR__c = orderIdAndOrder.get(orderId).X1st_yr_ARR__c;
            cont.Order_Current_ARR__c = orderIdAndOrder.get(orderId).Current_ARR__c;
            cont.Non_Standard_ACV__c = orderIdAndOrder.get(orderId).Non_Standard_ACV__c;
            updateList.add(cont);        
        }
        else if(orderIdAndOrder != null && orderIdAndOrder.size()>0 && orderIdAndOrder.containsKey(orderId) && orderIdAndOrder.get(orderId).kugo2p__RecordStatus__c == 'Released' && orderIdAndOrder.get(orderId).kuga_sub__ContractNumber__c != null && orderIdAndOrder.get(orderId).RecordTypeId == expansionRecTypeId) {
            decimal orderACV = 0.0;
            if(orderIdAndOrder.get(orderId).kuga_sub__ContractNumber__r.Order_ACV__c != null){
                orderACV = orderIdAndOrder.get(orderId).kuga_sub__ContractNumber__r.Order_ACV__c;
            }
            if(orderIdAndOrder.get(orderId).Quote_ACV__c != null){                
                orderACV += orderIdAndOrder.get(orderId).Quote_ACV__c;                
            }
            decimal orderIstYrARR = 0.0;
            if(orderIdAndOrder.get(orderId).kuga_sub__ContractNumber__r.Order_1st_yr_ARR__c != null){
                orderIstYrARR = orderIdAndOrder.get(orderId).kuga_sub__ContractNumber__r.Order_1st_yr_ARR__c;
            }
            if(orderIdAndOrder.get(orderId).X1st_yr_ARR__c != null){                
                orderIstYrARR += orderIdAndOrder.get(orderId).X1st_yr_ARR__c;                
            }
            decimal orderCurrentARR = 0.0;
            if(orderIdAndOrder.get(orderId).kuga_sub__ContractNumber__r.Order_Current_ARR__c != null){
                orderCurrentARR = orderIdAndOrder.get(orderId).kuga_sub__ContractNumber__r.Order_Current_ARR__c;
            }
            if(orderIdAndOrder.get(orderId).Current_ARR__c != null){                
                orderCurrentARR += orderIdAndOrder.get(orderId).Current_ARR__c;                
            }
            decimal orderNonStdACV = 0.0;
            if(orderIdAndOrder.get(orderId).kuga_sub__ContractNumber__r.Non_Standard_ACV__c != null){
                orderNonStdACV = orderIdAndOrder.get(orderId).kuga_sub__ContractNumber__r.Non_Standard_ACV__c;
            }
            if(orderIdAndOrder.get(orderId).Non_Standard_ACV__c != null){                
                orderNonStdACV += orderIdAndOrder.get(orderId).Non_Standard_ACV__c;                
            }
            Contract cont = new Contract(Id=orderIdAndOrder.get(orderId).kuga_sub__ContractNumber__c);            
            cont.Order_ACV__c = orderACV; 
            cont.Order_1st_yr_ARR__c = orderIstYrARR; 
            cont.Order_Current_ARR__c = orderCurrentARR; 
            cont.Non_Standard_ACV__c = orderNonStdACV;             
            updateList.add(cont);
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