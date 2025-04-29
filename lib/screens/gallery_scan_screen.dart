import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:hive/hive.dart';
import '../models/qr_history.dart';

class GalleryScanScreen extends StatefulWidget {
  const GalleryScanScreen({super.key});

  @override
  State<GalleryScanScreen> createState() => _GalleryScanScreenState();
}

class _GalleryScanScreenState extends State<GalleryScanScreen> {
  String? _result;
  String? _error;
  MobileScannerController? _controller;

  Future<void> _pickAndScanImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        _controller?.dispose();
        _controller = MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.back,
          formats: [BarcodeFormat.qrCode],
        );

        setState(() {
          _result = null;
          _error = null;
        });

        setState(() {
          _result = null;
          _error = 'Please hold while scanning...';
        });

        final scannerWidget = MobileScanner(
          controller: _controller!,
          onDetect: (capture) {
            if (capture.barcodes.isNotEmpty) {
              final barcode = capture.barcodes.first;
              if (barcode.rawValue != null) {
                setState(() {
                  _result = barcode.rawValue;
                  _error = null;
                });
                
                final historyBox = Hive.box<QRHistory>('qrHistory');
                historyBox.add(QRHistory(
                  content: barcode.rawValue!,
                  isGenerated: false,
                  timestamp: DateTime.now(),
                  type: _detectQRType(barcode.rawValue!),
                ));
              } else {
                setState(() {
                  _result = null;
                  _error = 'No valid QR code content found';
                });
              }
            } else {
              setState(() {
                _result = null;
                _error = 'No QR code found in the image';
              });
            }
          },
        );

        final overlay = Overlay.of(context);
        final entry = OverlayEntry(
          builder: (context) => Positioned(
            left: -9999,
            child: SizedBox(
              width: 1,
              height: 1,
              child: scannerWidget,
            ),
          ),
        );
        
        overlay.insert(entry);

        await Future.delayed(const Duration(seconds: 1));
        await _controller?.start();
      }
    } catch (e) {
      setState(() {
        _result = null;
        _error = 'Error scanning image: $e';
      });
    }
  }

  String _detectQRType(String content) {
    if (Uri.tryParse(content)?.hasAbsolutePath ?? false) return 'url';
    if (content.toLowerCase().startsWith('wifi:')) return 'wifi';
    if (content.contains('BEGIN:VCARD')) return 'contact';
    return 'text';
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan from Gallery')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickAndScanImage,
              child: const Text('Pick Image from Gallery'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (_result != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Scanned Result: $_result'),
              ),
          ],
        ),
      ),
    );
  }
}