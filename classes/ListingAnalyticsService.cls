/**
 * This apex class is the utility class for the Listing Analytics Service.
 * Author: Philipp Rackwitz
 * Date: 2020-01-19
 * Version: 1
 */
public without sharing class ListingAnalyticsService {
    /**
     * publishListingEvent description
     * @param  dt         DateTime string that is created in the LWC componet.
     * @param  userId     User ID is derived from the community user that is logged in.
     * @param  action     An action can be a Click, Page View, Install, Download
     * @param  action2    This column represents the details of the click, install location, download name.
     * @param  listingId  listing record Id
     * @param  docId      document Id being downloaded
     * @param  pageSource Page source (reserved for future use)
     */
    @AuraEnabled
    public static void publishListingEvent(String dt, String userId, String action, String action2, String listingId, String docId, String pageSource) {
        
        system.debug('Received value: '+dt);
        DateTime dtvalue = DateTime.valueOf(dt);

        Listing_Analytics_Event__e analyticsEvent = new Listing_Analytics_Event__e();
        analyticsEvent.DateTime__c = dtvalue;
        analyticsEvent.User_ID__c = userId;
        analyticsEvent.Action__c = action;
        analyticsEvent.Action2__c = action2;
        analyticsEvent.Listing_ID__c = listingId;
        analyticsEvent.Document_ID__c = docId;
        analyticsEvent.Page_Source__c = pageSource;

        Database.SaveResult result = EventBus.publish(analyticsEvent);
        system.debug('Publishing Result: '+result.isSuccess());
    }

    /**
     * This invocable method is called by the flow, "Capture_Listing_Analytics_Events_and_Insert_as_Big_Object_Records".
     * It creates the Listing_Analytics__c records. The design has chosen to deliniate the platform events from the Analytics via the Platform event 
     * for security puproses as well as performance in the community.
     * @param  inputs The Analytics event triggered from the platfrom, captured by the flow and passed into this apex class.
     */
    @InvocableMethod(label='Insert Analytics Record.' description='Listing Analytics Event data is added to the Listing Analytics Record.')
    public static void insertAnalyticsRecord (List<sObject> inputs) {
        
        List<Listing_Analytics_Event__e> evts = (List<Listing_Analytics_Event__e>)inputs;
        List<Listing_Analytics__c> insertables = new List<Listing_Analytics__c>();

        for (Listing_Analytics_Event__e e : evts) {
            
            Listing_Analytics__c bo = new Listing_Analytics__c();
            bo.DateTime__c = e.DateTime__c;
            bo.User__c = e.User_ID__c;
            bo.Action__c = e.Action__c;
            bo.Action2__c = e.Action2__c;
            bo.Listing__c = e.Listing_ID__c;
            bo.Document_ID__c = e.Document_ID__c;
            bo.Page_Source__c = e.Page_Source__c;
            bo.External_ID__c = String.valueOf(e.DateTime__c)+'-'+e.User_ID__c+'-'+e.Action__c;
            insertables.add(bo);
        }
        insert insertables;
    }
}