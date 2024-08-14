// lib/utils/temporal_timestamp_extension.dart

import 'package:amplify_flutter/amplify_flutter.dart';

extension TemporalTimestampExtension on TemporalTimestamp {
  /*DateTime getDateTime() {
    return DateTime.parse(this.toString());
  } */

  DateTime toDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(getSecondsSinceEpoch() * 1000);
  }

  int getSecondsSinceEpoch() {
    return int.parse(toString());
  }
}
