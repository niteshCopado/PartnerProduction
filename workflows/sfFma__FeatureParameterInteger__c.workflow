<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Alert_For_Deal_Desk_and_Renewals_Managers</fullName>
        <ccEmails>rranjan@copado.com</ccEmails>
        <description>Email Alert For Deal Desk and Renewals Managers</description>
        <protected>false</protected>
        <recipients>
            <recipient>Sales_Ops</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales_Templates/Email_Alert_For_Ops_AMs_and_CSMs_for_SFDC_Orgs</template>
    </alerts>
    <fieldUpdates>
        <fullName>Zero_Licenses</fullName>
        <field>sfFma__Value__c</field>
        <formula>0</formula>
        <name>Zero Licenses</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Check Expiration Date</fullName>
        <active>true</active>
        <criteriaItems>
            <field>sfFma__FeatureParameterInteger__c.Expiration_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>sfFma__FeatureParameterInteger__c.Expiration_Date__c</offsetFromField>
            <timeLength>-7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
