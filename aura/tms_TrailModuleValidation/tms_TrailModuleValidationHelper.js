({
    hasIMValidationConfigStep : function(component, moduleId) {
        var action = component.get("c.hasIMValidationConfigStep");
        action.setParams({ "moduleId":moduleId });
        action.setCallback(this,function(a){
            //get the response state
            var state = a.getState();
            
            //check if result is successfull
            if(state == "SUCCESS"){
                var result = a.getReturnValue();
                if(result==null) {
                	component.set("v.hasIMValidationConfigStep", false);
                } else {
                	component.set("v.hasIMValidationConfigStep", true);
                    component.set("v.learningAssignValidStatus", result);
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
        } else if (response.startsWith('Validation Steps Execution Started')){
            component.set("v.showResponse", true);
            component.set("v.response_message", $A.get("$Label.c.TMS_IV_MSG_TRAILSETUP_STARTED"));
            component.set("v.response_theme", THEME_BASE+"info");
        }
        var obj = JSON.parse(response);
        if(obj==null)return;
        
        if(obj.copadoJobId) {
            component.set('v.copadoJobId', obj.copadoJobId);
        }
        if (obj.isSuccess && obj.isSuccess==true && obj.isFinished==false) {
            component.set("v.showResponse", true);
            component.set("v.response_message", $A.get("$Label.c.TMS_IV_MSG_TRAILSETUP_STARTED"));
            component.set("v.response_theme", THEME_BASE+"info");
        }
        else if (obj.isSuccess && obj.isSuccess==false && obj.isFinished==true) {
            component.set("v.showResponse", true);
            component.set("v.response_theme", THEME_BASE+"error");
            if(obj.error)component.set("v.response_message", obj.error);
        }
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
        var action = component.get("c.getIVCopadoJobId");
        var hasIMValidationConfigStep = component.get("v.hasIMValidationConfigStep");
        if (hasIMValidationConfigStep == false) {
            var intervalId = component.get("v.intervalId");
            window.clearInterval(intervalId);
        }

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
                    let successCount = 0, isProgressCount = 0;
                    let isFailed = false;
                    result.forEach(element => {
                        if (element.ExecutionStatus__c == 'In progress') {
                            component.set("v.copadoJobId", element.Job_ID__c);
                            isProgressCount++;
                        }
                        if (element.ExecutionStatus__c == 'Pending') {
                            isProgressCount++;
                        }
                        
                        if (element.Validation_Result__c == 'Success') {
                            successCount++
                        }
                        if ((element.ExecutionStatus__c == 'Failed' || element.Validation_Result__c == 'Failed') && !isFailed) {
                            isFailed = true
                        }
                    });
                    component.set("v.IMValidationStepExecutions", result);
                    if (successCount == result.length) {
                        component.set("v.jobInProgress", false);
                        component.set("v.response_theme", THEME_BASE+"success");
                        component.set("v.response_message", $A.get("$Label.c.TMS_IV_MSG_TRAILSETUP_SUCCESS"));
                        helper.hideButton(component, "btnSubmit");
                        helper.hideButton(component, "btnRetry");
                        let moduleId = component.get("v.recordId");
                        helper.hasIMValidationConfigStep(component, moduleId);
                        return;
                    }

                    if (isProgressCount > 0) {
                        component.set("v.showResponse", true);
                        component.set("v.isBtnDisable", true);
                        component.set("v.response_message", $A.get("$Label.c.TMS_IV_MSG_TRAILSETUP_STARTED"));
                        component.set("v.response_theme", THEME_BASE+"info");
                        helper.hideButton(component, "btnRetry");
                        return;
                    }

                    if(isFailed){
                        component.set("v.isBtnDisable", false);
                        component.set("v.jobInProgress", false);
                        component.set("v.response_theme", THEME_BASE+"error");

                        if(isProgressCount == 0){
                            helper.hideButton(component, "btnSubmit");
                            helper.showButton(component, "btnRetry");
                            let moduleId = component.get("v.recordId");
                            helper.hasIMValidationConfigStep(component, moduleId);
                        }
                        component.set("v.response_message", $A.get("$Label.c.TMS_IV_MSG_TRAILSETUP_ERROR"));
                    }
                } else {
                    helper.showButton(component, "btnSubmit");
                    component.set("v.IMValidationStepExecutions", null);
                }
            }
        });
        $A.enqueueAction(action);
    }
})