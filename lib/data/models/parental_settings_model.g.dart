// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parental_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParentalSettingsModelAdapter extends TypeAdapter<ParentalSettingsModel> {
  @override
  final typeId = 1;

  @override
  ParentalSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ParentalSettingsModel(
      isEnabled: fields[0] == null ? false : fields[0] as bool,
      pinHash: fields[1] as String?,
      childModeEnabled: fields[2] == null ? false : fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ParentalSettingsModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.isEnabled)
      ..writeByte(1)
      ..write(obj.pinHash)
      ..writeByte(2)
      ..write(obj.childModeEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParentalSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
