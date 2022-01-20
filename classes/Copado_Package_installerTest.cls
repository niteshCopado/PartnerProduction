@isTest
public class Copado_Package_installerTest {

    static testMethod void test_GetAllReleaseRecords(){
        copado__Release__c Release = new copado__Release__c();
        Release.Visible_in_Community__c=true;
        Release.copado__Description__c ='Test Released';
        Release.copado__Version__c ='1.0';
        Release.Installation_Link_in_Sandbox__c ='https://test.salesforce.com/';
        Release.Installation_Link_in_Production__c ='https://login.salesforce.com/';
        Release.Documentation_Release_Notes__c ='Test Released Note';        
        Release.copado__Planned_Date__c = system.today();
        Release.copado__Status__c = 'Released';
        Insert Release;
        Copado_Package_installer.GetAllReleaseRecords();
    } 
}