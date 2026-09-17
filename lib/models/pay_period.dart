/// The company pay period always closes on the 25th: 26 M-1 through 25 M.
class PayPeriod {
  const PayPeriod({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  /// Builds the period ending in [reference]'s calendar month.
  factory PayPeriod.forMonth(DateTime reference) => PayPeriod(
        start: DateTime(reference.year, reference.month - 1, 26),
        end: DateTime(reference.year, reference.month, 25, 23, 59, 59, 999),
      );

  bool includes(DateTime date) => !date.isBefore(start) && !date.isAfter(end);
}
