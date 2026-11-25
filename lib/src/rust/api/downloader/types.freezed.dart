// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'types.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DownloadManagerEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DownloadTaskSnapshot field0) taskUpdated,
    required TResult Function(DownloadTaskSnapshot field0)
        taskCompletedPendingAck,
    required TResult Function(String taskId) taskRemoved,
    required TResult Function(int restored, int cleaned) recoverySummary,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DownloadTaskSnapshot field0)? taskUpdated,
    TResult? Function(DownloadTaskSnapshot field0)? taskCompletedPendingAck,
    TResult? Function(String taskId)? taskRemoved,
    TResult? Function(int restored, int cleaned)? recoverySummary,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DownloadTaskSnapshot field0)? taskUpdated,
    TResult Function(DownloadTaskSnapshot field0)? taskCompletedPendingAck,
    TResult Function(String taskId)? taskRemoved,
    TResult Function(int restored, int cleaned)? recoverySummary,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DownloadManagerEvent_TaskUpdated value)
        taskUpdated,
    required TResult Function(
            DownloadManagerEvent_TaskCompletedPendingAck value)
        taskCompletedPendingAck,
    required TResult Function(DownloadManagerEvent_TaskRemoved value)
        taskRemoved,
    required TResult Function(DownloadManagerEvent_RecoverySummary value)
        recoverySummary,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DownloadManagerEvent_TaskUpdated value)? taskUpdated,
    TResult? Function(DownloadManagerEvent_TaskCompletedPendingAck value)?
        taskCompletedPendingAck,
    TResult? Function(DownloadManagerEvent_TaskRemoved value)? taskRemoved,
    TResult? Function(DownloadManagerEvent_RecoverySummary value)?
        recoverySummary,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DownloadManagerEvent_TaskUpdated value)? taskUpdated,
    TResult Function(DownloadManagerEvent_TaskCompletedPendingAck value)?
        taskCompletedPendingAck,
    TResult Function(DownloadManagerEvent_TaskRemoved value)? taskRemoved,
    TResult Function(DownloadManagerEvent_RecoverySummary value)?
        recoverySummary,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadManagerEventCopyWith<$Res> {
  factory $DownloadManagerEventCopyWith(DownloadManagerEvent value,
          $Res Function(DownloadManagerEvent) then) =
      _$DownloadManagerEventCopyWithImpl<$Res, DownloadManagerEvent>;
}

/// @nodoc
class _$DownloadManagerEventCopyWithImpl<$Res,
        $Val extends DownloadManagerEvent>
    implements $DownloadManagerEventCopyWith<$Res> {
  _$DownloadManagerEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$DownloadManagerEvent_TaskUpdatedImplCopyWith<$Res> {
  factory _$$DownloadManagerEvent_TaskUpdatedImplCopyWith(
          _$DownloadManagerEvent_TaskUpdatedImpl value,
          $Res Function(_$DownloadManagerEvent_TaskUpdatedImpl) then) =
      __$$DownloadManagerEvent_TaskUpdatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({DownloadTaskSnapshot field0});
}

/// @nodoc
class __$$DownloadManagerEvent_TaskUpdatedImplCopyWithImpl<$Res>
    extends _$DownloadManagerEventCopyWithImpl<$Res,
        _$DownloadManagerEvent_TaskUpdatedImpl>
    implements _$$DownloadManagerEvent_TaskUpdatedImplCopyWith<$Res> {
  __$$DownloadManagerEvent_TaskUpdatedImplCopyWithImpl(
      _$DownloadManagerEvent_TaskUpdatedImpl _value,
      $Res Function(_$DownloadManagerEvent_TaskUpdatedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$DownloadManagerEvent_TaskUpdatedImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as DownloadTaskSnapshot,
    ));
  }
}

/// @nodoc

class _$DownloadManagerEvent_TaskUpdatedImpl
    extends DownloadManagerEvent_TaskUpdated {
  const _$DownloadManagerEvent_TaskUpdatedImpl(this.field0) : super._();

  @override
  final DownloadTaskSnapshot field0;

  @override
  String toString() {
    return 'DownloadManagerEvent.taskUpdated(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadManagerEvent_TaskUpdatedImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadManagerEvent_TaskUpdatedImplCopyWith<
          _$DownloadManagerEvent_TaskUpdatedImpl>
      get copyWith => __$$DownloadManagerEvent_TaskUpdatedImplCopyWithImpl<
          _$DownloadManagerEvent_TaskUpdatedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DownloadTaskSnapshot field0) taskUpdated,
    required TResult Function(DownloadTaskSnapshot field0)
        taskCompletedPendingAck,
    required TResult Function(String taskId) taskRemoved,
    required TResult Function(int restored, int cleaned) recoverySummary,
  }) {
    return taskUpdated(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DownloadTaskSnapshot field0)? taskUpdated,
    TResult? Function(DownloadTaskSnapshot field0)? taskCompletedPendingAck,
    TResult? Function(String taskId)? taskRemoved,
    TResult? Function(int restored, int cleaned)? recoverySummary,
  }) {
    return taskUpdated?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DownloadTaskSnapshot field0)? taskUpdated,
    TResult Function(DownloadTaskSnapshot field0)? taskCompletedPendingAck,
    TResult Function(String taskId)? taskRemoved,
    TResult Function(int restored, int cleaned)? recoverySummary,
    required TResult orElse(),
  }) {
    if (taskUpdated != null) {
      return taskUpdated(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DownloadManagerEvent_TaskUpdated value)
        taskUpdated,
    required TResult Function(
            DownloadManagerEvent_TaskCompletedPendingAck value)
        taskCompletedPendingAck,
    required TResult Function(DownloadManagerEvent_TaskRemoved value)
        taskRemoved,
    required TResult Function(DownloadManagerEvent_RecoverySummary value)
        recoverySummary,
  }) {
    return taskUpdated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DownloadManagerEvent_TaskUpdated value)? taskUpdated,
    TResult? Function(DownloadManagerEvent_TaskCompletedPendingAck value)?
        taskCompletedPendingAck,
    TResult? Function(DownloadManagerEvent_TaskRemoved value)? taskRemoved,
    TResult? Function(DownloadManagerEvent_RecoverySummary value)?
        recoverySummary,
  }) {
    return taskUpdated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DownloadManagerEvent_TaskUpdated value)? taskUpdated,
    TResult Function(DownloadManagerEvent_TaskCompletedPendingAck value)?
        taskCompletedPendingAck,
    TResult Function(DownloadManagerEvent_TaskRemoved value)? taskRemoved,
    TResult Function(DownloadManagerEvent_RecoverySummary value)?
        recoverySummary,
    required TResult orElse(),
  }) {
    if (taskUpdated != null) {
      return taskUpdated(this);
    }
    return orElse();
  }
}

abstract class DownloadManagerEvent_TaskUpdated extends DownloadManagerEvent {
  const factory DownloadManagerEvent_TaskUpdated(
          final DownloadTaskSnapshot field0) =
      _$DownloadManagerEvent_TaskUpdatedImpl;
  const DownloadManagerEvent_TaskUpdated._() : super._();

  DownloadTaskSnapshot get field0;
  @JsonKey(ignore: true)
  _$$DownloadManagerEvent_TaskUpdatedImplCopyWith<
          _$DownloadManagerEvent_TaskUpdatedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DownloadManagerEvent_TaskCompletedPendingAckImplCopyWith<
    $Res> {
  factory _$$DownloadManagerEvent_TaskCompletedPendingAckImplCopyWith(
          _$DownloadManagerEvent_TaskCompletedPendingAckImpl value,
          $Res Function(_$DownloadManagerEvent_TaskCompletedPendingAckImpl)
              then) =
      __$$DownloadManagerEvent_TaskCompletedPendingAckImplCopyWithImpl<$Res>;
  @useResult
  $Res call({DownloadTaskSnapshot field0});
}

/// @nodoc
class __$$DownloadManagerEvent_TaskCompletedPendingAckImplCopyWithImpl<$Res>
    extends _$DownloadManagerEventCopyWithImpl<$Res,
        _$DownloadManagerEvent_TaskCompletedPendingAckImpl>
    implements
        _$$DownloadManagerEvent_TaskCompletedPendingAckImplCopyWith<$Res> {
  __$$DownloadManagerEvent_TaskCompletedPendingAckImplCopyWithImpl(
      _$DownloadManagerEvent_TaskCompletedPendingAckImpl _value,
      $Res Function(_$DownloadManagerEvent_TaskCompletedPendingAckImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$DownloadManagerEvent_TaskCompletedPendingAckImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as DownloadTaskSnapshot,
    ));
  }
}

/// @nodoc

class _$DownloadManagerEvent_TaskCompletedPendingAckImpl
    extends DownloadManagerEvent_TaskCompletedPendingAck {
  const _$DownloadManagerEvent_TaskCompletedPendingAckImpl(this.field0)
      : super._();

  @override
  final DownloadTaskSnapshot field0;

  @override
  String toString() {
    return 'DownloadManagerEvent.taskCompletedPendingAck(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadManagerEvent_TaskCompletedPendingAckImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadManagerEvent_TaskCompletedPendingAckImplCopyWith<
          _$DownloadManagerEvent_TaskCompletedPendingAckImpl>
      get copyWith =>
          __$$DownloadManagerEvent_TaskCompletedPendingAckImplCopyWithImpl<
                  _$DownloadManagerEvent_TaskCompletedPendingAckImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DownloadTaskSnapshot field0) taskUpdated,
    required TResult Function(DownloadTaskSnapshot field0)
        taskCompletedPendingAck,
    required TResult Function(String taskId) taskRemoved,
    required TResult Function(int restored, int cleaned) recoverySummary,
  }) {
    return taskCompletedPendingAck(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DownloadTaskSnapshot field0)? taskUpdated,
    TResult? Function(DownloadTaskSnapshot field0)? taskCompletedPendingAck,
    TResult? Function(String taskId)? taskRemoved,
    TResult? Function(int restored, int cleaned)? recoverySummary,
  }) {
    return taskCompletedPendingAck?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DownloadTaskSnapshot field0)? taskUpdated,
    TResult Function(DownloadTaskSnapshot field0)? taskCompletedPendingAck,
    TResult Function(String taskId)? taskRemoved,
    TResult Function(int restored, int cleaned)? recoverySummary,
    required TResult orElse(),
  }) {
    if (taskCompletedPendingAck != null) {
      return taskCompletedPendingAck(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DownloadManagerEvent_TaskUpdated value)
        taskUpdated,
    required TResult Function(
            DownloadManagerEvent_TaskCompletedPendingAck value)
        taskCompletedPendingAck,
    required TResult Function(DownloadManagerEvent_TaskRemoved value)
        taskRemoved,
    required TResult Function(DownloadManagerEvent_RecoverySummary value)
        recoverySummary,
  }) {
    return taskCompletedPendingAck(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DownloadManagerEvent_TaskUpdated value)? taskUpdated,
    TResult? Function(DownloadManagerEvent_TaskCompletedPendingAck value)?
        taskCompletedPendingAck,
    TResult? Function(DownloadManagerEvent_TaskRemoved value)? taskRemoved,
    TResult? Function(DownloadManagerEvent_RecoverySummary value)?
        recoverySummary,
  }) {
    return taskCompletedPendingAck?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DownloadManagerEvent_TaskUpdated value)? taskUpdated,
    TResult Function(DownloadManagerEvent_TaskCompletedPendingAck value)?
        taskCompletedPendingAck,
    TResult Function(DownloadManagerEvent_TaskRemoved value)? taskRemoved,
    TResult Function(DownloadManagerEvent_RecoverySummary value)?
        recoverySummary,
    required TResult orElse(),
  }) {
    if (taskCompletedPendingAck != null) {
      return taskCompletedPendingAck(this);
    }
    return orElse();
  }
}

abstract class DownloadManagerEvent_TaskCompletedPendingAck
    extends DownloadManagerEvent {
  const factory DownloadManagerEvent_TaskCompletedPendingAck(
          final DownloadTaskSnapshot field0) =
      _$DownloadManagerEvent_TaskCompletedPendingAckImpl;
  const DownloadManagerEvent_TaskCompletedPendingAck._() : super._();

  DownloadTaskSnapshot get field0;
  @JsonKey(ignore: true)
  _$$DownloadManagerEvent_TaskCompletedPendingAckImplCopyWith<
          _$DownloadManagerEvent_TaskCompletedPendingAckImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DownloadManagerEvent_TaskRemovedImplCopyWith<$Res> {
  factory _$$DownloadManagerEvent_TaskRemovedImplCopyWith(
          _$DownloadManagerEvent_TaskRemovedImpl value,
          $Res Function(_$DownloadManagerEvent_TaskRemovedImpl) then) =
      __$$DownloadManagerEvent_TaskRemovedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String taskId});
}

/// @nodoc
class __$$DownloadManagerEvent_TaskRemovedImplCopyWithImpl<$Res>
    extends _$DownloadManagerEventCopyWithImpl<$Res,
        _$DownloadManagerEvent_TaskRemovedImpl>
    implements _$$DownloadManagerEvent_TaskRemovedImplCopyWith<$Res> {
  __$$DownloadManagerEvent_TaskRemovedImplCopyWithImpl(
      _$DownloadManagerEvent_TaskRemovedImpl _value,
      $Res Function(_$DownloadManagerEvent_TaskRemovedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taskId = null,
  }) {
    return _then(_$DownloadManagerEvent_TaskRemovedImpl(
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$DownloadManagerEvent_TaskRemovedImpl
    extends DownloadManagerEvent_TaskRemoved {
  const _$DownloadManagerEvent_TaskRemovedImpl({required this.taskId})
      : super._();

  @override
  final String taskId;

  @override
  String toString() {
    return 'DownloadManagerEvent.taskRemoved(taskId: $taskId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadManagerEvent_TaskRemovedImpl &&
            (identical(other.taskId, taskId) || other.taskId == taskId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, taskId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadManagerEvent_TaskRemovedImplCopyWith<
          _$DownloadManagerEvent_TaskRemovedImpl>
      get copyWith => __$$DownloadManagerEvent_TaskRemovedImplCopyWithImpl<
          _$DownloadManagerEvent_TaskRemovedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DownloadTaskSnapshot field0) taskUpdated,
    required TResult Function(DownloadTaskSnapshot field0)
        taskCompletedPendingAck,
    required TResult Function(String taskId) taskRemoved,
    required TResult Function(int restored, int cleaned) recoverySummary,
  }) {
    return taskRemoved(taskId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DownloadTaskSnapshot field0)? taskUpdated,
    TResult? Function(DownloadTaskSnapshot field0)? taskCompletedPendingAck,
    TResult? Function(String taskId)? taskRemoved,
    TResult? Function(int restored, int cleaned)? recoverySummary,
  }) {
    return taskRemoved?.call(taskId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DownloadTaskSnapshot field0)? taskUpdated,
    TResult Function(DownloadTaskSnapshot field0)? taskCompletedPendingAck,
    TResult Function(String taskId)? taskRemoved,
    TResult Function(int restored, int cleaned)? recoverySummary,
    required TResult orElse(),
  }) {
    if (taskRemoved != null) {
      return taskRemoved(taskId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DownloadManagerEvent_TaskUpdated value)
        taskUpdated,
    required TResult Function(
            DownloadManagerEvent_TaskCompletedPendingAck value)
        taskCompletedPendingAck,
    required TResult Function(DownloadManagerEvent_TaskRemoved value)
        taskRemoved,
    required TResult Function(DownloadManagerEvent_RecoverySummary value)
        recoverySummary,
  }) {
    return taskRemoved(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DownloadManagerEvent_TaskUpdated value)? taskUpdated,
    TResult? Function(DownloadManagerEvent_TaskCompletedPendingAck value)?
        taskCompletedPendingAck,
    TResult? Function(DownloadManagerEvent_TaskRemoved value)? taskRemoved,
    TResult? Function(DownloadManagerEvent_RecoverySummary value)?
        recoverySummary,
  }) {
    return taskRemoved?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DownloadManagerEvent_TaskUpdated value)? taskUpdated,
    TResult Function(DownloadManagerEvent_TaskCompletedPendingAck value)?
        taskCompletedPendingAck,
    TResult Function(DownloadManagerEvent_TaskRemoved value)? taskRemoved,
    TResult Function(DownloadManagerEvent_RecoverySummary value)?
        recoverySummary,
    required TResult orElse(),
  }) {
    if (taskRemoved != null) {
      return taskRemoved(this);
    }
    return orElse();
  }
}

abstract class DownloadManagerEvent_TaskRemoved extends DownloadManagerEvent {
  const factory DownloadManagerEvent_TaskRemoved(
      {required final String taskId}) = _$DownloadManagerEvent_TaskRemovedImpl;
  const DownloadManagerEvent_TaskRemoved._() : super._();

  String get taskId;
  @JsonKey(ignore: true)
  _$$DownloadManagerEvent_TaskRemovedImplCopyWith<
          _$DownloadManagerEvent_TaskRemovedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DownloadManagerEvent_RecoverySummaryImplCopyWith<$Res> {
  factory _$$DownloadManagerEvent_RecoverySummaryImplCopyWith(
          _$DownloadManagerEvent_RecoverySummaryImpl value,
          $Res Function(_$DownloadManagerEvent_RecoverySummaryImpl) then) =
      __$$DownloadManagerEvent_RecoverySummaryImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int restored, int cleaned});
}

/// @nodoc
class __$$DownloadManagerEvent_RecoverySummaryImplCopyWithImpl<$Res>
    extends _$DownloadManagerEventCopyWithImpl<$Res,
        _$DownloadManagerEvent_RecoverySummaryImpl>
    implements _$$DownloadManagerEvent_RecoverySummaryImplCopyWith<$Res> {
  __$$DownloadManagerEvent_RecoverySummaryImplCopyWithImpl(
      _$DownloadManagerEvent_RecoverySummaryImpl _value,
      $Res Function(_$DownloadManagerEvent_RecoverySummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? restored = null,
    Object? cleaned = null,
  }) {
    return _then(_$DownloadManagerEvent_RecoverySummaryImpl(
      restored: null == restored
          ? _value.restored
          : restored // ignore: cast_nullable_to_non_nullable
              as int,
      cleaned: null == cleaned
          ? _value.cleaned
          : cleaned // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$DownloadManagerEvent_RecoverySummaryImpl
    extends DownloadManagerEvent_RecoverySummary {
  const _$DownloadManagerEvent_RecoverySummaryImpl(
      {required this.restored, required this.cleaned})
      : super._();

  @override
  final int restored;
  @override
  final int cleaned;

  @override
  String toString() {
    return 'DownloadManagerEvent.recoverySummary(restored: $restored, cleaned: $cleaned)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadManagerEvent_RecoverySummaryImpl &&
            (identical(other.restored, restored) ||
                other.restored == restored) &&
            (identical(other.cleaned, cleaned) || other.cleaned == cleaned));
  }

  @override
  int get hashCode => Object.hash(runtimeType, restored, cleaned);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadManagerEvent_RecoverySummaryImplCopyWith<
          _$DownloadManagerEvent_RecoverySummaryImpl>
      get copyWith => __$$DownloadManagerEvent_RecoverySummaryImplCopyWithImpl<
          _$DownloadManagerEvent_RecoverySummaryImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DownloadTaskSnapshot field0) taskUpdated,
    required TResult Function(DownloadTaskSnapshot field0)
        taskCompletedPendingAck,
    required TResult Function(String taskId) taskRemoved,
    required TResult Function(int restored, int cleaned) recoverySummary,
  }) {
    return recoverySummary(restored, cleaned);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DownloadTaskSnapshot field0)? taskUpdated,
    TResult? Function(DownloadTaskSnapshot field0)? taskCompletedPendingAck,
    TResult? Function(String taskId)? taskRemoved,
    TResult? Function(int restored, int cleaned)? recoverySummary,
  }) {
    return recoverySummary?.call(restored, cleaned);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DownloadTaskSnapshot field0)? taskUpdated,
    TResult Function(DownloadTaskSnapshot field0)? taskCompletedPendingAck,
    TResult Function(String taskId)? taskRemoved,
    TResult Function(int restored, int cleaned)? recoverySummary,
    required TResult orElse(),
  }) {
    if (recoverySummary != null) {
      return recoverySummary(restored, cleaned);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DownloadManagerEvent_TaskUpdated value)
        taskUpdated,
    required TResult Function(
            DownloadManagerEvent_TaskCompletedPendingAck value)
        taskCompletedPendingAck,
    required TResult Function(DownloadManagerEvent_TaskRemoved value)
        taskRemoved,
    required TResult Function(DownloadManagerEvent_RecoverySummary value)
        recoverySummary,
  }) {
    return recoverySummary(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DownloadManagerEvent_TaskUpdated value)? taskUpdated,
    TResult? Function(DownloadManagerEvent_TaskCompletedPendingAck value)?
        taskCompletedPendingAck,
    TResult? Function(DownloadManagerEvent_TaskRemoved value)? taskRemoved,
    TResult? Function(DownloadManagerEvent_RecoverySummary value)?
        recoverySummary,
  }) {
    return recoverySummary?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DownloadManagerEvent_TaskUpdated value)? taskUpdated,
    TResult Function(DownloadManagerEvent_TaskCompletedPendingAck value)?
        taskCompletedPendingAck,
    TResult Function(DownloadManagerEvent_TaskRemoved value)? taskRemoved,
    TResult Function(DownloadManagerEvent_RecoverySummary value)?
        recoverySummary,
    required TResult orElse(),
  }) {
    if (recoverySummary != null) {
      return recoverySummary(this);
    }
    return orElse();
  }
}

abstract class DownloadManagerEvent_RecoverySummary
    extends DownloadManagerEvent {
  const factory DownloadManagerEvent_RecoverySummary(
      {required final int restored,
      required final int cleaned}) = _$DownloadManagerEvent_RecoverySummaryImpl;
  const DownloadManagerEvent_RecoverySummary._() : super._();

  int get restored;
  int get cleaned;
  @JsonKey(ignore: true)
  _$$DownloadManagerEvent_RecoverySummaryImplCopyWith<
          _$DownloadManagerEvent_RecoverySummaryImpl>
      get copyWith => throw _privateConstructorUsedError;
}
