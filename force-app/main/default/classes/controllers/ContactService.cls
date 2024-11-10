public with sharing class ContactService {
    @AuraEnabled
    public static List<Contact> findDuplicateContacts(List<Contact> contactsToCheck) {
        Set<String> emails = new set<String>();
        for (Contact contact : contactsToCheck) {
            emails.add(contact.Email);
        }

        List<Contact> contactsWithTheseEmails = [
            SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email IN :emails
        ];
        System.debug('contacts with emails' + contactsWithTheseEmails);
        return contactsWithTheseEmails;
    }
}