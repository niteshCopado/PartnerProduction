@isTest
public class MyApexTestClass {

    // Test method for Apex Class 1
    @isTest
    static void testApexClass1() {
        // Test data setup
        Integer num1 = 2;
        Integer num2 = 3;
        
        // Test case execution
        Test.startTest();
        Integer result = ApexClass1.addNumbers(num1, num2);
        Test.stopTest();
        
        // Assertion statements for Apex Class 1
        System.assertEquals(5, result, 'Expected result to be 5');
    }
    
    // Test method for Apex Class 2
    @isTest
    static void testApexClass2() {
        // Test data setup
        String str1 = 'Hello';
        String str2 = 'World';
        
        // Test case execution
        Test.startTest();
        String result = ApexClass2.concatenateStrings(str1, str2);
        Test.stopTest();
        
        // Assertion statements for Apex Class 2
        System.assertEquals('HelloWorld', result, 'Expected result to be "HelloWorld"');
    }
}