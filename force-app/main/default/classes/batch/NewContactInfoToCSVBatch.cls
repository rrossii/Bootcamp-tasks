public with sharing class NewContactInfoToCSVBatch implements Database.Batchable<sObject>, Database.Stateful {
    List<String> csvRows = new List<String>(); 

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(
            'SELECT Id, FirstName, LastName, Phone, Email, Date_of_joining_the_company__c FROM Contact '+
            'WHERE CreatedDate = LAST_N_DAYS:1'
        );
    }

    public void execute(Database.BatchableContext context, List<Contact> scope) {
        if (scope.isEmpty()) {
            System.debug('empty contacts in NewContactInfoToCSVBatch');
        } else {
            System.debug('non-empty contacts in NewContactInfoToCSVBatch');
        }
        for (Contact c : scope) {
            String firstName = c.FirstName != null ? c.FirstName : ''; 
            String lastName = c.LastName != null ? c.LastName : 'null';
            String phone = c.Phone != null ? c.Phone : '';
            String email = c.Email != null ? c.Email : '';
            String dayOfJoiningTheCompany = c.Date_of_joining_the_company__c != null ? 
                                            c.Date_of_joining_the_company__c.format() : '';

            String rowValue = firstName + ',' + lastName + ',' + phone + ',' + email + ',' + dayOfJoiningTheCompany;
            csvRows.add(rowValue);

            System.debug('rowValue: ' + rowValue);
        }
    }

    public void finish(Database.BatchableContext context) {
        if (!csvRows.isEmpty()) {
            System.debug('First CSV row: ' + csvRows[0]);
        } else {
            System.debug('csvRows is empty, no data to show.');
        }
        
        String csvHeader = 'FirstName,LastName,Phone,Email,Date_of_joining_the_company__c\n';
        String csvFile = csvHeader + String.join(csvRows, '\n');
        Blob csvBlob = Blob.valueOf(csvFile);

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Contacts_Created_This_Day_' + Date.today();
        contentVersion.PathOnClient = 'Contacts_Created_This_Day.csv';
        contentVersion.VersionData = csvBlob;
        insert contentVersion;

        System.debug('CSV file with Contact created this day info created');
    }
}