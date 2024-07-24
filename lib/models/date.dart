import 'package:intl/intl.dart';

class CustomDateUtils {
  // Function to add ordinal suffix
  static String getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  // Function to format the date as '23rd July 2024'
  static String formatDate(DateTime date) {
    String day = DateFormat('d').format(date); // Day
    String month = DateFormat('MMMM').format(date); // Month
    String year = DateFormat('y').format(date); // Year

    // Get the ordinal suffix
    String suffix = getOrdinalSuffix(int.parse(day));

    // Create formatted date string
    return '$day$suffix of $month $year';
  }
}
