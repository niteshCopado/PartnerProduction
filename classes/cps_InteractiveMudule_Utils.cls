/**
 * Class to be use to create util methods for Interactive Mudule
 */
global without sharing class cps_InteractiveMudule_Utils {
    public enum HttpMethods {GET, POST, PUT}
    public static final String SETTINGS_NAME = 'Default_Values';

    @AuraEnabled
    global static Boolean checkOrgType() {
        Boolean orgType = ([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox);
    
        return orgType;
    }
    
    @AuraEnabled
    global static List<Playground__c> getPlaygroundRecords() {
        User currentUser = [Select Id, ContactId from User where Id = :UserInfo.getUserId() limit 1];
        if(currentUser.contactId==null){ return new List<Playground__c>();}
        String lastUsePlaygroundId = '';
        List<Playground__c> playgrounds =  new List<Playground__c>();

        Map<Id, Playground__c> playgroundMap = new Map<Id, Playground__c>([select Id, Name, Org_Credential__c, Contact__c from Playground__c where Status__c='Activated' and Playground_Configuration__c <> 'Light Configuration' and Contact__c=:currentUser.contactId limit 100]);

        Interactive_Validation_Step_Execution__c ivse = new Interactive_Validation_Step_Execution__c();
        for(Interactive_Validation_Step_Execution__c ivs : [Select Id, Name, Playground__c, LastModifiedDate From Interactive_Validation_Step_Execution__c Where Playground__c IN :playgroundMap.keySet() AND Playground__c <> null Order By LastModifiedDate DESC Limit 1]){
            ivse = ivs;
        }
        
        Step_Execution__c se = new Step_Execution__c();
        for(Step_Execution__c s : [Select Id, Name, Playground__c, LastModifiedDate From Step_Execution__c Where Playground__c IN :playgroundMap.keySet() AND Playground__c <> null Order By LastModifiedDate DESC Limit 1]){
            se = s;
        }

        if(ivse != null && se != null){
            if (ivse.LastModifiedDate > se.LastModifiedDate) {
                lastUsePlaygroundId = ivse.Playground__c;
            } else {
                lastUsePlaygroundId = se.Playground__c;
            }
        } else if (ivse != null) {
            lastUsePlaygroundId = ivse.Playground__c;
        } else if (se != null) {
            lastUsePlaygroundId = se.Playground__c;
        }

        if (lastUsePlaygroundId != null && playgroundMap.containsKey(lastUsePlaygroundId)) {
            playgrounds.add(playgroundMap.get(lastUsePlaygroundId));
        }
        
        for (Id pId : playgroundMap.keySet()) {
            if (pId != lastUsePlaygroundId) {
                playgrounds.add(playgroundMap.get(pId));
            }
        }

        return playgrounds;
    }

    @AuraEnabled
    global static List<Playground_Enviroment__c> getPlaygroundEnv(String playgroundId) {
        List<Playground_Enviroment__c> playgroundEnvs = new List<Playground_Enviroment__c>();

        for(Playground_Enviroment__c pe : [Select Id, Name From Playground_Enviroment__c Where Playground__c = :playgroundId]) {
            playgroundEnvs.add(pe);
        }

        if (!playgroundEnvs.isEmpty()) {
            return playgroundEnvs;
        }
        return null;
    }

    @AuraEnabled
    public static String getFrontDoorUrl(Id orgId) {
        Playground_Enviroment__c playgroundEnviroment = [SELECT Authorization_URL__c, Playground__r.Api_Key__c FROM Playground_Enviroment__c WHERE Id = :orgId LIMIT 1];
        if (playgroundEnviroment != null && playgroundEnviroment.Authorization_URL__c != null) {
            String OrgCredentialId = cps_Helper.getOrgCredentialIdFromAuthorizationUrl(playgroundEnviroment.Authorization_URL__c);
            String apiKeyToOpenEnv = cps_Crypto.decryptString(playgroundEnviroment.Playground__r.Api_Key__c);
            
            return createFrontDoorRequest(OrgCredentialId, apiKeyToOpenEnv);
        }
        return null;
    }

    public static String createFrontDoorRequest(Id OrgCredentialId, String apiKeyToOpenEnv) {
        Playground_Setting__mdt playgroundSetting = [select Copado_Client_Key__c, C1P_Api_Key__c from Playground_Setting__mdt where QualifiedApiName=:cps_Helper.SETTINGS_NAME limit 1];
        if (apiKeyToOpenEnv == null) {
            apiKeyToOpenEnv = playgroundSetting.C1P_Api_Key__c;
        }
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://app-api.copado.com/json/v1/webhook/copadoSession/'+OrgCredentialId+'?api_key='+apiKeyToOpenEnv);
        request.setMethod(HttpMethods.GET.name());
        request.setHeader('X-Client-Key', playgroundSetting.Copado_Client_Key__c);
        
        HttpResponse httpResponse;
        
        try{
            httpResponse = http.send(request);
            system.debug('@@@' + httpResponse.getBody());
            return httpResponse.getBody();
        } catch(Exception e) {
            throw e;
        }
    }

    public static Map<String, Object> parsePayload(String payloadString) {
        if(payloadString==null) return new Map<String, Object>();

        Map<String, Object> payloadObj = new Map<String, Object>();
        try{
            //clean payloadString of carriage returns;
            payloadString = payloadString.replaceAll('\n','');
            payloadObj = (Map<String, Object>) JSON.deserializeUntyped(payloadString);
        }
        catch(Exception e) {
            system.debug(payloadString);
            system.debug('@@@ Error parsing payloadString: '+e.getMessage());
        }
        return payloadObj;
    }
}