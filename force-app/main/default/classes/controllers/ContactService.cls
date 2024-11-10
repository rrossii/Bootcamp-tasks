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

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsForAccount(Id accountId) {
        System.debug('accountId' + accountId);
        if (accountId == null) {
            return new List<Contact>();
        }

        List<Contact> contacts = [
            SELECT Id, FirstName, LastName, Birthdate, Email, LeadSource 
            FROM Contact WHERE AccountId = :accountId
        ];
        System.debug('contacts' + contacts);
        return contacts;
    }
}