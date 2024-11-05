@isTest
private class ContactCsvSchedulerTest {
    public static String CRON_EXPR = '0 0 0 30 11 ? 2024';

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
    static void testCsvFileCreationOnLastDay() {
        Test.startTest();
        String jobId = System.schedule(
            'Create CSV file with Contacts created on 30 November',
            CRON_EXPR,
            new ContactCsvScheduler()
        );

        String expectedTitle = 'Contacts_Created_This_Month_2024-11-30 00:00:00';
        List<ContentVersion> csvFile = [SELECT Id, Title FROM ContentVersion WHERE Title LIKE 'Contacts_Created_This_Month_%'];
        System.assertEquals(0, csvFile.size(), 'csvFile exist before job has run');
        Test.stopTest();

        csvFile = [SELECT Id, Title FROM ContentVersion WHERE Title LIKE 'Contacts_Created_This_Month_%'];
        System.assertEquals(1, csvFile.size(), 'csvFile wasnt created');
    }
}