<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_ACV</fullName>
        <field>ACV__c</field>
        <formula>Opp_ACV__c</formula>
        <name>Set ACV</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_TCV</fullName>
        <field>TCV__c</field>
        <formula>Opp_TCV__c</formula>
        <name>Set TCV</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Set ACV and TCV</fullName>
        <actions>
            <name>Set_ACV</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_TCV</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This populates the currency fields from the formula field so that we can use it in a Roll-up summary field.</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
