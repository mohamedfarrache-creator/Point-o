/// Configurable employee payroll deductions. Rates are decimal values (4.29%
/// is represented by 0.0429) so calculations remain explicit and testable.
class SalaryConfig {
  const SalaryConfig({
    this.hourlyRate = 30.82,
    this.cnssRate = .0429,
    this.cnssCeiling = 6000,
    this.cnssIpeRate = .0019,
    this.mutualRate = .0144,
    this.cimrRate = 0,
    this.advance = 0,
    this.cosDeduction = 0,
  });

  final double hourlyRate;
  final double cnssRate;
  final double cnssCeiling;
  final double cnssIpeRate;
  final double mutualRate;
  final double cimrRate;
  final double advance;
  final double cosDeduction;

  SalaryConfig copyWith({double? hourlyRate, double? cnssRate, double? cnssCeiling, double? cnssIpeRate, double? mutualRate, double? cimrRate, double? advance, double? cosDeduction}) => SalaryConfig(
    hourlyRate: hourlyRate ?? this.hourlyRate, cnssRate: cnssRate ?? this.cnssRate, cnssCeiling: cnssCeiling ?? this.cnssCeiling,
    cnssIpeRate: cnssIpeRate ?? this.cnssIpeRate, mutualRate: mutualRate ?? this.mutualRate, cimrRate: cimrRate ?? this.cimrRate,
    advance: advance ?? this.advance, cosDeduction: cosDeduction ?? this.cosDeduction,
  );
}
