public with sharing class NewContactInfoToCSVBatch implements Database.Batchable<sObject>, Database.Stateful {
    List<String> csvRows = new List<String>(); 

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(
            'SELECT Id, FirstName, LastName, Phone, Email, Date_of_joining_the_company__c, Type__c FROM Contact '+
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
                              + dayOfJoiningTheCompany + ',' + numOfDaysSinceJoinedTheCompany + ',' + type;
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
        contentVersion.Title = 'Contacts_Created_This_Day_' + Date.today();
        contentVersion.PathOnClient = 'Contacts_Created_This_Day.csv';
        contentVersion.VersionData = csvBlob;
        insert contentVersion;

        System.debug('CSV file with Contact created this day info created');
    }
}