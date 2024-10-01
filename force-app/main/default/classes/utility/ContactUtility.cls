public with sharing class ContactUtility {
    public static AggregateResult numberOfExistingContactsOnAccount(Id accountId) {
        return [SELECT AccountId, COUNT(Id) ContactCount FROM Contact 
                WHERE AccountId =:accountId GROUP BY AccountId];
    }
}