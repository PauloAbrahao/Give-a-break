// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoutineModelAdapter extends TypeAdapter<RoutineModel> {
  @override
  final typeId = 3;

  @override
  RoutineModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoutineModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      days: (fields[3] as List).cast<int>(),
      appPackages: (fields[4] as List).cast<String>(),
      isEnabled: fields[5] == null ? true : fields[5] as bool,
      isArchived: fields[7] == null ? false : fields[7] as bool,
      createdAt: fields[6] as DateTime?,
      startTime: fields[8] as String?,
      endTime: fields[9] as String?,
      dailyLimitMinutes: fields[10] == null ? 0 : (fields[10] as num).toInt(),
      dailyLimitOpenings: fields[11] == null ? 0 : (fields[11] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, RoutineModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.days)
      ..writeByte(4)
      ..write(obj.appPackages)
      ..writeByte(5)
      ..write(obj.isEnabled)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.isArchived)
      ..writeByte(8)
      ..write(obj.startTime)
      ..writeByte(9)
      ..write(obj.endTime)
      ..writeByte(10)
      ..write(obj.dailyLimitMinutes)
      ..writeByte(11)
      ..write(obj.dailyLimitOpenings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
