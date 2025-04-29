import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';  
import 'dart:ui' as ui;
import 'dart:io';
import 'package:hive/hive.dart';
import '../models/qr_history.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  final TextEditingController _textController = TextEditingController();
  String _qrData = 'Enter text to generate QR code';
  String _qrType = 'text';
  final GlobalKey globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter text or URL',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _qrData = value.isNotEmpty ? value : 'Enter text to generate QR code';
                  if (Uri.tryParse(value)?.hasAbsolutePath ?? false) {
                    _qrType = 'url';
                  } else {
                    _qrType = 'text';
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            Container(
              key: globalKey,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: QrImageView(
                data: _qrData,
                version: QrVersions.auto,
                size: 200,
                gapless: false,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton(
                  onPressed: _saveToHistory,
                  child: const Text('Save to History'),
                ),
                ElevatedButton(
                  onPressed: _saveQRCode,
                  child: const Text('Save to Gallery'),
                ),
                ElevatedButton(
                  onPressed: _shareQRCode,
                  child: const Text('Share'),
                ),
                if (_qrType == 'wifi')
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _qrData = 'WIFI:T:WPA;S:MyNetwork;P:mypassword;;';
                        _textController.text = _qrData;
                      });
                    },
                    child: const Text('Use WiFi Template'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveQRCode() async {
    try {
      final boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/qr_code.png';
      final File imageFile = File(imagePath);
      await imageFile.writeAsBytes(bytes);
      
      await ImageGallerySaver.saveFile(imagePath);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR code saved to gallery')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving QR code: $e')),
      );
    }
  }

  Future<void> _shareQRCode() async {
    try {
      final boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/qr_code_share.png';
      final File imageFile = File(imagePath);
      await imageFile.writeAsBytes(bytes);
      
      await Share.shareFiles([imagePath], text: 'Check out this QR code');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing QR code: $e')),
      );
    }
  }

  void _saveToHistory() {
    if (_qrData.isNotEmpty && _qrData != 'Enter text to generate QR code') {
      final historyBox = Hive.box<QRHistory>('qrHistory');
      historyBox.add(QRHistory(
        content: _qrData,
        isGenerated: true,
        timestamp: DateTime.now(),
        type: _qrType,
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR code saved to history')),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}