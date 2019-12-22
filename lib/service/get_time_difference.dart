import 'package:timeago/timeago.dart' as timeago;

class GetTimeDifference {

    static String timeDifference(int date) {
        final DateTime now = new DateTime.now();
        final DateTime targetDate = new DateTime.fromMicrosecondsSinceEpoch(date*1000);
        final Duration timeDiff = now.difference(targetDate);

        return timeago.format(now.subtract(timeDiff), locale: 'ko');
    }
}