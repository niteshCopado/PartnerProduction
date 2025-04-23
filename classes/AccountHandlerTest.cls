@isTest
private class AccountHandlerTest {

    @isTest
    static void testCreateAccount() {
        String name = 'Test Account';
        String phone = '1234567890';
        String type = 'Customer';

        Test.startTest();
        Id accId = AccountHandler.createAccount(name, phone, type);
        Test.stopTest();

        Account acc = [SELECT Name, Phone, Type FROM Account WHERE Id = :accId];
        System.assertEquals(name, acc.Name);
        System.assertEquals(phone, acc.Phone);
        System.assertEquals(type, acc.Type);
    }

    @isTest
    static void testGetActiveAccounts() {
        // Create sample active account
        Account activeAcc = new Account(
            Name = 'Active Account',
            Active__c = 'Yes' // Make sure this field exists in your org
        );
        insert activeAcc;

        // Create inactive account
        Account inactiveAcc = new Account(
            Name = 'Inactive Account',
            Active__c = 'No'
        );
        insert inactiveAcc;

        Test.startTest();
        List<Account> activeAccounts = AccountHandler.getActiveAccounts();
        Test.stopTest();

        System.assertNotEquals(0, activeAccounts.size());
        for (Account acc : activeAccounts) {
            System.assertEquals('Yes', acc.Active__c);
        }
    }
}