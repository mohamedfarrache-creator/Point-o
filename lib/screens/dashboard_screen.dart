import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/attendance_provider.dart';
import '../utils/formatters.dart';
import '../widgets/summary_card.dart';
import 'qr_scanner_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final attendance = context.watch<AttendanceProvider>();
    if (attendance.isLoading) return const Center(child: CircularProgressIndicator());
    final log = attendance.todayLog;
    final active = attendance.activeLog;
    final normal = log == null ? 0 : attendance.normalFor(log);
    final overtime = log == null ? 0 : attendance.overtimeFor(log);
    final now = DateTime.now();
    return ListView(padding: const EdgeInsets.all(20), children: [
      Center(child: Column(children: [
        Text(dateLabel(now), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          width: 154, height: 154,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .12), blurRadius: 18)]),
          child: Center(child: Text(clock(now), style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700))),
        ),
      ])),
      const SizedBox(height: 28),
      FilledButton.icon(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(58), backgroundColor: active == null ? const Color(0xFF36B995) : const Color(0xFFE36A5C)),
        onPressed: attendance.toggleAttendance,
        icon: Icon(active == null ? Icons.login : Icons.logout),
        label: Text(active == null ? 'Pointer l’entrée' : 'Pointer la sortie', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QrScannerScreen())),
        icon: const Icon(Icons.qr_code_scanner), label: const Text('Scanner un QR code'),
      ),
      const SizedBox(height: 28),
      Text("Aujourd’hui", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      if (active != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text('En cours depuis ${clock(active.checkInTime)}', style: const TextStyle(color: Color(0xFF168469), fontWeight: FontWeight.w600))),
      SummaryCard(label: 'Heures normales', value: hoursMinutes(normal), icon: Icons.schedule, color: const Color(0xFF14558B)),
      const SizedBox(height: 12),
      SummaryCard(label: 'Heures supplémentaires', value: hoursMinutes(overtime), icon: Icons.add_alarm, color: const Color(0xFFE58D31)),
    ]);
  }
}
