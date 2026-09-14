enum AttendanceStatus { open, completed }

/// An attendance session persisted locally. Durations are stored in minutes to
/// prevent floating point rounding errors in the database.
class TimeLog {
  const TimeLog({
    this.id,
    required this.date,
    required this.checkInTime,
    this.checkOutTime,
    this.normalMinutes = 0,
    this.overtimeMinutes = 0,
    this.status = AttendanceStatus.open,
  });

  final int? id;
  final DateTime date;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final int normalMinutes;
  final int overtimeMinutes;
  final AttendanceStatus status;

  bool get isOpen => status == AttendanceStatus.open;
  int get totalMinutes => normalMinutes + overtimeMinutes;

  TimeLog copyWith({
    int? id,
    DateTime? date,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    int? normalMinutes,
    int? overtimeMinutes,
    AttendanceStatus? status,
  }) =>
      TimeLog(
        id: id ?? this.id,
        date: date ?? this.date,
        checkInTime: checkInTime ?? this.checkInTime,
        checkOutTime: checkOutTime ?? this.checkOutTime,
        normalMinutes: normalMinutes ?? this.normalMinutes,
        overtimeMinutes: overtimeMinutes ?? this.overtimeMinutes,
        status: status ?? this.status,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'date': DateTime(date.year, date.month, date.day).toIso8601String(),
        'check_in': checkInTime.toIso8601String(),
        'check_out': checkOutTime?.toIso8601String(),
        'normal_minutes': normalMinutes,
        'overtime_minutes': overtimeMinutes,
        'status': status.name,
      };

  factory TimeLog.fromMap(Map<String, Object?> map) => TimeLog(
        id: map['id'] as int?,
        date: DateTime.parse(map['date']! as String),
        checkInTime: DateTime.parse(map['check_in']! as String),
        checkOutTime: map['check_out'] == null
            ? null
            : DateTime.parse(map['check_out']! as String),
        normalMinutes: map['normal_minutes'] as int? ?? 0,
        overtimeMinutes: map['overtime_minutes'] as int? ?? 0,
        status: AttendanceStatus.values.byName(
          map['status'] as String? ?? AttendanceStatus.open.name,
        ),
      );
}
