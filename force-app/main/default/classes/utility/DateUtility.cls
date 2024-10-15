public with sharing class DateUtility {
    private static Set<String> WEEKEND = new Set<String>{'Saturday', 'Sunday'};

    public static Date getNextWorkDate(Date startDate, Integer numberOfWorkDaysToAdd) {
        Date endDate = startDate;
        Integer howManyWorkDaysHaveBeenAdded = 0;

        while (howManyWorkDaysHaveBeenAdded < numberOfWorkDaysToAdd) {
            endDate = endDate.addDays(1);
            DateTime dt = (DateTime)endDate;
            String dayOfWeek = dt.format('EEEE');

            if (!WEEKEND.contains(dayOfWeek)) {
                howManyWorkDaysHaveBeenAdded += 1;
            }
        }

        return endDate;
    }
}