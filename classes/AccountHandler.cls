public with sharing class AccountHandler {
    
    // Method to create an Account
    public static Id createAccount(String name, String phone, String type) {
        Account acc = new Account(
            Name = name,
            Phone = phone,
            Type = type
        );
        insert acc;
        return acc.Id;
    }

    // Method to get active accounts (assuming Active__c is a custom checkbox field)
    public static List<Account> getActiveAccounts() {
        return [SELECT Id, Name, Phone, Type FROM Account WHERE Active__c = 'Yes'];
    }
}