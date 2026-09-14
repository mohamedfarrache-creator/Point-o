import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/time_log.dart';
import '../providers/attendance_provider.dart';
import '../utils/formatters.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final attendance = context.watch<AttendanceProvider>();
    final logs = attendance.logs;
    return Column(children: [
      Expanded(child: logs.isEmpty ? const Center(child: Text('Aucun pointage enregistré.')) : ListView.separated(
        padding: const EdgeInsets.all(16), itemCount: logs.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) => _LogTile(log: logs[index], attendance: attendance),
      )),
      SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 12), child: FilledButton.icon(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simulation : le rapport serait exporté au format CSV.'))),
        icon: const Icon(Icons.file_download_outlined), label: const Text('Exporter le rapport'),
      ))),
    ]);
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.log, required this.attendance}); final TimeLog log; final AttendanceProvider attendance;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Expanded(child: Text(dateLabel(log.date), style: const TextStyle(fontWeight: FontWeight.bold))), Icon(log.isOpen ? Icons.timelapse : Icons.check_circle, size: 19, color: log.isOpen ? Colors.orange : const Color(0xFF36B995))]),
    const Divider(height: 22),
    Row(children: [Expanded(child: _stamp('Entrée', clock(log.checkInTime))), Expanded(child: _stamp('Sortie', log.checkOutTime == null ? 'En cours' : clock(log.checkOutTime!))), _stamp('Total', hoursMinutes(attendance.elapsedFor(log)))]),
  ])));
  Widget _stamp(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))]);
}
