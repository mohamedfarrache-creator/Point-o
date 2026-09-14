import 'package:intl/intl.dart';

String hoursMinutes(int minutes) => '${minutes ~/ 60}h ${minutes % 60}min';
String clock(DateTime value) => DateFormat('HH:mm').format(value);
String dateLabel(DateTime value) => DateFormat('EEEE d MMMM', 'fr_FR').format(value);
String monthLabel(DateTime value) => DateFormat('MMMM yyyy', 'fr_FR').format(value);
