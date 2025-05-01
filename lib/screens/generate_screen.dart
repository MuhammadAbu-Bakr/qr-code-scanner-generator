import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/qr_history.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  final TextEditingController _controller = TextEditingController();
  String qrData = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateQR() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        qrData = _controller.text;
      });
      // Save to history
      final box = Hive.box<QRHistory>('qrHistory');
      box.add(QRHistory(
        content: qrData,
        timestamp: DateTime.now(),
        type: 'generated',
        isGenerated: true,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate QR Code'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Enter text or URL',
                      hintText: 'Type something to generate QR code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.text_fields, color: colorScheme.primary),
                    ),
                    maxLines: 3,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _generateQR,
                icon: const Icon(Icons.qr_code),
                label: const Text('Generate QR Code'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
              const SizedBox(height: 30),
              if (qrData.isNotEmpty)
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        QrImageView(
                          data: qrData,
                          size: 200,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'QR Code Generated!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          qrData,
                          style: TextStyle(
                            color: colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}