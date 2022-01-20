/**
 * Helper class for Project & Project Team Member Triggers
 */
public class CustomerProjectAndPTMTriggerHelper {
    /**
	 * Method to Assign Customer_Project_Access_On_Community PS to the specific users
	 */
    @future
    public static void assignPSToUsers(List<String> userIdsForAddPS){
        PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Customer_Project_Access_On_Community'];
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        for(String uId : userIdsForAddPS){
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = uId;
            psa.PermissionSetId = ps.Id;
            psaList.add(psa);
        }
        database.insert(psaList, false);
    }
    
    /**
	 * Method to Remove Customer_Project_Access_On_Community PS from the specific users
	 */
    @future
    public static void removePSFromUsers(List<String> userIdsForRemovePS){
        PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Customer_Project_Access_On_Community'];
        delete [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId IN :userIdsForRemovePS AND PermissionSetId = :ps.Id];
    }
}