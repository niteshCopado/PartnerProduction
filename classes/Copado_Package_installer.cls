public class Copado_Package_installer{
    @AuraEnabled
    public static List<copado__Release__c> GetAllReleaseRecords(){
        RETURN [SELECT 
                Id, Name, copado__Planned_Date__c, copado__Description__c, copado__Project__c, copado__Status__c, copado__Base_Branch__c, 
                Visible_in_Community__c, copado__Version__c, Installation_Link_in_Sandbox__c, Installation_Link_in_Production__c, Documentation_Release_Notes__c 
                FROM 
                copado__Release__c 
                WHERE 
                Visible_in_Community__c = TRUE AND 
                copado__Planned_Date__c !=NULL AND 
                copado__Status__c = 'Released' 
                ORDER BY copado__Planned_Date__c DESC
               ];
    }
}