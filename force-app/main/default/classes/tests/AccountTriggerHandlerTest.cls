@isTest
private class AccountTriggerHandlerTest {
    @TestSetup
    static void makeData() {
        Account account = new Account(Name='Test account');
        List<Contact> contacts = new List<Contact>();
        insert account;

        for (Integer i = 0; i < 3; i++) {
            Contact contact = new Contact(LastName='Test contact ' + i, AccountId = account.Id);
            contacts.add(contact);
        }

        insert contacts;
    }

    @isTest
    static void testSetUpdateContactRecordsCheckboxToTrue() {
        Account account = [
            SELECT Id, Update_Contact_Records__c FROM Account 
            WHERE Name='Test account'
        ];

        Test.startTest();
        account.Update_Contact_Records__c = True;
        update account;
        Test.stopTest();

        List<Contact> contacts = [
            SELECT Id, Due_Date__c FROM Contact 
            WHERE AccountId =:account.Id
        ];
        Date startDate = System.today();
        Integer numberOfWorkDaysToAdd = 3;

        for (Contact contact : contacts) {
            Date expectedDate = DateUtility.getNextWorkDate(startDate, numberOfWorkDaysToAdd);
            System.assertEquals(expectedDate, contact.Due_Date__c);
            startDate = expectedDate;
        }
    }
}