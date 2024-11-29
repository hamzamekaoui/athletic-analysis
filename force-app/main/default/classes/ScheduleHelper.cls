public class ScheduleHelper {
    private static final Integer HOURS_BETWEEN_MATCHES = 3;
    private Datetime currentTime;

    public ScheduleHelper(Datetime startTime) {
        this.currentTime = startTime;
    }

    public Datetime getNextSchedule() {
        Datetime nextTime = currentTime;
        currentTime = currentTime.addHours(HOURS_BETWEEN_MATCHES);
        return nextTime;
    }
}