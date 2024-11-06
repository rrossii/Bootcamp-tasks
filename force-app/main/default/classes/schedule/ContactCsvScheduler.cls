public with sharing class ContactCsvScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        Date today = Date.today();
        Integer lastDayOfMonth = today.addMonths(1).toStartOfMonth().addDays(-1).day();
        Integer dayUntilMonthEnd = lastDayOfMonth - today.day();

        try {
            if (dayUntilMonthEnd == 2) {
                Database.executeBatch(new ContactInfoToCSVBatch(), 20);
            } else if (dayUntilMonthEnd == 1) {
                Database.executeBatch(new NewContactInfoToCSVBatch(), 5);
            } else if (dayUntilMonthEnd == 0) {
                Database.executeBatch(new ContactInfoToCSVBatch(), 20);
            }
        } catch (Exception e) {
            System.debug('Error executing batch (CSV file creation): ' + e.getMessage());
        }
    }
}