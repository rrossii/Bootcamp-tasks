@isTest
private class ContactInfoToCSVBatchTest {
    @testSetup
    static void makeData() {
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(
            FirstName = 'Test',
            LastName = 'Test1',
            Email = 'testtype1@example.com',
            Date_of_joining_the_company__c = Date.today().addDays(-10),
            Type__c = 'Type 1'
        ));

        contacts.add(new Contact(
            FirstName = 'Test',
            LastName = 'Test2',
            Email = 'testtype2@example.com',
            Date_of_joining_the_company__c = Date.today().addDays(-20),
            Type__c = 'Type 2'
        ));

        contacts.add(new Contact(
            FirstName = 'Test',
            LastName = 'Test3',
            Email = 'testtype3@example.com',
            Date_of_joining_the_company__c = Date.today().addDays(-30),
            Type__c = 'Type 3'
        ));

        insert contacts;
    }

    @isTest
    static void testCsvFileCreation() {
        Test.startTest();
        ContactInfoToCSVBatch csvBatch = new ContactInfoToCSVBatch();
        Id csvBatchId = Database.executeBatch(csvBatch, 3);
        Test.stopTest();

        String expectedTitle = 'Contacts_Created_This_Month_' + Date.today();
        List<ContentVersion> csvFile = [SELECT Id, Title FROM ContentVersion WHERE Title LIKE :expectedTitle];
        System.assertEquals(1, csvFile.size(), 'Cannot create CSV file with Contacts created this month');
    }
}