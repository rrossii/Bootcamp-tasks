public with sharing class ContactUtility {
    public static Map<Id, Integer> numberOfExistingContactsOnAccounts(List<Id> accountIds) {
        List<AggregateResult> accountsAndNumOfContacts = [
            SELECT AccountId, COUNT(Id) ContactCount FROM Contact 
            WHERE AccountId IN :accountIds GROUP BY AccountId
        ];
        
        Map<Id, Integer> accountsAndNumberOfRelatedContacts = new Map<Id, Integer>();
        for (AggregateResult aggResult : accountsAndNumOfContacts) {
            Id currentAccId = (Id)aggResult.get('AccountId');
            Integer numberOfContactsForCurrentAcc = (Integer)aggResult.get('ContactCount');

            accountsAndNumberOfRelatedContacts.put(currentAccId, numberOfContactsForCurrentAcc);
        }

        for (Id accountId : accountIds) {
            if (!accountsAndNumberOfRelatedContacts.containsKey(accountId)) {
                accountsAndNumberOfRelatedContacts.put(accountId, 0);
            }
        }

        return accountsAndNumberOfRelatedContacts;
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
    public static List<String> getContactTypeValues() {
        Schema.DescribeFieldResult fieldResult = Contact.Type__c.getDescribe();
        List<Schema.PicklistEntry> typePicklist = fieldResult.getPicklistValues();

        List<String> types = new List<String>();
        for (Schema.PicklistEntry typeValue : typePicklist){
            types.add(typeValue.getLabel());
        }     

        return types;
    }
}