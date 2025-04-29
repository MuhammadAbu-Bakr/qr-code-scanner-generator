import 'package:hive/hive.dart';

part 'qr_history.g.dart';

@HiveType(typeId: 0)
class QRHistory extends HiveObject {
  @HiveField(0)
  final String content;
  
  @HiveField(1)
  final bool isGenerated;
  
  @HiveField(2)
  final DateTime timestamp;
  
  @HiveField(3)
  final String type;

  QRHistory({
    required this.content,
    required this.isGenerated,
    required this.timestamp,
    required this.type,
  });
}