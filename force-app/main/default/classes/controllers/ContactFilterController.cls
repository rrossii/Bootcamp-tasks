public with sharing class ContactFilterController {
    @AuraEnabled
    public static List<Contact> getFilteredContacts(Date dateFrom, Date dateTo, String type) {
        try {
            List<Contact> contacts = [
                SELECT FirstName, LastName, Birthdate, Phone, Email, Date_of_joining_the_company__c, Type__c
                FROM Contact 
                WHERE Date_of_joining_the_company__c >= :dateFrom 
                AND Date_of_joining_the_company__c <= :dateTo
                AND Type__c = :type
            ];

            return contacts;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}