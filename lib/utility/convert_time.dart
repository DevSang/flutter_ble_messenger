import 'package:intl/intl.dart';

class ConvertTime {
    String getTime(int targetDate) {
        DateTime converted = new DateTime.fromMicrosecondsSinceEpoch(targetDate*1000);
        String time = DateFormat('yyyy.MM.dd  h:mma').format(converted);
        return time;
    }
}