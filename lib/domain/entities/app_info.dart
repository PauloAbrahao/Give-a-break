import 'dart:typed_data';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_info.freezed.dart';

@freezed
sealed class AppInfo with _$AppInfo {
  const factory AppInfo({
    required String packageName,
    required String appName,
    Uint8List? icon,
    @Default(false) bool isSystemApp,
  }) = _AppInfo;
}
