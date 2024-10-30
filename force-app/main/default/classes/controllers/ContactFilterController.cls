public with sharing class ContactFilterController {
    public List<Contact> contacts { get; set; }

    public ContactFilterController() {
        String dateFrom = ApexPages.currentPage().getParameters().get('dateFrom');
        String dateTo = ApexPages.currentPage().getParameters().get('dateTo');
        String type = ApexPages.currentPage().getParameters().get('type');
        String accountId = ApexPages.currentPage().getParameters().get('recordId');

        Date dateFromParsed = (dateFrom != null && dateFrom != '') ? Date.valueOf(dateFrom) : null;
        Date dateToParsed = (dateTo != null && dateTo != '') ? Date.valueOf(dateTo) : null;
        
        contacts = getFilteredContacts(accountId, dateFromParsed, dateToParsed, type);
    }

    @AuraEnabled(cacheable=true)
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

    @AuraEnabled(cacheable=true)
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