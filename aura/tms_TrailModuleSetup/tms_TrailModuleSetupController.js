({
	doInit : function(component, event, helper) {
        var moduleId = helper.getParameterFromUrl("ltui__urlRecordId");
        component.set("v.recordId", moduleId);
        helper.hasConfigStep(component, moduleId);

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
        component.set("v.isSeedBtnDisable", false);
		component.set("v.isOpen", false);
        
        helper.hideButton(component, "btnOpenPlayground");
        helper.showButton(component, "btnClose");
        helper.showButton(component, "btnSubmit");
    },
    setSelectedPlayground: function(component, event, helper) {

        var params = event.getParam('arguments');
        if (params) {
            var playground = params.playground;

            component.set("v.stepExecutions", null);
            component.set("v.selectedPlayground", playground.Id);
            component.set("v.selectedOrgCredentialId", playground.Org_Credential__c);
            component.set("v.selectedPlaygroundName", playground.Name);

            component.set("v.isOpen", true);
            helper.getCopadoJobId(component, helper);
        }
    },
    runJob: function(component, event, helper) {
        component.set("v.showResponse", false);
        component.set("v.response_message", "");
        var action = component.get("c.runOrgConfigurationStep");

        action.setParams({
            "playgroundId": component.get("v.selectedPlayground"),
            "learningAssignmentId": component.get("v.recordId")
        });
        component.set("v.isSeedBtnDisable", true);

        action.setCallback(this, function(response) {

            component.set("v.showResponse", true);
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                helper.handleResponse(component, response.getReturnValue());
            	component.set("v.jobInProgress", true);
            }
            else if (state === "ERROR") {
                component.set("v.isSeedBtnDisable", false);
                var errors = response.getError();
                component.set("v.showResponse", true);
            	component.set("v.jobInProgress", false);
                component.set("v.response_theme", "error");
                component.set("v.response_message", ((errors)?obj.error: "Unknown error"));
            }
        });
        //now create background action for credit assignment.
        var backgroundAction = component.get("c.assignCredits");
        backgroundAction.setBackground();
        backgroundAction.setParams({ "playgroundId": component.get("v.selectedPlayground") });
        backgroundAction.setCallback(this, function(response) {
            var state = response.getState();
        });
        $A.enqueueAction(backgroundAction);
        $A.enqueueAction(action);

    },
    openPlayground: function(component, event, helper){

        let orgId = component.get("v.selectedOrgCredentialId");
        helper.getFrontDoorUrl(component, orgId);

    },
	changeStepStatus : function(component, event, helper) {
		let stepId = event.currentTarget.getAttribute("data-stepId");
        if(stepId != ''){
            helper.restartStepProcess(component, helper, stepId);

        }
	}
})