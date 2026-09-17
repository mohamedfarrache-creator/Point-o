import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pay_period.dart';
import '../models/payslip.dart';
import '../providers/attendance_provider.dart';
import '../providers/salary_provider.dart';

class PayslipScreen extends StatelessWidget {
  const PayslipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final attendance = context.watch<AttendanceProvider>();
    final salary = context.watch<SalaryProvider>();
    if (attendance.isLoading || salary.isLoading) return const Center(child: CircularProgressIndicator());
    final period = PayPeriod.forMonth(DateTime.now());
    final logs = attendance.logsForPayPeriod(DateTime.now());
    final payslip = Payslip.fromLogs(logs: logs, config: salary.config, normalMinutes: attendance.normalFor, overtimeMinutes: attendance.overtimeFor);
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(color: Theme.of(context).colorScheme.primary, child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('BULLETIN DE PAIE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 8), Text('Période : ${_date(period.start)} – ${_date(period.end)}', style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 16), const Text('NET À PAYER', style: TextStyle(color: Colors.white70)),
        Text('${payslip.netPay.toStringAsFixed(2)} MAD', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
      ]))),
      const SizedBox(height: 14),
      _Section(title: 'Gains', rows: [
        ('Heures normales (${payslip.normalHours.toStringAsFixed(2)} h)', payslip.normalGross),
        ('Heures supplémentaires × 1,5 (${payslip.overtimeHours.toStringAsFixed(2)} h)', payslip.overtimeGross),
        ('Jours fériés travaillés × 2 (${payslip.holidayHours.toStringAsFixed(2)} h)', payslip.holidayGross),
        ('Brut total', payslip.gross),
      ]),
      const SizedBox(height: 14),
      _Section(title: 'Retenues', rows: [
        ('CNSS (${(salary.config.cnssRate * 100).toStringAsFixed(2)} %, plafond ${salary.config.cnssCeiling.toStringAsFixed(0)} MAD)', -payslip.cnss),
        ('CNSS-IPE (${(salary.config.cnssIpeRate * 100).toStringAsFixed(2)} %)', -payslip.cnssIpe),
        ('Mutuelle (${(salary.config.mutualRate * 100).toStringAsFixed(2)} %)', -payslip.mutual),
        ('CIMR (${(salary.config.cimrRate * 100).toStringAsFixed(2)} %)', -payslip.cimr),
        ('Net imposable', payslip.taxableNet),
        ('IR progressif annualisé', -payslip.incomeTax),
        ('Acompte', -salary.config.advance),
        ('Déduction COS', -salary.config.cosDeduction),
      ]),
      const SizedBox(height: 12),
      const Text('Estimation indicative : vérifiez les taux et le barème en vigueur auprès de votre service paie.', style: TextStyle(fontSize: 12, color: Colors.black54)),
    ]);
  }

  String _date(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});
  final String title;
  final List<(String, double)> rows;
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), const Divider(height: 24),
    for (final row in rows) Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [
      Expanded(child: Text(row.$1, style: TextStyle(fontWeight: row.$1 == 'Brut total' || row.$1 == 'Net imposable' ? FontWeight.bold : FontWeight.normal))),
      Text('${row.$2.toStringAsFixed(2)} MAD', style: TextStyle(fontWeight: row.$1 == 'Brut total' || row.$1 == 'Net imposable' ? FontWeight.bold : FontWeight.normal)),
    ])),
  ])));
}
