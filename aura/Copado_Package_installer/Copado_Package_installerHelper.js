({
	GetAllRelease : function(component, event, helper){
        var action = component.get("c.GetAllReleaseRecords");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                var APEX_Response = response.getReturnValue();
                APEX_Response.forEach(function(record){
                    
                    if(!record.hasOwnProperty("Documentation_Release_Notes__c")){
                        record.isDisabled = true;
                        record.Documentation_Release_Notes__c = 'comming soon';
                        record.Release_Note_text = 'Release Notes will be available soon';
                    }else{
                        record.isDisabled = false;
                        record.Release_Note_text =  'Release Notes';
                    }
                });
                component.set("v.TableData",APEX_Response);
                if(APEX_Response.length>0){
                    component.set("v.LatestReleaseRecord",APEX_Response[0]);    
                }
            }
            else{
                console.log('Apex error:: '+JSON.stringify(response.getError()));
            }
        });       
        $A.enqueueAction(action);
    },
})