/**
 * This is the test class for ListingAnalyticsService.
 * Author: Philipp Rackwitz
 * Date: 2021-01-21
 * Version 1:
 */
@isTest
public with sharing class ListingAnalyticsServiceTest {

    /**
     * This test covers the Flow also that we are publishing an event and asserting that a Listing Analytics record was created.
     * The Platform Event is created via usage of the community where the LWC "Listing Analytics Service" component sends data to this ListingAnalyticsService Apex Class.
     * The apex class then publishes the platform event that is picked up by the flow which creates the custom object record.
     */
    static testMethod void test_publishListingEvent() {
        
        User testUser = [select Id from User where IsActive=true and UserType='CspLitePortal' limit 1];
        String dateStringFromCommunity = '2020-01-19 18:18:18';
        String action = 'Page View';
        String action2 = null;
        Listing_Profile__c testProfile = createProfile('Copado, Inc.');
        Listing__c testListing = createListing('Copado Templates', testProfile.Id);
        String documentId = 'Some doc id';
        String pageSource = 'Search Results';

        Test.startTest();

        ListingAnalyticsService.publishListingEvent(dateStringFromCommunity, testUser.Id, action, action2, testListing.Id, documentId, pageSource);
        Test.getEventBus().deliver();
        
        Test.stopTest();

        //Check that the event was published.
        EventBusSubscriber[] subscribers = getSubscribers('Listing_Analytics_Event__e');
        system.assertEquals(1, subscribers.size());

        //Check that the record was created via the flow.
        String externalId = dateStringFromCommunity+'-'+testUser.Id+'-'+action;
        Listing_Analytics__c result = getRecord(externalId);
        system.assert(result!=null);
        system.assertEquals(testUser.Id, result.User__c);
        system.assertEquals(action, result.Action__c);
        system.assertEquals(action2, result.Action2__c);
        system.assertEquals(testListing.Id, result.Listing__c);
        system.assertEquals(documentId, result.Document_ID__c);
        system.assertEquals(pageSource, result.Page_Source__c);
    }

    static testMethod void validPlatforEventInputCreatingRecord() {
        
        User testUser = [select Id from User where IsActive=true and UserType='CspLitePortal' limit 1];
        String dateStringFromCommunity = '2020-01-19 18:18:19';
        String action = 'Page View';
        String action2 = null;
        Listing_Profile__c testProfile = createProfile('Copado, Inc.');
        Listing__c testListing = createListing('Copado Templates', testProfile.Id);
        String documentId = 'Some doc id';
        String pageSource = 'Search Results';

        Listing_Analytics_Event__e evt = new Listing_Analytics_Event__e();
        evt.DateTime__c = DateTime.valueOf(dateStringFromCommunity);
        evt.User_ID__c = testUser.Id;
        evt.Action__c = action;
        evt.Action2__c = action2;
        evt.Listing_ID__c = testListing.Id;
        evt.Document_ID__c = documentId;
        evt.Page_Source__c = pageSource;
        List<Listing_Analytics_Event__e> evts = new List<Listing_Analytics_Event__e>();
        evts.add(evt);

        Test.startTest();
        ListingAnalyticsService.insertAnalyticsRecord(evts);
        Test.stopTest();

        String externalId = dateStringFromCommunity+'-'+testUser.Id+'-'+action;
        Listing_Analytics__c result = getRecord(externalId);
        system.assert(result!=null);
        system.assertEquals(testUser.Id, result.User__c);
        system.assertEquals(action, result.Action__c);
        system.assertEquals(action2, result.Action2__c);
        system.assertEquals(testListing.Id, result.Listing__c);
        system.assertEquals(documentId, result.Document_ID__c);
        system.assertEquals(pageSource, result.Page_Source__c);
    }

    //Private methos for this test class.
    private static EventBusSubscriber[] getSubscribers(String topicName) {
        return [select Name, Type, Position, Retries, LastError from EventBusSubscriber where Topic=:topicName];
    }
    private static Listing_Analytics__c getRecord(String externalId) {
        return [select Id, Action__c, Action2__c, DateTime__c, Document_ID__c, External_ID__c, Listing__c, Page_Source__c, User__c 
            from Listing_Analytics__c where External_ID__c=:externalId limit 1];
    }
    private static Listing_Profile__c createProfile(String name) {
        Listing_Profile__c lp = new Listing_Profile__c(Name=name);
        insert lp;
        return lp;
    }
    private static Listing__c createListing(String name, Id profileId) {
        Listing__c l = new Listing__c(Name=name, Listing_Profile__c=profileId);
        insert l;
        return l;
    }
}