global with sharing class InvokeListingApprovalProcess {
    global with sharing class InvocableVariables {
        @InvocableVariable(label='Listing Id' required=true)
        global Id listingId;
    }
    
    @InvocableMethod(label='Execute Listing Approval Process' description='Execute listing approval process')
    public static List<ApprovalProcessResult> execute(List<InvocableVariables> variables) {
        Listing__c listing = [SELECT Id,CurrencyIsoCode , Reviews__c , 
                                           Rating__c , First_Listed__c , Latest_Release__c , 
                                           Get_It_Now_Action__c 
                                           FROM Listing__c  WHERE Id = :variables[0].listingId];
        
        
        List<ApprovalProcessResult> results= new List<ApprovalProcessResult>();
        String errors = '';
        
        if(Approval.isLocked(variables[0].listingId)){
            errors += 'This is still currently in an Approval Process \n';
        }else{
             errors += validationListingField(listing);
        }
        ApprovalProcessResult result = new ApprovalProcessResult();
        result.ErrorMessage = errors == '' ? null : errors;
        results.add(result);
        return results;
    }
    private static string validationListingField(Listing__c listing){
        string errors = '';

        if (listing.CurrencyIsoCode == null) {
            errors +='CurrencyIsoCode cannot be null \n';
        }
        if (listing.Reviews__c == null) {
            errors += 'Reviews cannot be null \n';
        }
        if (listing.Rating__c == null) {
            errors += 'Rating cannot be null \n';
        }
         if (listing.First_Listed__c == null) {
            errors += 'First Listed cannot be null \n';
        }
         if (listing.Latest_Release__c == null) {
            errors += 'Latest Release cannot be null \n';
        }
         if (listing.Get_It_Now_Action__c == null) {
            errors += 'Get It Now Action cannot be null \n';
        }
        
        return errors;
    }
    
    global class ApprovalProcessResult {
        @InvocableVariable
        global String ErrorMessage;
    }
}