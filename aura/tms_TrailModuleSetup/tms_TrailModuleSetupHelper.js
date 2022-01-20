({
    hasConfigStep : function(component, moduleId) {
        var action = component.get("c.hasConfigStep");
        action.setParams({ "moduleId":moduleId });
        action.setCallback(this,function(a){
            //get the response state
            var state = a.getState();
            
            //check if result is successfull
            if(state == "SUCCESS"){
                var result = a.getReturnValue();
                //console.info("setting platform job id ", result);
				//component.set("v.platformJobId", result);
                if(result==null) {
                	component.set("v.hasConfigStep", false);
                }
                else {
                	component.set("v.hasConfigStep", true);
                }
            } else if(state == "ERROR"){
                alert("Error in calling server side action");
            }
        });
        //adds the server-side action to the queue        
        $A.enqueueAction(action);
    },
    handleResponse : function(component, response) {
        var THEME_BASE = "slds-notify slds-notify_alert slds-theme_alert-texture slds-theme_";
        
        if(response.startsWith('<html')) {
            component.set("v.showResponse", true);
            component.set("v.response_message", "The service failed authorization. You can contact support by logging a case in our community.");
            component.set("v.response_theme", THEME_BASE+"error");
        } else if (response.startsWith('Steps Execution Started')){
            component.set("v.showResponse", true);
            component.set("v.response_message", $A.get("$Label.c.TMS_MSG_TRAILSETUP_STARTED"));
            component.set("v.response_theme", THEME_BASE+"info");
        }
        var obj = JSON.parse(response);
        if(obj==null)return;
        
        if (obj.isSuccess && obj.isSuccess==true && obj.isFinished==false) {
            component.set("v.showResponse", true);
            component.set("v.response_message", $A.get("$Label.c.TMS_MSG_TRAILSETUP_STARTED"));
            component.set("v.response_theme", THEME_BASE+"info");
        }
        else if (obj.isSuccess && obj.isSuccess==false && obj.isFinished==true) {
            component.set("v.showResponse", true);
            component.set("v.response_theme", THEME_BASE+"error");
            if(obj.error)component.set("v.response_message", obj.error);
        }
	},
    getFrontDoorUrl : function(component, orgId) {
        var action = component.get("c.createFrontDoorRequest");
        action.setParams({
            "orgId": orgId
        });
        
        action.setCallback(this,function(a){
            var state = a.getState();
            if(state == "SUCCESS"){
                var result = a.getReturnValue();
                console.info("JSON Response object received: ", result);
                
                if(result==null) {
                    //handle exception.
                }
                else {
                    try {
                        var obj = JSON.parse(result);
                        console.info("JSON obj: ", obj);
                        if(obj.isFinished==true && obj.isSuccess==true) {
                            if(!obj.frontDoor)alert("We were unable to log you into your org.  Please do so manually.");
                                var urlEvent = $A.get("e.force:navigateToURL");
                                urlEvent.setParams({
                                  "url": obj.frontDoor
                                });
                                urlEvent.fire();
                        }
                        if(obj.error) {
                            alert("Error: "+obj.error);
                        }
                    } 
                    catch (e) {
                        alert("Request to access org was not authorized.");
                    	console.log("Error parsing response.", e);
                    }
                }
            } else if(state == "ERROR"){
                alert("Error in calling server side action");
            }
        });
        //adds the server-side action to the queue        
        $A.enqueueAction(action);
    },
    showButton : function(component, cmpName){
        var cmpTarget = component.find(cmpName);
        $A.util.removeClass(cmpTarget, "slds-hide");
    },
    hideButton : function(component, cmpName) {
        var cmpTarget = component.find(cmpName);
        $A.util.addClass(cmpTarget, "slds-hide");
    },
    getParameterFromUrl : function(paramName) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); // Get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split("&"); //Split by & so that we get the key value pairs separately in a list
        for (var i=0; i<sURLVariables.length; i++) {
            var sParameterName = sURLVariables[i].split("="); //to split the key from the value.
            if (sParameterName[0] === paramName) {
                sParameterName[1] === undefined ? null : sParameterName[1];
                return sParameterName[1];
            }
        }
        console.log("No params were found, potentially due to a URL parsing issue.");
        return null;
    },
    getCopadoJobId : function(component, helper){

        var hasConfigStep = component.get("v.hasConfigStep");
        var intervalId = component.get("v.intervalId");
        if (hasConfigStep == false) {
            window.clearInterval(intervalId);
        }

        var action = component.get("c.getCopadoJobId");
        action.setParams({
            "playgroundId": component.get("v.selectedPlayground"),
            "learningAssignmentId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var THEME_BASE = "slds-notify slds-notify_alert slds-theme_alert-texture slds-theme_";
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!$A.util.isEmpty(result) && !$A.util.isUndefined(result)){
                    let completeCount = 0;
                    let isFailed = false;
                    result.forEach(element => {
                        if (element.Status__c == 'Completed') {
                            completeCount++
                        }
                        if (element.Status__c == 'Failed' && !isFailed) {
                            isFailed = true
                        }
                    });
                    component.set("v.stepExecutions", result);
                    if (completeCount == result.length) {
                        component.set("v.jobInProgress", false);
                        component.set("v.response_theme", THEME_BASE+"success");
                        component.set("v.response_message", $A.get("$Label.c.TMS_MSG_TRAILSETUP_SUCCESS"));

                        helper.showButton(component, "btnOpenPlayground");
                        helper.hideButton(component, "btnClose");
                        helper.hideButton(component, "btnSubmit");

                        window.clearInterval(intervalId);
                    }

                    if(isFailed){
                        component.set("v.isSeedBtnDisable", false);
                        component.set("v.jobInProgress", false);
                        component.set("v.response_theme", THEME_BASE+"error");
                        component.set("v.response_message", $A.get("$Label.c.TMS_MSG_TRAILSETUP_ERROR"));
                    }
                } else {
                    component.set("v.stepExecutions", null);
                    helper.showButton(component, "btnSubmit");
                }
            }
        });
        $A.enqueueAction(action);
    },
    restartStepProcess : function(component, helper, stepId) {
        var action = component.get("c.resetStepExecutionById");
        action.setParams({
            stepId : stepId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                helper.getCopadoJobId(component, helper);
            }
            else if (state === "ERROR") {
                console.log(json.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    }
})