@isTest
public class ContactTriggerHandlerTest {
    @TestSetup
    static void makeData() {
        Account account = new Account(Name='Test account');
        List<Contact> contacts = new List<Contact>();
        insert account;

        for (Integer i = 0; i < 5; i++) {
            Contact contact = new Contact(LastName='Test contact ' + i, AccountId = account.Id);
            contacts.add(contact);
        }

        insert contacts;
    }

    @isTest
    static void testInsertingMoreThatFiveContactsInAccount() {
        Account account = [SELECT Id FROM Account];
        Integer numOfContactsOnAccount = ContactUtility.numberOfExistingContactsOnAccount(account.Id);
        System.assertEquals(5, numOfContactsOnAccount);

        Test.startTest();
        Contact contact = new Contact(LastName='Last test contact ', AccountId = account.Id);
        try {
            insert contact;
            System.assert(false, 'Expected error, but more than 5 Contacts are created and error was not thrown.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('This account already has 5 contacts.'));
        }
        
        Test.stopTest();
    }
}