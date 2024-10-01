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
}