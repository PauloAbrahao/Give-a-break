// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_usage_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DailyUsageSummary {

 DateTime get date; Duration get totalScreenTime; List<AppUsage> get appUsages; int get appsUsed;
/// Create a copy of DailyUsageSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyUsageSummaryCopyWith<DailyUsageSummary> get copyWith => _$DailyUsageSummaryCopyWithImpl<DailyUsageSummary>(this as DailyUsageSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyUsageSummary&&(identical(other.date, date) || other.date == date)&&(identical(other.totalScreenTime, totalScreenTime) || other.totalScreenTime == totalScreenTime)&&const DeepCollectionEquality().equals(other.appUsages, appUsages)&&(identical(other.appsUsed, appsUsed) || other.appsUsed == appsUsed));
}


@override
int get hashCode => Object.hash(runtimeType,date,totalScreenTime,const DeepCollectionEquality().hash(appUsages),appsUsed);

@override
String toString() {
  return 'DailyUsageSummary(date: $date, totalScreenTime: $totalScreenTime, appUsages: $appUsages, appsUsed: $appsUsed)';
}


}

/// @nodoc
abstract mixin class $DailyUsageSummaryCopyWith<$Res>  {
  factory $DailyUsageSummaryCopyWith(DailyUsageSummary value, $Res Function(DailyUsageSummary) _then) = _$DailyUsageSummaryCopyWithImpl;
@useResult
$Res call({
 DateTime date, Duration totalScreenTime, List<AppUsage> appUsages, int appsUsed
});




}
/// @nodoc
class _$DailyUsageSummaryCopyWithImpl<$Res>
    implements $DailyUsageSummaryCopyWith<$Res> {
  _$DailyUsageSummaryCopyWithImpl(this._self, this._then);

  final DailyUsageSummary _self;
  final $Res Function(DailyUsageSummary) _then;

/// Create a copy of DailyUsageSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? totalScreenTime = null,Object? appUsages = null,Object? appsUsed = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,totalScreenTime: null == totalScreenTime ? _self.totalScreenTime : totalScreenTime // ignore: cast_nullable_to_non_nullable
as Duration,appUsages: null == appUsages ? _self.appUsages : appUsages // ignore: cast_nullable_to_non_nullable
as List<AppUsage>,appsUsed: null == appsUsed ? _self.appsUsed : appsUsed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyUsageSummary].
extension DailyUsageSummaryPatterns on DailyUsageSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyUsageSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyUsageSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyUsageSummary value)  $default,){
final _that = this;
switch (_that) {
case _DailyUsageSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyUsageSummary value)?  $default,){
final _that = this;
switch (_that) {
case _DailyUsageSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  Duration totalScreenTime,  List<AppUsage> appUsages,  int appsUsed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyUsageSummary() when $default != null:
return $default(_that.date,_that.totalScreenTime,_that.appUsages,_that.appsUsed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  Duration totalScreenTime,  List<AppUsage> appUsages,  int appsUsed)  $default,) {final _that = this;
switch (_that) {
case _DailyUsageSummary():
return $default(_that.date,_that.totalScreenTime,_that.appUsages,_that.appsUsed);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  Duration totalScreenTime,  List<AppUsage> appUsages,  int appsUsed)?  $default,) {final _that = this;
switch (_that) {
case _DailyUsageSummary() when $default != null:
return $default(_that.date,_that.totalScreenTime,_that.appUsages,_that.appsUsed);case _:
  return null;

}
}

}

/// @nodoc


class _DailyUsageSummary implements DailyUsageSummary {
  const _DailyUsageSummary({required this.date, required this.totalScreenTime, required final  List<AppUsage> appUsages, required this.appsUsed}): _appUsages = appUsages;
  

@override final  DateTime date;
@override final  Duration totalScreenTime;
 final  List<AppUsage> _appUsages;
@override List<AppUsage> get appUsages {
  if (_appUsages is EqualUnmodifiableListView) return _appUsages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_appUsages);
}

@override final  int appsUsed;

/// Create a copy of DailyUsageSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyUsageSummaryCopyWith<_DailyUsageSummary> get copyWith => __$DailyUsageSummaryCopyWithImpl<_DailyUsageSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyUsageSummary&&(identical(other.date, date) || other.date == date)&&(identical(other.totalScreenTime, totalScreenTime) || other.totalScreenTime == totalScreenTime)&&const DeepCollectionEquality().equals(other._appUsages, _appUsages)&&(identical(other.appsUsed, appsUsed) || other.appsUsed == appsUsed));
}


@override
int get hashCode => Object.hash(runtimeType,date,totalScreenTime,const DeepCollectionEquality().hash(_appUsages),appsUsed);

@override
String toString() {
  return 'DailyUsageSummary(date: $date, totalScreenTime: $totalScreenTime, appUsages: $appUsages, appsUsed: $appsUsed)';
}


}

/// @nodoc
abstract mixin class _$DailyUsageSummaryCopyWith<$Res> implements $DailyUsageSummaryCopyWith<$Res> {
  factory _$DailyUsageSummaryCopyWith(_DailyUsageSummary value, $Res Function(_DailyUsageSummary) _then) = __$DailyUsageSummaryCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, Duration totalScreenTime, List<AppUsage> appUsages, int appsUsed
});




}
/// @nodoc
class __$DailyUsageSummaryCopyWithImpl<$Res>
    implements _$DailyUsageSummaryCopyWith<$Res> {
  __$DailyUsageSummaryCopyWithImpl(this._self, this._then);

  final _DailyUsageSummary _self;
  final $Res Function(_DailyUsageSummary) _then;

/// Create a copy of DailyUsageSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? totalScreenTime = null,Object? appUsages = null,Object? appsUsed = null,}) {
  return _then(_DailyUsageSummary(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,totalScreenTime: null == totalScreenTime ? _self.totalScreenTime : totalScreenTime // ignore: cast_nullable_to_non_nullable
as Duration,appUsages: null == appUsages ? _self._appUsages : appUsages // ignore: cast_nullable_to_non_nullable
as List<AppUsage>,appsUsed: null == appsUsed ? _self.appsUsed : appsUsed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
