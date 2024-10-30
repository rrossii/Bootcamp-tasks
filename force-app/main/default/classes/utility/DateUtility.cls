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

    public static Integer calculateDaysBetweenDates(Date dateFrom, Date dateTo) {
        if (dateFrom <= dateTo) {
            return dateFrom.daysBetween(dateTo);
        } else {
            return 0; // затичка
            // throw error and catch later
        }
    }
    public static Integer calculateWorkDaysBetweenDates(Date dateFrom, Date dateTo) {
        Integer workingDays = 0;
        Date currentDate = dateFrom;
        if (currentDate <= dateTo) {
            while (currentDate <= dateTo) {
                String dayOfWeek = getDayOfWeek(currentDate);
                if (!WEEKEND.contains(dayOfWeek)) {
                    workingDays += 1;
                }
                currentDate = currentDate.addDays(1);
            }
        } else {
            return 0; // затичка
            // throw error and catch later
        }

        return workingDays;
    }

    private static String getDayOfWeek(Date givenDate) {
        DateTime givenDateToDateTime = (DateTime)givenDate;
        return givenDateToDateTime.format('EEEE');
    }
}