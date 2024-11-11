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

    // @AuraEnabled(cacheable=true)
    // public static List<ContactWrapper> getContactsForAccountWithCalculatedAge(Id accountId) {
    //     if (accountId == null) {
    //         return new List<ContactWrapper>();
    //     }

    //     List<ContactWrapper> contactsWithAge = new List<ContactWrapper>();
    //     List<Contact> contacts = [
    //         SELECT Id, FirstName, LastName, Birthdate, Email, LeadSource 
    //         FROM Contact WHERE AccountId = :accountId
    //     ];
    //     for (Contact contact : contacts) {
    //         Integer age = null;
    //         Date today = Date.today();

    //         if (contact.Birthdate != null) {
    //             age = today.year() - contact.Birthdate.year();
    //             if (today.month() < contact.Birthdate.month() || 
    //                 (today.month() == contact.Birthdate.month() && today.day() < contact.Birthdate.day())) {
    //                 age--;
    //             }
    //             contactsWithAge.add(new ContactWrapper(contact, age));
    //         }
    //     }

    //     return contactsWithAge;
    // }

    // public class ContactWrapper {
    //     @AuraEnabled public Contact contact {get; set;}
    //     @AuraEnabled public Integer age {get; set;}

    //     public ContactWrapper(Contact contact, Integer age) {
    //         this.contact = contact;
    //         this.age = age;
    //     }
    // }
}