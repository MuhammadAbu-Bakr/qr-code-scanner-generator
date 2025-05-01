import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/qr_history.dart';
import 'dart:io';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as mlkit;

class GalleryScanScreen extends StatelessWidget {
  const GalleryScanScreen({super.key});

  Future<void> _scanImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final inputImage = mlkit.InputImage.fromFilePath(image.path);
      final barcodeScanner = mlkit.BarcodeScanner();
      
      try {
        final List<mlkit.Barcode> barcodes = await barcodeScanner.processImage(inputImage);
        
        if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
          
          final box = Hive.box<QRHistory>('qrHistory');
          box.add(QRHistory(
            content: barcodes.first.rawValue!,
            timestamp: DateTime.now(),
            type: 'scanned',
            isGenerated: false,
          ));

          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('QR Code Found'),
                content: Text(barcodes.first.rawValue!),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No QR code found in the image')),
            );
          }
        }
      } finally {
        barcodeScanner.close();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning image: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan from Gallery'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Select an image containing a QR code',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _scanImage(context),
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose from Gallery'),
            ),
          ],
        ),
      ),
    );
  }
}