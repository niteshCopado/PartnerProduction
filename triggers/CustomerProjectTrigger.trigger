trigger CustomerProjectTrigger on Project__c (after update) {
    // Selecting the UserIds to Assign PS when project become Active
    List<String> projIdsForAddPS = new List<String>();
    List<String> projIdsForRemovePS = new List<String>();
    for(Project__c proj : Trigger.New){
        if(Trigger.oldMap.get(proj.Id).IsActive__c != proj.IsActive__c){
            if(proj.IsActive__c){
                projIdsForAddPS.add(proj.Id);
            }else{
                projIdsForRemovePS.add(proj.Id);
            }
        }
    }
    
    List<Project_Team_Member__c> ptmListToAdd = [SELECT Id, User__c FROM Project_Team_Member__c WHERE Customer_Project__c IN :projIdsForAddPS AND IsActive__c = true AND User__c != null];
    List<Project_Team_Member__c> ptmListToRemove = [SELECT Id, User__c FROM Project_Team_Member__c WHERE Customer_Project__c IN :projIdsForRemovePS AND IsActive__c = true AND User__c != null];
    
    if(!ptmListToAdd.isEmpty()){
        List<String> userIdsForAddPS = new List<String>();
        for(Project_Team_Member__c ptm : ptmListToAdd){
            userIdsForAddPS.add(ptm.User__c);
        }
        CustomerProjectAndPTMTriggerHelper.assignPSToUsers(userIdsForAddPS);
    }
    
    // Selecting the UserIds to Assign PS when project become InActive
    if(!ptmListToRemove.isEmpty()){
        List<String> userIdsForRemovePS = new List<String>();
        for(Project_Team_Member__c ptm : ptmListToRemove){
            userIdsForRemovePS.add(ptm.User__c);
        }
        
        List<Project_Team_Member__c> ptmList = [SELECT Id, User__c FROM Project_Team_Member__c WHERE User__c IN :userIdsForRemovePS AND IsActive__c = true];
        
        Map<String, List<Project_Team_Member__c>> ptmUserMap = new Map<String, List<Project_Team_Member__c>>();
        List<Project_Team_Member__c> ptmListTemp;
        for(Project_Team_Member__c ptm : ptmList){
            ptmListTemp = ptmUserMap.get(ptm.User__c) != null ? ptmUserMap.get(ptm.User__c) : new List<Project_Team_Member__c>();
            ptmListTemp.add(ptm);
            ptmUserMap.put(ptm.User__c, ptmListTemp);
        }
        
        List<String> usrIds = new List<String>();
        for(String str : ptmUserMap.keySet()){
            if(ptmUserMap.get(str).size() == 1){
                usrIds.add(str);
            }
        }
        
        CustomerProjectAndPTMTriggerHelper.removePSFromUsers(usrIds);
    }
}