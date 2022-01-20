//This scheduler class will map Renewal QuoteLines with Product and run in every 10 minutes.
global class ScheduleProductinQuoteLines implements Schedulable {
   
    global void execute(SchedulableContext sc) {       
       
        // process each batch of records default size is 200
        Map<string,SBQQ__QuoteLine__c> renewQuoteLineIdAndQuoteLine = new Map<string,SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> updateQuoteLineList = new List<SBQQ__QuoteLine__c>();
        
        List<SBQQ__QuoteLine__c> qtLineList = [SELECT Id, SBQQ__AllowAssetRefund__c,SBQQ__Quote__c,OriginalQuoteLineId2__c, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__ListPrice__c, SBQQ__ProrateMultiplier__c, SBQQ__NetPrice__c, SBQQ__ProratedListPrice__c FROM SBQQ__QuoteLine__c where SBQQ__Product__c = null AND  OriginalQuoteLineId2__c != null];
        IF(Test.isRunningTest()){
            qtLineList = [SELECT Id, SBQQ__AllowAssetRefund__c,SBQQ__Quote__c,OriginalQuoteLineId2__c, SBQQ__ListPrice__c FROM SBQQ__QuoteLine__c where OriginalQuoteLineId2__c != null];
        }
        for(SBQQ__QuoteLine__c quoteLine : qtLineList) {            
            renewQuoteLineIdAndQuoteLine.put(quoteLine.OriginalQuoteLineId2__c,quoteLine);              
        }   
       
        if(!renewQuoteLineIdAndQuoteLine.isEmpty()) {
            for(SBQQ__QuoteLine__c originalQuoteLine : [Select Id, SBQQ__ProrateMultiplier__c,SBQQ__Product__c, SBQQ__Quote__r.SBQQ__FirstSegmentTermEndDate__c,SBQQ__SegmentIndex__c, SBQQ__ListPrice__c from SBQQ__QuoteLine__c where Id IN:renewQuoteLineIdAndQuoteLine.keySet()]) {
                renewQuoteLineIdAndQuoteLine.get(originalQuoteLine.Id).SBQQ__Product__c = originalQuoteLine.SBQQ__Product__c; 
                renewQuoteLineIdAndQuoteLine.get(originalQuoteLine.Id).SBQQ__ProrateMultiplier__c = 12;
                
                renewQuoteLineIdAndQuoteLine.get(originalQuoteLine.Id).SBQQ__AllowAssetRefund__c = true;
                if(renewQuoteLineIdAndQuoteLine.get(originalQuoteLine.Id).SBQQ__ProrateMultiplier__c != null && renewQuoteLineIdAndQuoteLine.get(originalQuoteLine.Id).SBQQ__ListPrice__c != null) {
                    renewQuoteLineIdAndQuoteLine.get(originalQuoteLine.Id).SBQQ__NetPrice__c = (renewQuoteLineIdAndQuoteLine.get(originalQuoteLine.Id).SBQQ__ListPrice__c)*(renewQuoteLineIdAndQuoteLine.get(originalQuoteLine.Id).SBQQ__ProrateMultiplier__c);
                    renewQuoteLineIdAndQuoteLine.get(originalQuoteLine.Id).SBQQ__ProratedListPrice__c = (renewQuoteLineIdAndQuoteLine.get(originalQuoteLine.Id).SBQQ__ListPrice__c)*(renewQuoteLineIdAndQuoteLine.get(originalQuoteLine.Id).SBQQ__ProrateMultiplier__c);
                }
                updateQuoteLineList.add(renewQuoteLineIdAndQuoteLine.get(originalQuoteLine.Id));
            }
        }

        if(!updateQuoteLineList.isEmpty()) {               
            try {           
                update updateQuoteLineList;
            
            } catch(Exception e) {
                System.debug(e);
            }    
        }         
    }  
}