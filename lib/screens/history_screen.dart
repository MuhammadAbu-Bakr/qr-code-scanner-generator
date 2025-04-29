// screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/qr_history.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Box<QRHistory> historyBox;
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    historyBox = Hive.box<QRHistory>('qrHistory');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _filterType = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'url', child: Text('URLs')),
              const PopupMenuItem(value: 'wifi', child: Text('WiFi')),
              const PopupMenuItem(value: 'contact', child: Text('Contacts')),
              const PopupMenuItem(value: 'text', child: Text('Text')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text('Are you sure you want to delete all history?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        historyBox.clear();
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<QRHistory>('qrHistory').listenable(),
        builder: (context, Box<QRHistory> box, _) {
          final items = box.values
              .where((item) => _filterType == 'all' || item.type == _filterType)
              .toList()
              .reversed
              .toList();
              
          if (items.isEmpty) {
            return Center(
              child: Text(_filterType == 'all' 
                  ? 'No history yet' 
                  : 'No $_filterType items in history'),
            );
          }
          
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Dismissible(
                key: Key(item.timestamp.toString()),
                onDismissed: (direction) {
                  box.delete(box.keyAt(box.values.toList().indexOf(item)));
                },
                background: Container(color: Colors.red),
                child: Card(
                  child: ListTile(
                    leading: _buildTypeIcon(item.type),
                    title: Text(
                      item.content.length > 30
                          ? '${item.content.substring(0, 30)}...'
                          : item.content,
                    ),
                    subtitle: Text(
                      '${DateFormat('MMM dd, yyyy - hh:mm a').format(item.timestamp)} • ${item.type.toUpperCase()}',
                    ),
                    trailing: Icon(
                      item.isGenerated ? Icons.qr_code : Icons.qr_code_scanner,
                      color: Colors.blue,
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('${item.type.toUpperCase()} QR Code'),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SelectableText(item.content),
                                if (item.type == 'wifi') const SizedBox(height: 10),
                                if (item.type == 'wifi')
                                  ElevatedButton(
                                    onPressed: () => _connectToWifi(item.content),
                                    child: const Text('Connect to WiFi'),
                                  ),
                              ],
                            ),
                          ),
                          actions: [
                            if (item.type == 'url')
                              TextButton(
                                onPressed: () => _launchURL(item.content),
                                child: const Text('Open Link'),
                              ),
                            TextButton(
                              onPressed: () async {
                                await Clipboard.setData(ClipboardData(text: item.content));
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
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTypeIcon(String type) {
    switch (type) {
      case 'url':
        return const Icon(Icons.link, color: Colors.blue);
      case 'wifi':
        return const Icon(Icons.wifi, color: Colors.green);
      case 'contact':
        return const Icon(Icons.contact_page, color: Colors.purple);
      default:
        return const Icon(Icons.text_fields, color: Colors.orange);
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _connectToWifi(String wifiConfig) {
    // Platform-specific implementation needed
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('WiFi connection feature requires platform implementation')),
    );
  }
}