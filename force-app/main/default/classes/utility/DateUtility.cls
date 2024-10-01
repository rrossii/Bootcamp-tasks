public with sharing class DateUtility {
    public static Date getNextWorkDate(Date startDate, Integer numberOfWorkDaysToAdd) {
        Date endDate = startDate;
        Integer howManyWorkDaysHaveBeenAdded = 0;

        while (howManyWorkDaysHaveBeenAdded < numberOfWorkDaysToAdd) {
            endDate = endDate.addDays(1);
            DateTime dt = (DateTime)endDate;
            String dayOfWeek = dt.format('EEEE');

            if (dayOfWeek != 'Saturday' || dayOfWeek != 'Sunday') {
                howManyWorkDaysHaveBeenAdded += 1;
            }
        }

        return endDate;
    }
}