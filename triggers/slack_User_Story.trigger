trigger slack_User_Story on copado__User_Story__c (after insert, after update, before delete) {
	if(trigger.isAfter && trigger.isInsert || trigger.isAfter && trigger.isUpdate || trigger.isBefore && trigger.isDelete) {
		slackv2__.utilities.startSubscriptionQueue(trigger.newMap, trigger.oldMap, trigger.operationType, 'copado__User_Story__c');
	}
}