public with sharing class ContactInfoToCSVBatch implements Database.Batchable<sObject>, Database.Stateful {
    List<String> csvRows = new List<String>(); 

    public Database.QueryLocator start(Database.BatchableContext context) {
        Date firstDayOfCurrentMonth = Date.today().toStartOfMonth();
        Date lastDayOfCurrentMonth = Date.today().addMonths(1).toStartOfMonth().addDays(-1);
        DateTime firstDayOfMonthDateTime = DateTime.newInstanceGmt(firstDayOfCurrentMonth.year(), firstDayOfCurrentMonth.month(), firstDayOfCurrentMonth.day(), 0, 0, 0);
        DateTime lastDayOfMonthDateTime = DateTime.newInstanceGmt(lastDayOfCurrentMonth.year(), lastDayOfCurrentMonth.month(), lastDayOfCurrentMonth.day(), 23, 59, 59);

        System.debug('firstDayOfMonthDateTime: ' + firstDayOfMonthDateTime);
        System.debug('lastDayOfMonthDateTime: ' + lastDayOfMonthDateTime);
        
        return Database.getQueryLocator(
            'SELECT Id, FirstName, LastName, Phone, Email, Date_of_joining_the_company__c FROM Contact ' +
            'WHERE CreatedDate >= :firstDayOfMonthDateTime AND CreatedDate <= :lastDayOfMonthDateTime'
        );
    }
    public void execute(Database.BatchableContext context, List<Contact> scope) {
        System.debug('execute in ContactInfoToCSVBatch');
        if (scope.isEmpty()) {
            System.debug('empty contacts in ContactInfoToCSVBatch');
        } else {
            System.debug('non-empty contacts in ContactInfoToCSVBatch');
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
        contentVersion.Title = 'Contacts_Created_This_Month_' + Date.today();
        contentVersion.PathOnClient = 'Contacts_Created_This_Month.csv';
        contentVersion.VersionData = csvBlob;
        insert contentVersion;

        System.debug('CSV file with Contact created this month info created');
    }
}