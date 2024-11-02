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
        validateDates(dateFrom, dateTo);

        return dateFrom.daysBetween(dateTo);
    }

    public static Integer calculateWorkDaysBetweenDates(Date dateFrom, Date dateTo) {
        validateDates(dateFrom, dateTo);

        Integer workingDays = 0;
        Date currentDate = dateFrom;
        while (currentDate <= dateTo) {
            String dayOfWeek = getDayOfWeek(currentDate);
            if (!WEEKEND.contains(dayOfWeek)) {
                workingDays += 1;
            }
            currentDate = currentDate.addDays(1);
        }

        return workingDays;
    }

    public static Integer calculateDaysBetweenDatesMinusOneDayForEachMonth(Date dateFrom, Date dateTo) {
        validateDates(dateFrom, dateTo);

        Integer totalDaysBetweenDates = dateFrom.daysBetween(dateTo);
        Integer monthsBetweenDates = ((dateTo.year() - dateFrom.year()) * 12) + (dateTo.month() - dateFrom.month());
        Integer daysToSubtract = monthsBetweenDates;

        return totalDaysBetweenDates - daysToSubtract;
    }

    private static String getDayOfWeek(Date givenDate) {
        DateTime givenDateToDateTime = (DateTime)givenDate;
        return givenDateToDateTime.format('EEEE');
    }

    private static void validateDates(Date dateFrom, Date dateTo) {
        if (dateFrom == null || dateTo == null) {
            throw new IllegalArgumentException('Both dates must be provided.');
        }
        if (dateFrom > dateTo) {
            throw new IllegalArgumentException('The dateFrom value must not be later than dateTo.');
        }
    }
    
}