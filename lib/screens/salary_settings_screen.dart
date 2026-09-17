import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/salary_config.dart';
import '../providers/salary_provider.dart';

class SalarySettingsScreen extends StatefulWidget { const SalarySettingsScreen({super.key}); @override State<SalarySettingsScreen> createState() => _SalarySettingsScreenState(); }
class _SalarySettingsScreenState extends State<SalarySettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = List.generate(8, (_) => TextEditingController());
  bool _initialized = false;
  @override void dispose() { for (final controller in _controllers) { controller.dispose(); } super.dispose(); }
  @override Widget build(BuildContext context) {
    final provider = context.watch<SalaryProvider>();
    if (!_initialized && !provider.isLoading) { _setValues(provider.config); _initialized = true; }
    if (provider.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(appBar: AppBar(title: const Text('Paramètres salaire')), body: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Ces paramètres sont enregistrés uniquement sur cet appareil.', style: TextStyle(color: Colors.black54)), const SizedBox(height: 18),
      Form(key: _formKey, child: Column(children: [
        _field(0, 'Taux horaire', 'MAD'), _field(1, 'Taux CNSS', '%'), _field(2, 'Plafond CNSS', 'MAD'),
        _field(3, 'Taux CNSS-IPE', '%'), _field(4, 'Taux Mutuelle', '%'), _field(5, 'Taux CIMR (optionnel)', '%'),
        _field(6, 'Montant Acompte', 'MAD'), _field(7, 'Déduction COS', 'MAD'),
      ])), const SizedBox(height: 8),
      FilledButton(onPressed: () async { if (!(_formKey.currentState?.validate() ?? false)) return; final messenger = ScaffoldMessenger.of(context); await provider.save(_toConfig()); if (!mounted) return; messenger.showSnackBar(const SnackBar(content: Text('Paramètres salaire enregistrés.'))); }, child: const Text('Enregistrer')),
    ]));
  }
  Widget _field(int index, String label, String unit) => Padding(padding: const EdgeInsets.only(bottom: 14), child: TextFormField(controller: _controllers[index], keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: label, suffixText: unit), validator: (value) => double.tryParse((value ?? '').replaceAll(',', '.')) == null ? 'Valeur numérique requise' : null));
  void _setValues(SalaryConfig c) { final values = [c.hourlyRate, c.cnssRate * 100, c.cnssCeiling, c.cnssIpeRate * 100, c.mutualRate * 100, c.cimrRate * 100, c.advance, c.cosDeduction]; for (var i = 0; i < values.length; i++) { _controllers[i].text = values[i].toString(); } }
  SalaryConfig _toConfig() { double value(int i) => double.parse(_controllers[i].text.replaceAll(',', '.')); return SalaryConfig(hourlyRate: value(0), cnssRate: value(1) / 100, cnssCeiling: value(2), cnssIpeRate: value(3) / 100, mutualRate: value(4) / 100, cimrRate: value(5) / 100, advance: value(6), cosDeduction: value(7)); }
}
