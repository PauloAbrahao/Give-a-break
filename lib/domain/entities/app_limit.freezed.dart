// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_limit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppLimit {

 String get packageName; Duration get dailyLimit; double get warningThreshold; int get dailyLimitOpenings; bool get isEnabled;
/// Create a copy of AppLimit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppLimitCopyWith<AppLimit> get copyWith => _$AppLimitCopyWithImpl<AppLimit>(this as AppLimit, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppLimit&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.dailyLimit, dailyLimit) || other.dailyLimit == dailyLimit)&&(identical(other.warningThreshold, warningThreshold) || other.warningThreshold == warningThreshold)&&(identical(other.dailyLimitOpenings, dailyLimitOpenings) || other.dailyLimitOpenings == dailyLimitOpenings)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,packageName,dailyLimit,warningThreshold,dailyLimitOpenings,isEnabled);

@override
String toString() {
  return 'AppLimit(packageName: $packageName, dailyLimit: $dailyLimit, warningThreshold: $warningThreshold, dailyLimitOpenings: $dailyLimitOpenings, isEnabled: $isEnabled)';
}


}

/// @nodoc
abstract mixin class $AppLimitCopyWith<$Res>  {
  factory $AppLimitCopyWith(AppLimit value, $Res Function(AppLimit) _then) = _$AppLimitCopyWithImpl;
@useResult
$Res call({
 String packageName, Duration dailyLimit, double warningThreshold, int dailyLimitOpenings, bool isEnabled
});




}
/// @nodoc
class _$AppLimitCopyWithImpl<$Res>
    implements $AppLimitCopyWith<$Res> {
  _$AppLimitCopyWithImpl(this._self, this._then);

  final AppLimit _self;
  final $Res Function(AppLimit) _then;

/// Create a copy of AppLimit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packageName = null,Object? dailyLimit = null,Object? warningThreshold = null,Object? dailyLimitOpenings = null,Object? isEnabled = null,}) {
  return _then(_self.copyWith(
packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,dailyLimit: null == dailyLimit ? _self.dailyLimit : dailyLimit // ignore: cast_nullable_to_non_nullable
as Duration,warningThreshold: null == warningThreshold ? _self.warningThreshold : warningThreshold // ignore: cast_nullable_to_non_nullable
as double,dailyLimitOpenings: null == dailyLimitOpenings ? _self.dailyLimitOpenings : dailyLimitOpenings // ignore: cast_nullable_to_non_nullable
as int,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppLimit].
extension AppLimitPatterns on AppLimit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppLimit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppLimit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppLimit value)  $default,){
final _that = this;
switch (_that) {
case _AppLimit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppLimit value)?  $default,){
final _that = this;
switch (_that) {
case _AppLimit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String packageName,  Duration dailyLimit,  double warningThreshold,  int dailyLimitOpenings,  bool isEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppLimit() when $default != null:
return $default(_that.packageName,_that.dailyLimit,_that.warningThreshold,_that.dailyLimitOpenings,_that.isEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String packageName,  Duration dailyLimit,  double warningThreshold,  int dailyLimitOpenings,  bool isEnabled)  $default,) {final _that = this;
switch (_that) {
case _AppLimit():
return $default(_that.packageName,_that.dailyLimit,_that.warningThreshold,_that.dailyLimitOpenings,_that.isEnabled);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String packageName,  Duration dailyLimit,  double warningThreshold,  int dailyLimitOpenings,  bool isEnabled)?  $default,) {final _that = this;
switch (_that) {
case _AppLimit() when $default != null:
return $default(_that.packageName,_that.dailyLimit,_that.warningThreshold,_that.dailyLimitOpenings,_that.isEnabled);case _:
  return null;

}
}

}

/// @nodoc


class _AppLimit implements AppLimit {
  const _AppLimit({required this.packageName, required this.dailyLimit, this.warningThreshold = 0.8, this.dailyLimitOpenings = 0, this.isEnabled = true});
  

@override final  String packageName;
@override final  Duration dailyLimit;
@override@JsonKey() final  double warningThreshold;
@override@JsonKey() final  int dailyLimitOpenings;
@override@JsonKey() final  bool isEnabled;

/// Create a copy of AppLimit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppLimitCopyWith<_AppLimit> get copyWith => __$AppLimitCopyWithImpl<_AppLimit>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppLimit&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.dailyLimit, dailyLimit) || other.dailyLimit == dailyLimit)&&(identical(other.warningThreshold, warningThreshold) || other.warningThreshold == warningThreshold)&&(identical(other.dailyLimitOpenings, dailyLimitOpenings) || other.dailyLimitOpenings == dailyLimitOpenings)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,packageName,dailyLimit,warningThreshold,dailyLimitOpenings,isEnabled);

@override
String toString() {
  return 'AppLimit(packageName: $packageName, dailyLimit: $dailyLimit, warningThreshold: $warningThreshold, dailyLimitOpenings: $dailyLimitOpenings, isEnabled: $isEnabled)';
}


}

/// @nodoc
abstract mixin class _$AppLimitCopyWith<$Res> implements $AppLimitCopyWith<$Res> {
  factory _$AppLimitCopyWith(_AppLimit value, $Res Function(_AppLimit) _then) = __$AppLimitCopyWithImpl;
@override @useResult
$Res call({
 String packageName, Duration dailyLimit, double warningThreshold, int dailyLimitOpenings, bool isEnabled
});




}
/// @nodoc
class __$AppLimitCopyWithImpl<$Res>
    implements _$AppLimitCopyWith<$Res> {
  __$AppLimitCopyWithImpl(this._self, this._then);

  final _AppLimit _self;
  final $Res Function(_AppLimit) _then;

/// Create a copy of AppLimit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packageName = null,Object? dailyLimit = null,Object? warningThreshold = null,Object? dailyLimitOpenings = null,Object? isEnabled = null,}) {
  return _then(_AppLimit(
packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,dailyLimit: null == dailyLimit ? _self.dailyLimit : dailyLimit // ignore: cast_nullable_to_non_nullable
as Duration,warningThreshold: null == warningThreshold ? _self.warningThreshold : warningThreshold // ignore: cast_nullable_to_non_nullable
as double,dailyLimitOpenings: null == dailyLimitOpenings ? _self.dailyLimitOpenings : dailyLimitOpenings // ignore: cast_nullable_to_non_nullable
as int,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
