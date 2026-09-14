import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/time_log.dart';
import '../providers/attendance_provider.dart';
import '../utils/formatters.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final attendance = context.watch<AttendanceProvider>();
    final logs = attendance.logsForMonth(_focusedDay);
    final normal = attendance.normalMinutesForMonth(_focusedDay);
    final overtime = attendance.overtimeMinutesForMonth(_focusedDay);
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: TableCalendar<TimeLog>(
            locale: 'fr_FR',
            firstDay: DateTime(2020), lastDay: DateTime(2100), focusedDay: _focusedDay,
            availableCalendarFormats: const {CalendarFormat.month: 'Mois'}, calendarFormat: CalendarFormat.month,
            eventLoader: (day) => logs.where((log) => isSameDay(log.date, day)).toList(),
            onPageChanged: (day) => setState(() => _focusedDay = day),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .45), shape: BoxShape.circle),
              markerDecoration: const BoxDecoration(color: Color(0xFF36B995), shape: BoxShape.circle),
              markersMaxCount: 1,
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final dayLogs = logs.where((log) => isSameDay(log.date, day)).toList();
                if (dayLogs.isEmpty) return null;
                final hasOvertime = dayLogs.any((log) => attendance.overtimeFor(log) > 0);
                return Container(margin: const EdgeInsets.all(5), alignment: Alignment.center,
                  decoration: BoxDecoration(color: (hasOvertime ? const Color(0xFFE58D31) : const Color(0xFF36B995)).withValues(alpha: .20), borderRadius: BorderRadius.circular(9)), child: Text('${day.day}'));
              },
            ),
          ),
        ),
      ),
      const SizedBox(height: 18),
      Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(monthLabel(_focusedDay), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _line('Jours travaillés', '${logs.length}'),
        _line('Heures normales', hoursMinutes(normal)),
        _line('Heures supplémentaires', hoursMinutes(overtime), color: const Color(0xFFE58D31)),
      ]))),
      const SizedBox(height: 10),
      const Row(children: [ _Legend(color: Color(0xFF36B995), label: 'Journée travaillée'), SizedBox(width: 16), _Legend(color: Color(0xFFE58D31), label: 'Avec heures supp.') ]),
    ]);
  }

  Widget _line(String label, String value, {Color? color}) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color))]));
}

class _Legend extends StatelessWidget { const _Legend({required this.color, required this.label}); final Color color; final String label;
  @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 5), Text(label, style: const TextStyle(fontSize: 11))]); }
