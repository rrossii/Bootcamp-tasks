public class TestSchedule implements Schedulable {
    public void execute(SchedulableContext ctx) {
        ContactInfoToCSVBatch csvBatch = new ContactInfoToCSVBatch();
        Id csvBatchId = Database.executeBatch(csvBatch, 10);
    }
}