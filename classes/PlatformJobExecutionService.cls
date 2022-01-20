public with sharing class PlatformJobExecutionService {

    public static void updateRelatedStepExecution(copado1p__Platform_Job_Execution__c oldPje, copado1p__Platform_Job_Execution__c pje) {
        if (oldPje.copado1p__Status__c != pje.copado1p__Status__c && pje.copado1p__Copado_Job_ID__c != null) {
            String stepExecutionStatus;
            if (pje.copado1p__Status__c == 'Starting') {
                stepExecutionStatus = 'Pending';
            } else if (pje.copado1p__Status__c == 'Running') {
                stepExecutionStatus = 'In progress';
            } else if (pje.copado1p__Status__c == 'Success') {
                stepExecutionStatus = 'Completed';
            } else if (pje.copado1p__Status__c == 'Failure') {
                stepExecutionStatus = 'Failed';
            }

            // Update Step Execution for Interactive Module
            List<Step_Execution__c> stepExecutionToBeUpdate = new List<Step_Execution__c>();
            for (Step_Execution__c se : [Select Id, Status__c, Platform_Job_Execution__c From Step_Execution__c Where JobID__c =:pje.copado1p__Copado_Job_ID__c Order by LastModifiedDate DESC Limit 1]) {
                se.Status__c = stepExecutionStatus;
                se.Platform_Job_Execution__c = pje.Id;
                stepExecutionToBeUpdate.add(se);
            }

            if (!stepExecutionToBeUpdate.isEmpty()) {
                update stepExecutionToBeUpdate;
            }

            // Update Step Execution for Interactive Validation
            List<Interactive_Validation_Step_Execution__c> IVStepExecutionToBeUpdate = new List<Interactive_Validation_Step_Execution__c>();
            for (Interactive_Validation_Step_Execution__c se : [Select Id, ExecutionStatus__c, Platform_Job_Execution__c From Interactive_Validation_Step_Execution__c Where Job_ID__c =:pje.copado1p__Copado_Job_ID__c Order by LastModifiedDate DESC Limit 1]) {
                se.ExecutionStatus__c = stepExecutionStatus;
                se.Platform_Job_Execution__c = pje.Id;
                IVStepExecutionToBeUpdate.add(se);
            }

            if (!IVStepExecutionToBeUpdate.isEmpty()) {
                update IVStepExecutionToBeUpdate;
            }
            
        }
    }
}