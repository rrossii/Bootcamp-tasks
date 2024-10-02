public with sharing class ContactTriggerHandler extends TriggerHandler {
    // public override void beforeInsert() {
    //     List<Contact> contactsToInsert = Trigger.new;

    //     for (Contact contact : contactsToInsert) {
    //         if (contact.AccountId != null) {
    //             Integer numOfContactsOnAccount = ContactUtility.numberOfExistingContactsOnAccount(contact.AccountId);
    //             if (numOfContactsOnAccount == 5) {
    //                 contact.addError('This account already has 5 contacts.');
    //             }
    //         }
    //     }
    // }

    public override void beforeInsert() {
        List<Contact> contactsToInsert = Trigger.new;
        List<Contact> contactsWithAccount = new List<Contact>();
        List<Id> accountIds = new List<Id>();

        for (Contact contact : contactsToInsert) {
            if (contact.AccountId != null) {
                accountIds.add(contact.AccountId);
                contactsWithAccount.add(contact);
            }
        }

        Map<Id, Integer> accountsAndNumberOfRelatedContacts = new Map<Id, Integer>();
        if (!accountIds.isEmpty()) {
            accountsAndNumberOfRelatedContacts = ContactUtility.numberOfExistingContactsOnAccounts(accountIds);
        }

        // for (Contact contact : contactsWithAccount) {
        //     if (accountsAndNumberOfRelatedContacts.containsKey(contact.AccountId)) {
        //         if (accountsAndNumberOfRelatedContacts.get(contact.AccountId) == 5) {
        //             contact.addError('This account already has 5 contacts.');
        //         }
        //     }
        // }

        for (Contact contact : contactsWithAccount) {
            Integer currentContactNumber = accountsAndNumberOfRelatedContacts.get(contact.AccountId);
            if (currentContactNumber == 5) {
                contact.addError('This account already has 5 contacts.');
            } 

        }
    }
}