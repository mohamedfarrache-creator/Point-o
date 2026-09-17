import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/attendance_provider.dart';
import 'salary_settings_screen.dart';

class SettingsScreen extends StatefulWidget { const SettingsScreen({super.key}); @override State<SettingsScreen> createState() => _SettingsScreenState(); }
class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _daily;
  late final TextEditingController _target;
  bool _initialized = false;
  @override void initState() { super.initState(); _daily = TextEditingController(); _target = TextEditingController(); }
  @override void dispose() { _daily.dispose(); _target.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final attendance = context.watch<AttendanceProvider>();
    if (!_initialized && !attendance.isLoading) { _daily.text = '${attendance.standardDailyMinutes ~/ 60}'; _target.text = '${attendance.monthlyTargetMinutes ~/ 60}'; _initialized = true; }
    return ListView(padding: const EdgeInsets.all(20), children: [
      const CircleAvatar(radius: 34, child: Icon(Icons.person, size: 36)), const SizedBox(height: 12), Center(child: Text('Mon profil', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))), const SizedBox(height: 28),
      Form(key: _formKey, child: Column(children: [
        TextFormField(controller: _daily, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Durée quotidienne standard', suffixText: 'heures', prefixIcon: Icon(Icons.schedule)), validator: _validHours), const SizedBox(height: 18),
        TextFormField(controller: _target, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Objectif par période', suffixText: 'heures', prefixIcon: Icon(Icons.flag_outlined)), validator: _validHours),
      ])),
      const SizedBox(height: 26), FilledButton(onPressed: () async { if (!(_formKey.currentState?.validate() ?? false)) return; await attendance.saveSettings(standardHours: int.parse(_daily.text), targetHours: int.parse(_target.text)); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Préférences enregistrées.'))); }, child: const Text('Enregistrer les préférences')),
      const SizedBox(height: 12), OutlinedButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SalarySettingsScreen())), icon: const Icon(Icons.payments_outlined), label: const Text('Paramètres salaire')),
      const SizedBox(height: 24), const Text('Les données de pointage et les réglages salaire restent enregistrés localement sur cet appareil.', style: TextStyle(color: Colors.black54)),
    ]);
  }
  String? _validHours(String? value) { final hours = int.tryParse(value ?? ''); return hours == null || hours < 1 || hours > 300 ? 'Saisissez un nombre d’heures valide.' : null; }
}
