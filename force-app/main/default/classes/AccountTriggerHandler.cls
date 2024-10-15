public with sharing class AccountTriggerHandler extends TriggerHandler {
    List<Account> accounts = Trigger.new;
    Set<Id> accountIdsWithEnabledUpdateContactsCheckbox = new Set<Id>();

    public override void afterInsert() {
        handleUpdateContactRecordsCheckboxEnabled();
    }

    public override void afterUpdate() {
        handleUpdateContactRecordsCheckboxEnabled();
    }

    private void handleUpdateContactRecordsCheckboxEnabled() {
        for (Account account : accounts) {
            if (account.Update_Contact_Records__c) {
                accountIdsWithEnabledUpdateContactsCheckbox.add(account.Id);
            }
        }

        if (!accountIdsWithEnabledUpdateContactsCheckbox.isEmpty()) {
            List<Contact> contactsToUpdate = [
                SELECT Id, Due_Date__c FROM Contact 
                WHERE AccountId IN :accountIdsWithEnabledUpdateContactsCheckbox
                ORDER BY CreatedDate ASC
            ];

            ContactUtility.updateDueDateForEachContact(contactsToUpdate);
        }
    }

}