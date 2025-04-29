// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QRHistoryAdapter extends TypeAdapter<QRHistory> {
  @override
  final int typeId = 0;

  @override
  QRHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QRHistory(
      content: fields[0] as String,
      isGenerated: fields[1] as bool,
      timestamp: fields[2] as DateTime,
      type: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, QRHistory obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.content)
      ..writeByte(1)
      ..write(obj.isGenerated)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QRHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
