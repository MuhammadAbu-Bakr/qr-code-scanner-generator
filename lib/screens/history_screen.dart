
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/qr_history.dart';
import 'package:timeago/timeago.dart' as timeago;

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text('Are you sure you want to clear all history?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        final box = Hive.box<QRHistory>('qrHistory');
                        box.clear();
                        Navigator.pop(context);
                      },
                      child: Text('Clear', style: TextStyle(color: colorScheme.error)),
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
        builder: (context, box, _) {
          if (box.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No History Yet',
                    style: TextStyle(
                      fontSize: 20,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final history = box.getAt(box.length - 1 - index) as QRHistory;
              return Dismissible(
                key: Key(history.timestamp.toString()),
                background: Container(
                  color: colorScheme.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  box.deleteAt(box.length - 1 - index);
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: history.type == 'scanned' 
                          ? colorScheme.primary.withOpacity(0.1)
                          : colorScheme.secondary.withOpacity(0.1),
                      child: Icon(
                        history.type == 'scanned' 
                            ? Icons.qr_code_scanner
                            : Icons.qr_code,
                        color: history.type == 'scanned'
                            ? colorScheme.primary
                            : colorScheme.secondary,
                      ),
                    ),
                    title: Text(
                      history.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${history.type.toUpperCase()} • ${timeago.format(history.timestamp)}',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.content_copy),
                      onPressed: () {
                       
                      },
                      tooltip: 'Copy to clipboard',
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}