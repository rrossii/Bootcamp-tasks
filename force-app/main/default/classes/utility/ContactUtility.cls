public with sharing class ContactUtility {
    public static Integer numberOfExistingContactsOnAccount(Id accountId) {
        List<AggregateResult> result = [
            SELECT AccountId, COUNT(Id) ContactCount FROM Contact 
            WHERE AccountId =:accountId GROUP BY AccountId];
        if (result.isEmpty()) {
            return 0;
        }
        return (Integer)result[0].get('ContactCount');
    }

    public static void updateDueDateForEachContact(List<Contact> contacts) {
        Integer numberOfWorkDaysToAdd = 3;
        for (Contact contact : contacts) {
            Date contactDueDate = DateUtility.getNextWorkDate(System.today(), numberOfWorkDaysToAdd);
            contact.Due_Date__c = contactDueDate;

            numberOfWorkDaysToAdd += 3;
        }

        try {
            update contacts;
            System.debug('Contacts Due date field updated successfully');
        } catch (DmlException e) {
            System.debug('Error while updating Contact Due date field: ' + e.getMessage());
        }
    }
}