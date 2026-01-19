import 'package:freezed_annotation/freezed_annotation.dart';

part 'routine.freezed.dart';

@freezed
sealed class Routine with _$Routine {
  const factory Routine({
    required String id,
    required String name,
    String? description,
    required Set<int> days,
    required Set<String> appPackages,
    @Default(true) bool isEnabled,
    @Default(false) bool isArchived,
    DateTime? createdAt,
  }) = _Routine;
}
