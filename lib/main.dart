import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'data/database_helper.dart';
import 'providers/attendance_provider.dart';
import 'screens/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
  runApp(const PointeoApp());
}

class PointeoApp extends StatelessWidget {
  const PointeoApp({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => AttendanceProvider(DatabaseHelper.instance)..initialize(),
        child: MaterialApp(
          title: 'Pointéo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF14558B), brightness: Brightness.light),
            scaffoldBackgroundColor: const Color(0xFFF4F7FA),
            cardTheme: const CardThemeData(elevation: 0, color: Colors.white, margin: EdgeInsets.zero),
            inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
          ),
          home: const HomeShell(),
        ),
      );
}
