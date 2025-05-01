import 'package:flutter/material.dart';
import 'scan_screen.dart';
import 'generate_screen.dart';
import 'history_screen.dart';
import 'gallery_scan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner & Generator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildFeatureCard(
                      context,
                      'Scan QR Code',
                      Icons.qr_code_scanner,
                      colorScheme.primary,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ScanScreen()),
                      ),
                    ),
                    _buildFeatureCard(
                      context,
                      'Generate QR Code',
                      Icons.qr_code,
                      colorScheme.secondary,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GenerateScreen()),
                      ),
                    ),
                    _buildFeatureCard(
                      context,
                      'Scan from Gallery',
                      Icons.photo_library,
                      colorScheme.tertiary,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GalleryScanScreen()),
                      ),
                    ),
                    _buildFeatureCard(
                      context,
                      'History',
                      Icons.history,
                      colorScheme.surfaceVariant,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HistoryScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}