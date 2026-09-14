import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../providers/attendance_provider.dart';

/// QR validation can be connected to a company endpoint later. Currently a
/// successfully-read QR simply authorizes the same local check-in/out action.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});
  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _handled = false;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: const Text('Scanner QR Code'), backgroundColor: Colors.black, foregroundColor: Colors.white),
        body: Stack(fit: StackFit.expand, children: [
          MobileScanner(onDetect: (capture) async {
            if (_handled || capture.barcodes.isEmpty) return;
            _handled = true;
            final attendance = context.read<AttendanceProvider>();
            final navigator = Navigator.of(context);
            final messenger = ScaffoldMessenger.of(context);
            await attendance.toggleAttendance();
            if (!mounted) return;
            navigator.pop();
            messenger.showSnackBar(const SnackBar(content: Text('QR lu : pointage enregistré.')));
          }),
          Center(child: Container(width: 230, height: 230, decoration: BoxDecoration(border: Border.all(color: const Color(0xFF58D4B5), width: 4), borderRadius: BorderRadius.circular(18)))),
          const Positioned(left: 24, right: 24, bottom: 56, child: Text('Alignez le QR code dans le cadre pour pointer.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16))),
        ]),
      );
}
