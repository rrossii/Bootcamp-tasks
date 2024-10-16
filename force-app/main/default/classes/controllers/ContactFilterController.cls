public with sharing class ContactFilterController {
    @AuraEnabled
    public static List<Contact> getFilteredContacts(Id accountId, Date dateFrom, Date dateTo, String type) {
        try {
            String queryToGetFilteredContacts = 
                'SELECT FirstName, LastName, Birthdate, Phone, Email, Date_of_joining_the_company__c, Type__c FROM Contact WHERE Account.Id = :accountId';
            
            if (dateFrom != null) {
                queryToGetFilteredContacts += ' AND Date_of_joining_the_company__c >= :dateFrom';
            }
            if (dateTo != null) {
                queryToGetFilteredContacts += ' AND Date_of_joining_the_company__c <= :dateTo';
            }
            if (type != null & type != '') {
                queryToGetFilteredContacts += ' AND Type__c = :type';
            }
    
            return Database.query(queryToGetFilteredContacts);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<String> getTypePicklistValues() {
        try {
            Schema.DescribeFieldResult fieldResult = Contact.Type__c.getDescribe();
            List<Schema.PicklistEntry> typePicklist = fieldResult.getPicklistValues();

            List<String> types = new List<String>();
            for (Schema.PicklistEntry typeValue : typePicklist){
                types.add(typeValue.getLabel());
            }     

            return types;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}