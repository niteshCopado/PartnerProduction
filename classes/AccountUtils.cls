public class AccountUtils {
    
    public static void updateAccountStatus(List<Account> accounts, String status) {
        for(Account acc : accounts) {
            acc.Status__c = status;
//Adding a comment
        }
        update accounts;
    }
    //Push to trigger Sonarcloud Scan
    public static List<Account> getActiveAccounts() {
        return [SELECT Id, Name, Status__c FROM Account WHERE Status__c = 'Active'];
    }
    
}
