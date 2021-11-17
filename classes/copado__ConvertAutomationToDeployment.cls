/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ConvertAutomationToDeployment {
    global ConvertAutomationToDeployment() {

    }
    @InvocableMethod(label='Execute Automation Template' description='Convert Automation into a deployment, clone the steps, create destination orgs and clone attachments')
    global static List<copado__Result__c> execute(List<copado.ConvertAutomationToDeployment.InvocableVariables> variables) {
        return null;
    }
global class InvocableVariables {
    @InvocableVariable(label='Automation Template Id' required=true)
    global Id automationTemplateId;
    @InvocableVariable(label='Execute Automatically' required=false)
    global Boolean execute;
    @InvocableVariable(label='Source Credential Id' required=false)
    global Id sourceCredentialId;
    @InvocableVariable(label='Target Credential Id' required=false)
    global Id targetCredentialId;
    global InvocableVariables() {

    }
}
}
