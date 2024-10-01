public with sharing class ContactTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        List<Contact> contactsToInsert = Trigger.new;

        for (Contact contact : contactsToInsert) {
            if (contact.AccountId != null) {
                Integer numOfContactsOnAccount = ContactUtility.numberOfExistingContactsOnAccount(contact.AccountId);
                if (numOfContactsOnAccount == 5) {
                    contact.addError('This account already has 5 contacts.');
                }
            }
        }
    }
}