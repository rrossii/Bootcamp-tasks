public with sharing class ContactService {
    @AuraEnabled
    public static List<Contact> findDuplicateContacts(List<String> emails) {
        System.debug('contact emails list in findDuplicateContacts: ' + emails);

        Set<String> emailsSet = new Set<String>(emails);
        if (!emailsSet.isEmpty()) {
            List<Contact> contactsWithTheseEmails = [
                SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email IN :emailsSet
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

    @AuraEnabled(cacheable=true)
    public static List<String> getLeadSourceValues() {
        return ContactUtility.getLeadSourcePicklistValues();
    }
}