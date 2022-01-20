trigger CustomerProjectTeamMemberTrigger on Project_Team_Member__c (before insert, before update, after insert, after update) {
    if(Trigger.isAfter){
        // Selecting the UserIds to Assign PS
        List<Project_Team_Member__c> allPTMListWithActiveProject = [SELECT Id, User__c, IsActive__c, Customer_Project__c, Customer_Project__r.IsActive__c FROM Project_Team_Member__c WHERE Id IN :Trigger.New
                                    AND Customer_Project__r.IsActive__c = true AND User__c != null AND IsActive__c = true];
        List<String> userIdsForAddPS = new List<String>();
        for(Project_Team_Member__c ptm : allPTMListWithActiveProject){
            userIdsForAddPS.add(ptm.User__c);
        }
        CustomerProjectAndPTMTriggerHelper.assignPSToUsers(userIdsForAddPS);
        
        // Selecting the UserIds to remove PS
        if(Trigger.isUpdate){
            List<String> userIdsForRemovePS = new List<String>();
            for(Project_Team_Member__c ptm : Trigger.old){
                if(ptm.User__c != null && Trigger.newMap.get(ptm.Id).User__c != ptm.User__c){
                    userIdsForRemovePS.add(ptm.User__c);
                }
                
                if(Trigger.newMap.get(ptm.Id).IsActive__c == false && Trigger.newMap.get(ptm.Id).IsActive__c != ptm.IsActive__c){
                    userIdsForRemovePS.add(ptm.User__c);
                }
            }
            CustomerProjectAndPTMTriggerHelper.removePSFromUsers(userIdsForRemovePS);
        }
    }
    
    if(Trigger.isBefore){
        // Based on the Selected Contact Assigning the Related Community User on the record. If dont found any user throw an error.
        List<Project_Team_Member__c> allPTMList = [SELECT Id, Contact__c, Customer_Project__c FROM Project_Team_Member__c];
        List<String> allTeamMembers = new List<String>();
        for(Project_Team_Member__c mem : allPTMList){
            allTeamMembers.add(mem.Customer_Project__c+'-'+mem.Contact__c);
        }

        List<String> conIds = new List<String>();
        for(Project_Team_Member__c ptm : Trigger.New){
            if(Trigger.IsInsert){
                if(allTeamMembers.contains(ptm.Customer_Project__c+'-'+ptm.Contact__c)){
                    ptm.addError('User Already Exist with Same User.');
                }
            }else if(Trigger.IsUpdate){
                if(Trigger.oldMap.get(ptm.Id).Contact__c != ptm.Contact__c && allTeamMembers.contains(ptm.Customer_Project__c+'-'+ptm.Contact__c)){
                    ptm.addError('User Already Exist with Same User.');
                }
            }
            conIds.add(ptm.Contact__c);
        }
        
        //Based on assigned user fetching the profile Image URL
        List<User> usersList = [SELECT Id, ContactId, SmallPhotoUrl FROM User WHERE ContactId IN :conIds];
        Map<String, String> conUserMap = new Map<String, String>();
        Map<String, String> conUserImageMap = new Map<String, String>();
        for(User usr : usersList){
            conUserMap.put(usr.ContactId, usr.Id);
            conUserImageMap.put(usr.ContactId, usr.SmallPhotoUrl);
        }
        
        for(Project_Team_Member__c ptm : Trigger.New){
            ptm.User__c = conUserMap.get(ptm.Contact__c) != null ? conUserMap.get(ptm.Contact__c) : null;
            
            String imgUrl = '/success/profilephoto/005/T';
            if(conUserImageMap.get(ptm.Contact__c) != null){
                String fullUrl = conUserImageMap.get(ptm.Contact__c);
                fullUrl = fullUrl.replace('https://', '');
                fullUrl = fullUrl.replace('/success', '');
                List<String> urlArray = fullUrl.split('/');
                urlArray[0] = '/success';
                imgUrl = String.join(urlArray, '/');
            }
            ptm.Profile_Pic_URL__c = imgUrl;
            
            if(ptm.Is_Super_User__c){
                ptm.Manage_Team__c = true;
                ptm.Log_Case__c = true;
                ptm.View_Case_Report__c = true;
                ptm.View_Certification_Report__c = true;
            }
        }
    }
}