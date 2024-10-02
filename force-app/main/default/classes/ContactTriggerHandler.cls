public with sharing class ContactTriggerHandler extends TriggerHandler {
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

        for (Contact contact : contactsWithAccount) {
            Integer currentContactNumber = accountsAndNumberOfRelatedContacts.get(contact.AccountId);
            if (currentContactNumber == 5) {
                contact.addError('This account already has 5 contacts.');
            } 
        }
    }
}