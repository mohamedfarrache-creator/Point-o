import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/salary_config.dart';

/// SharedPreferences is used for lightweight salary preferences, separately
/// from operational SQLite attendance records.
class SalaryProvider extends ChangeNotifier {
  SalaryConfig _config = const SalaryConfig();
  bool _loading = true;
  SalaryConfig get config => _config;
  bool get isLoading => _loading;
  static const _keys = ['hourlyRate', 'cnssRate', 'cnssCeiling', 'cnssIpeRate', 'mutualRate', 'cimrRate', 'advance', 'cosDeduction'];

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    double getValue(String key, double fallback) => prefs.getDouble('salary.$key') ?? fallback;
    _config = SalaryConfig(
      hourlyRate: getValue(_keys[0], 30.82), cnssRate: getValue(_keys[1], .0429), cnssCeiling: getValue(_keys[2], 6000),
      cnssIpeRate: getValue(_keys[3], .0019), mutualRate: getValue(_keys[4], .0144), cimrRate: getValue(_keys[5], 0),
      advance: getValue(_keys[6], 0), cosDeduction: getValue(_keys[7], 0),
    );
    _loading = false;
    notifyListeners();
  }

  Future<void> save(SalaryConfig config) async {
    _config = config;
    final prefs = await SharedPreferences.getInstance();
    final values = [config.hourlyRate, config.cnssRate, config.cnssCeiling, config.cnssIpeRate, config.mutualRate, config.cimrRate, config.advance, config.cosDeduction];
    for (var index = 0; index < _keys.length; index++) { await prefs.setDouble('salary.${_keys[index]}', values[index]); }
    notifyListeners();
  }
}
