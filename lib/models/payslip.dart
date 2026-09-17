import 'salary_config.dart';
import 'time_log.dart';

/// Immutable salary breakdown. The IR method applies Morocco's annual
/// progressive brackets to monthly taxable income annualised over 12 months.
class Payslip {
  const Payslip({required this.normalHours, required this.overtimeHours, required this.holidayHours, required this.config});
  final double normalHours;
  final double overtimeHours;
  final double holidayHours;
  final SalaryConfig config;

  /// Builds the payroll base from attendance sessions. Callers can provide
  /// live minute resolvers so an open shift is also reflected in the preview.
  factory Payslip.fromLogs({
    required List<TimeLog> logs,
    required SalaryConfig config,
    int Function(TimeLog log)? normalMinutes,
    int Function(TimeLog log)? overtimeMinutes,
  }) {
    var normal = 0.0;
    var overtime = 0.0;
    var holiday = 0.0;
    for (final log in logs) {
      final normalHours = (normalMinutes?.call(log) ?? log.normalMinutes) / 60;
      if (isFixedMoroccanHoliday(log.date)) {
        holiday += normalHours;
      } else {
        normal += normalHours;
      }
      overtime += (overtimeMinutes?.call(log) ?? log.overtimeMinutes) / 60;
    }
    return Payslip(normalHours: normal, overtimeHours: overtime, holidayHours: holiday, config: config);
  }

  /// Fixed national dates. Movable religious holidays are intentionally kept
  /// outside the default list until configured by the employer.
  static bool isFixedMoroccanHoliday(DateTime day) => const {
        (1, 1), (5, 1), (7, 30), (8, 14), (8, 20), (8, 21), (11, 6), (11, 18),
      }.contains((day.month, day.day));

  double get normalGross => normalHours * config.hourlyRate;
  double get overtimeGross => overtimeHours * config.hourlyRate * 1.5;
  /// Work performed on a holiday is paid at 200% of the hourly rate.
  double get holidayGross => holidayHours * config.hourlyRate * 2;
  double get gross => normalGross + overtimeGross + holidayGross;
  double get cappedGross => gross.clamp(0, config.cnssCeiling).toDouble();
  double get cnss => cappedGross * config.cnssRate;
  double get cnssIpe => cappedGross * config.cnssIpeRate;
  double get mutual => gross * config.mutualRate;
  double get cimr => gross * config.cimrRate;
  double get contributions => cnss + cnssIpe + mutual + cimr;
  double get taxableNet => (gross - contributions).clamp(0, double.infinity).toDouble();

  /// Moroccan annual progressive IR. The result is annual tax divided by 12.
  double get incomeTax {
    final annual = taxableNet * 12;
    final brackets = <({double upTo, double rate})>[
      (upTo: 30000, rate: 0), (upTo: 50000, rate: .10), (upTo: 60000, rate: .20),
      (upTo: 80000, rate: .30), (upTo: 180000, rate: .34), (upTo: double.infinity, rate: .38),
    ];
    var previous = 0.0;
    var tax = 0.0;
    for (final bracket in brackets) {
      final portion = (annual.clamp(previous, bracket.upTo) - previous).clamp(0, double.infinity);
      tax += portion * bracket.rate;
      previous = bracket.upTo;
      if (annual <= bracket.upTo) break;
    }
    return tax / 12;
  }

  /// Rounding is applied only at the displayed net payable stage.
  double get netPay => (taxableNet - incomeTax - config.advance - config.cosDeduction).roundToDouble();
}
