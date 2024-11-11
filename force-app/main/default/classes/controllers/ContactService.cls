public with sharing class ContactService {
    @AuraEnabled
    public static List<Contact> findDuplicateContacts(List<Contact> contactsToCheck) {
        Set<String> emails = new Set<String>();
        for (Contact contact : contactsToCheck) {
            if (contact.Email != '' && contact.Email != null) {
                emails.add(contact.Email);
            }
        }

        if (!emails.isEmpty()) {
            System.debug('emails is empty? :' + emails.isEmpty() + 'emails: ' + emails + 'size: ' + emails.size());
            List<Contact> contactsWithTheseEmails = [
                SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email IN :emails
            ];
            System.debug('contacts with emails' + contactsWithTheseEmails);
            return contactsWithTheseEmails;
        } else {
            return new List<Contact>();
        } 
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