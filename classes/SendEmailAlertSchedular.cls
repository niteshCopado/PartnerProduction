global class SendEmailAlertSchedular implements Schedulable {
    global void execute(SchedulableContext SC) {
        SendEmailAlertBatchClass batchObj = new SendEmailAlertBatchClass(); 
        database.executebatch(batchObj);
        
    }
    /*Excecute this code in Anonymous Window once to run batch class in every 10min
System.schedule('Scheduled Job 1', '0 0 * * * ?', new HelpDocsSyncSch());
System.schedule('Scheduled Job 2', '0 10 * * * ?', new HelpDocsSyncSch());
System.schedule('Scheduled Job 3', '0 20 * * * ?', new HelpDocsSyncSch());
System.schedule('Scheduled Job 4', '0 30 * * * ?', new HelpDocsSyncSch());
System.schedule('Scheduled Job 5', '0 40 * * * ?', new HelpDocsSyncSch());
System.schedule('Scheduled Job 6', '0 50 * * * ?', new HelpDocsSyncSch());

*/
}