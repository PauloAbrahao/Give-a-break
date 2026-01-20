// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_usage.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppUsage {

 String get packageName; Duration get totalTimeInForeground; DateTime get lastTimeUsed; DateTime get date; int get openCount;
/// Create a copy of AppUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUsageCopyWith<AppUsage> get copyWith => _$AppUsageCopyWithImpl<AppUsage>(this as AppUsage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUsage&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.totalTimeInForeground, totalTimeInForeground) || other.totalTimeInForeground == totalTimeInForeground)&&(identical(other.lastTimeUsed, lastTimeUsed) || other.lastTimeUsed == lastTimeUsed)&&(identical(other.date, date) || other.date == date)&&(identical(other.openCount, openCount) || other.openCount == openCount));
}


@override
int get hashCode => Object.hash(runtimeType,packageName,totalTimeInForeground,lastTimeUsed,date,openCount);

@override
String toString() {
  return 'AppUsage(packageName: $packageName, totalTimeInForeground: $totalTimeInForeground, lastTimeUsed: $lastTimeUsed, date: $date, openCount: $openCount)';
}


}

/// @nodoc
abstract mixin class $AppUsageCopyWith<$Res>  {
  factory $AppUsageCopyWith(AppUsage value, $Res Function(AppUsage) _then) = _$AppUsageCopyWithImpl;
@useResult
$Res call({
 String packageName, Duration totalTimeInForeground, DateTime lastTimeUsed, DateTime date, int openCount
});




}
/// @nodoc
class _$AppUsageCopyWithImpl<$Res>
    implements $AppUsageCopyWith<$Res> {
  _$AppUsageCopyWithImpl(this._self, this._then);

  final AppUsage _self;
  final $Res Function(AppUsage) _then;

/// Create a copy of AppUsage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packageName = null,Object? totalTimeInForeground = null,Object? lastTimeUsed = null,Object? date = null,Object? openCount = null,}) {
  return _then(_self.copyWith(
packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,totalTimeInForeground: null == totalTimeInForeground ? _self.totalTimeInForeground : totalTimeInForeground // ignore: cast_nullable_to_non_nullable
as Duration,lastTimeUsed: null == lastTimeUsed ? _self.lastTimeUsed : lastTimeUsed // ignore: cast_nullable_to_non_nullable
as DateTime,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,openCount: null == openCount ? _self.openCount : openCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUsage].
extension AppUsagePatterns on AppUsage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUsage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUsage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUsage value)  $default,){
final _that = this;
switch (_that) {
case _AppUsage():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUsage value)?  $default,){
final _that = this;
switch (_that) {
case _AppUsage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String packageName,  Duration totalTimeInForeground,  DateTime lastTimeUsed,  DateTime date,  int openCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUsage() when $default != null:
return $default(_that.packageName,_that.totalTimeInForeground,_that.lastTimeUsed,_that.date,_that.openCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String packageName,  Duration totalTimeInForeground,  DateTime lastTimeUsed,  DateTime date,  int openCount)  $default,) {final _that = this;
switch (_that) {
case _AppUsage():
return $default(_that.packageName,_that.totalTimeInForeground,_that.lastTimeUsed,_that.date,_that.openCount);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String packageName,  Duration totalTimeInForeground,  DateTime lastTimeUsed,  DateTime date,  int openCount)?  $default,) {final _that = this;
switch (_that) {
case _AppUsage() when $default != null:
return $default(_that.packageName,_that.totalTimeInForeground,_that.lastTimeUsed,_that.date,_that.openCount);case _:
  return null;

}
}

}

/// @nodoc


class _AppUsage implements AppUsage {
  const _AppUsage({required this.packageName, required this.totalTimeInForeground, required this.lastTimeUsed, required this.date, this.openCount = 0});
  

@override final  String packageName;
@override final  Duration totalTimeInForeground;
@override final  DateTime lastTimeUsed;
@override final  DateTime date;
@override@JsonKey() final  int openCount;

/// Create a copy of AppUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUsageCopyWith<_AppUsage> get copyWith => __$AppUsageCopyWithImpl<_AppUsage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUsage&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.totalTimeInForeground, totalTimeInForeground) || other.totalTimeInForeground == totalTimeInForeground)&&(identical(other.lastTimeUsed, lastTimeUsed) || other.lastTimeUsed == lastTimeUsed)&&(identical(other.date, date) || other.date == date)&&(identical(other.openCount, openCount) || other.openCount == openCount));
}


@override
int get hashCode => Object.hash(runtimeType,packageName,totalTimeInForeground,lastTimeUsed,date,openCount);

@override
String toString() {
  return 'AppUsage(packageName: $packageName, totalTimeInForeground: $totalTimeInForeground, lastTimeUsed: $lastTimeUsed, date: $date, openCount: $openCount)';
}


}

/// @nodoc
abstract mixin class _$AppUsageCopyWith<$Res> implements $AppUsageCopyWith<$Res> {
  factory _$AppUsageCopyWith(_AppUsage value, $Res Function(_AppUsage) _then) = __$AppUsageCopyWithImpl;
@override @useResult
$Res call({
 String packageName, Duration totalTimeInForeground, DateTime lastTimeUsed, DateTime date, int openCount
});




}
/// @nodoc
class __$AppUsageCopyWithImpl<$Res>
    implements _$AppUsageCopyWith<$Res> {
  __$AppUsageCopyWithImpl(this._self, this._then);

  final _AppUsage _self;
  final $Res Function(_AppUsage) _then;

/// Create a copy of AppUsage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packageName = null,Object? totalTimeInForeground = null,Object? lastTimeUsed = null,Object? date = null,Object? openCount = null,}) {
  return _then(_AppUsage(
packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,totalTimeInForeground: null == totalTimeInForeground ? _self.totalTimeInForeground : totalTimeInForeground // ignore: cast_nullable_to_non_nullable
as Duration,lastTimeUsed: null == lastTimeUsed ? _self.lastTimeUsed : lastTimeUsed // ignore: cast_nullable_to_non_nullable
as DateTime,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,openCount: null == openCount ? _self.openCount : openCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
