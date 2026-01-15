// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_limit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppLimitModelAdapter extends TypeAdapter<AppLimitModel> {
  @override
  final typeId = 0;

  @override
  AppLimitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppLimitModel(
      packageName: fields[0] as String,
      dailyLimitMinutes: (fields[1] as num).toInt(),
      warningThreshold: fields[2] == null ? 0.8 : (fields[2] as num).toDouble(),
      cooldownMinutes: fields[3] == null ? 5 : (fields[3] as num).toInt(),
      isEnabled: fields[4] == null ? true : fields[4] as bool,
      lastWarningShown: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AppLimitModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.dailyLimitMinutes)
      ..writeByte(2)
      ..write(obj.warningThreshold)
      ..writeByte(3)
      ..write(obj.cooldownMinutes)
      ..writeByte(4)
      ..write(obj.isEnabled)
      ..writeByte(5)
      ..write(obj.lastWarningShown);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLimitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
