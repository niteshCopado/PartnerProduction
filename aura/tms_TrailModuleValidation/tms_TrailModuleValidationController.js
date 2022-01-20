({
	doInit : function(component, event, helper) {
        var moduleId = helper.getParameterFromUrl("ltui__urlRecordId");
        component.set("v.recordId", moduleId);
        helper.hasIMValidationConfigStep(component, moduleId);

        //Schedule method to get copado job Id in every minute
        var intervalId = window.setInterval($A.getCallback(function() {
            helper.getCopadoJobId(component, helper);
        }),
        5000);
        component.set("v.intervalId", intervalId);
	},
   	closeModal: function(component, event, helper) {
        component.set("v.showResponse", false);
        component.set("v.response_message", "");
        component.set("v.isBtnDisable", false);
		component.set("v.isOpen", false);
    },
    setSelectedPlayground: function(component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            var playground = params.playground;
            
            component.set("v.IMValidationStepExecutions", null);
            component.set("v.selectedPlayground", playground.Id);
            component.set("v.selectedPlaygroundName", playground.Name);
            component.set("v.isOpen", true);
            helper.getCopadoJobId(component, helper);
        }
    },
    runJob: function(component, event, helper) {
        component.set("v.showResponse", false);
        component.set("v.response_message", "");
        component.set("v.response_theme", "");
        var action = component.get("c.runIVOrgConfigurationStep");

        action.setParams({
            "playgroundId": component.get("v.selectedPlayground"),
            "learningAssignmentId": component.get("v.recordId")
        });
        component.set("v.isBtnDisable", true);
        
        action.setCallback(this, function(response) {
            
            component.set("v.showResponse", true);
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                helper.handleResponse(component, response.getReturnValue());
            	component.set("v.jobInProgress", true);
            }
            else if (state === "ERROR") {
                component.set("v.isBtnDisable", false);
                var errors = response.getError();
                component.set("v.showResponse", true);
            	component.set("v.jobInProgress", false);
                component.set("v.response_theme", "slds-notify slds-notify_alert slds-theme_alert-texture slds-theme_error");
                component.set("v.response_message", ((errors)?obj.error: "Unknown error"));
            }
        });
        
        $A.enqueueAction(action);
        
    }
})