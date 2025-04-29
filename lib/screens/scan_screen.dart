import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../models/qr_history.dart';
import 'package:hive/hive.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  MobileScannerController cameraController = MobileScannerController();
  String? lastScanned;

  String _detectQRType(String content) {
    if (Uri.tryParse(content)?.hasAbsolutePath ?? false) return 'url';
    if (content.toLowerCase().startsWith('wifi:')) return 'wifi';
    if (content.contains('BEGIN:VCARD')) return 'contact';
    return 'text';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: cameraController,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null && barcode.rawValue != lastScanned) {
                lastScanned = barcode.rawValue;
                final qrType = _detectQRType(barcode.rawValue!);
                
                final historyBox = Hive.box<QRHistory>('qrHistory');
                historyBox.add(QRHistory(
                  content: barcode.rawValue!,
                  isGenerated: false,
                  timestamp: DateTime.now(),
                  type: qrType,
                ));

                _showResultDialog(barcode.rawValue!, qrType);
              }
            }
          },
        ),
        CustomPaint(
          painter: ScannerOverlay(),
          child: Container(),
        ),
      ],
    );
  }

  void _showResultDialog(String result, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Scanned ${type.toUpperCase()}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(result),
              if (type == 'wifi') const SizedBox(height: 10),
              if (type == 'wifi')
                ElevatedButton(
                  onPressed: () => _connectToWifi(result),
                  child: const Text('Connect to WiFi'),
                ),
            ],
          ),
        ),
        actions: [
          if (type == 'url')
            TextButton(
              onPressed: () => _launchURL(result),
              child: const Text('Open Link'),
            ),
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: result));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
              Navigator.pop(context);
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _connectToWifi(String wifiConfig) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('WiFi connection feature requires platform implementation')),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromPoints(Offset.zero, Offset(size.width, size.height)));

    final center = size.center(Offset.zero);
    const width = 250.0;
    const height = 250.0;
    final rect = Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    );

    path.addRect(rect);
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}