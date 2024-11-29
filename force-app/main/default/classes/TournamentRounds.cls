public without sharing class TournamentRounds {

    public final static String COMPLETED = 'COMPLETED';

    public enum Round {
        ROUND_1,
        ROUND_2,
        ROUND_3,
        ROUND_OF_16,
        QUARTER_FINALS,
        SEMI_FINALS,
        FINALS
    }

    private static final Map<String, Round> STR_TO_ROUND_MAP = new Map<String, Round> {
        '1' => Round.ROUND_1,
        '2' => Round.ROUND_2,
        '3' => Round.ROUND_3,
        'Round of 16' => Round.ROUND_OF_16,
        'Quarter Finals' => Round.QUARTER_FINALS,
        'Semi Finals' => Round.SEMI_FINALS,
        'Finals' => Round.FINALS
    };

    private static final Map<Round, String> ROUND_TO_STR_MAP = new Map<Round, String> {
            Round.ROUND_1 => '1',
            Round.ROUND_2 => '2',
            Round.ROUND_3 => '3',
            Round.ROUND_OF_16 => 'Round of 16',
            Round.QUARTER_FINALS => 'Quarter Finals',
            Round.SEMI_FINALS => 'Semi Finals',
            Round.FINALS => 'Finals'
    };

    public static String getNextRound(String currentRound) {
        Round current = STR_TO_ROUND_MAP.get(currentRound);

        if (!Round.FINALS.equals(current)) {
            List<Round> rounds = Round.values();
            Integer currentIndex = current.ordinal();
            return ROUND_TO_STR_MAP.get(rounds.get(currentIndex + 1));
        } else {
            return COMPLETED;
        }
    }

    public static Round valueOf(String value) {
        return STR_TO_ROUND_MAP.get(value);
    }

    public static String toString(Round value) {
        return ROUND_TO_STR_MAP.get(value);
    }

    public static List<String> getKnockoutStageRoundNames() {
        return new List<String> {'Round of 16', 'Quarter Finals', 'Semi Finals', 'Finals'};
    }

    public static List<String> getGroupStageRoundNames() {
        return new List<String> {'1', '2', '3'};
    }

    public static Boolean isGroupStage(String stringValue) {
        Round value = valueOf(stringValue);
        return (Round.ROUND_1 == value) || (Round.ROUND_2 == value) || (Round.ROUND_3 == value);
    }

    public static Boolean isFinal(String stringValue) {
        Round value = valueOf(stringValue);
        return Round.FINALS == value;
    }

    public static Boolean isThirdRound(String stringValue) {
        Round value = valueOf(stringValue);
        return Round.ROUND_3 == value;
    }

    public static Boolean isKnockoutStage(String stringValue) {
        return !isGroupStage(stringValue);
    }
}