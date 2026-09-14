import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/database_helper.dart';
import '../models/time_log.dart';

class AttendanceProvider extends ChangeNotifier {
  AttendanceProvider(this._database);
  final DatabaseHelper _database;
  static const _standardHoursKey = 'standard_hours';
  static const _targetHoursKey = 'target_hours';

  List<TimeLog> _logs = [];
  int _standardDailyMinutes = 8 * 60;
  int _monthlyTargetMinutes = 160 * 60;
  bool _loading = true;
  Timer? _clockTicker;

  List<TimeLog> get logs => List.unmodifiable(_logs);
  int get standardDailyMinutes => _standardDailyMinutes;
  int get monthlyTargetMinutes => _monthlyTargetMinutes;
  bool get isLoading => _loading;
  TimeLog? get activeLog {
    for (final log in _logs) { if (log.isOpen) return log; }
    return null;
  }
  TimeLog? get todayLog {
    final today = _day(DateTime.now());
    for (final log in _logs) { if (_sameDay(log.date, today)) return log; }
    return null;
  }

  Future<void> initialize() async {
    _standardDailyMinutes = int.tryParse(await _database.getSetting(_standardHoursKey) ?? '') ?? 480;
    _monthlyTargetMinutes = int.tryParse(await _database.getSetting(_targetHoursKey) ?? '') ?? 9600;
    _logs = await _database.allLogs();
    _loading = false;
    _clockTicker = Timer.periodic(const Duration(seconds: 1), (_) => notifyListeners());
    notifyListeners();
  }

  /// Creates or closes the current attendance session; UI updates immediately.
  Future<void> toggleAttendance() async {
    final now = DateTime.now();
    final current = activeLog;
    if (current == null) {
      final draft = TimeLog(date: _day(now), checkInTime: now);
      final id = await _database.insertLog(draft);
      _logs = [draft.copyWith(id: id), ..._logs];
    } else {
      final elapsed = now.difference(current.checkInTime).inMinutes;
      final completed = current.copyWith(
        checkOutTime: now,
        normalMinutes: elapsed.clamp(0, _standardDailyMinutes).toInt(),
        overtimeMinutes: (elapsed - _standardDailyMinutes).clamp(0, 1 << 30).toInt(),
        status: AttendanceStatus.completed,
      );
      await _database.updateLog(completed);
      _logs = _logs.map((log) => log.id == completed.id ? completed : log).toList();
    }
    notifyListeners();
  }

  int elapsedFor(TimeLog log) => log.isOpen ? DateTime.now().difference(log.checkInTime).inMinutes : log.totalMinutes;
  int normalFor(TimeLog log) => elapsedFor(log).clamp(0, _standardDailyMinutes).toInt();
  int overtimeFor(TimeLog log) => (elapsedFor(log) - _standardDailyMinutes).clamp(0, 1 << 30).toInt();

  Future<void> saveSettings({required int standardHours, required int targetHours}) async {
    _standardDailyMinutes = standardHours * 60;
    _monthlyTargetMinutes = targetHours * 60;
    await _database.setSetting(_standardHoursKey, _standardDailyMinutes.toString());
    await _database.setSetting(_targetHoursKey, _monthlyTargetMinutes.toString());
    notifyListeners();
  }

  List<TimeLog> logsForMonth(DateTime month) => _logs.where((log) => log.date.year == month.year && log.date.month == month.month).toList();
  int normalMinutesForMonth(DateTime month) => logsForMonth(month).fold(0, (sum, log) => sum + normalFor(log));
  int overtimeMinutesForMonth(DateTime month) => logsForMonth(month).fold(0, (sum, log) => sum + overtimeFor(log));

  static DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);
  static bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  void dispose() { _clockTicker?.cancel(); super.dispose(); }
}
