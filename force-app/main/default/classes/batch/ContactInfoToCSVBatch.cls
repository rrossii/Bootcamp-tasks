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
            'SELECT Id, FirstName, LastName, Phone, Email, Date_of_joining_the_company__c, Type__c FROM Contact ' +
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
            String lastName = c.LastName != null ? c.LastName : '';
            String phone = c.Phone != null ? c.Phone : '';
            String email = c.Email != null ? c.Email : '';
            String dateOfJoiningTheCompany = c.Date_of_joining_the_company__c != null ? 
                                            c.Date_of_joining_the_company__c.format() : '';
            String type = c.Type__c != null ? c.Type__c : '';

            String numOfDaysSinceJoinedTheCompany = '';
            if (c.Date_of_joining_the_company__c != null) {
                switch on c.Type__c {
                    when 'Type 1' {
                        try {
                            numOfDaysSinceJoinedTheCompany = String.valueOf(
                                DateUtility.calculateWorkDaysBetweenDates(c.Date_of_joining_the_company__c, Date.today()));
                        } catch (Exception e) {
                            System.debug('Error in calculateWorkDaysBetweenDates(): ' + e.getMessage());
                            numOfDaysSinceJoinedTheCompany = 'null';
                        }
                    }
                    when 'Type 2' {
                        try {
                            numOfDaysSinceJoinedTheCompany = String.valueOf(
                                DateUtility.calculateDaysBetweenDates(c.Date_of_joining_the_company__c, Date.today()));
                        } catch (Exception e) {
                            System.debug('Error in calculateDaysBetweenDates(): ' + e.getMessage());
                            numOfDaysSinceJoinedTheCompany = 'null';
                        }
                    }
                    when 'Type 3' {
                        try {
                            numOfDaysSinceJoinedTheCompany = String.valueOf(
                                DateUtility.calculateDaysBetweenDatesMinusOneDayForEachMonth(c.Date_of_joining_the_company__c, Date.today()));
                        } catch (Exception e) {
                            System.debug('Error in calculateDaysBetweenDatesMinusOneDayForEachMonth(): ' + e.getMessage());
                            numOfDaysSinceJoinedTheCompany = 'null';
                        }
                    }
                }
            }
            String rowValue = firstName + ',' + lastName + ',' 
                              + phone + ',' + email + ',' 
                              + dateOfJoiningTheCompany + ',' + numOfDaysSinceJoinedTheCompany + ',' + type;
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
        
        String csvHeader = 'FirstName,LastName,Phone,Email,Date of joining the company,Days since joined the company,Type\n';
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