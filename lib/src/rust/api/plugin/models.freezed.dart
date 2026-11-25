// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MediaItem {
  Object get field0 => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Track field0) track,
    required TResult Function(AlbumSummary field0) album,
    required TResult Function(ArtistSummary field0) artist,
    required TResult Function(PlaylistSummary field0) playlist,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Track field0)? track,
    TResult? Function(AlbumSummary field0)? album,
    TResult? Function(ArtistSummary field0)? artist,
    TResult? Function(PlaylistSummary field0)? playlist,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Track field0)? track,
    TResult Function(AlbumSummary field0)? album,
    TResult Function(ArtistSummary field0)? artist,
    TResult Function(PlaylistSummary field0)? playlist,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MediaItem_Track value) track,
    required TResult Function(MediaItem_Album value) album,
    required TResult Function(MediaItem_Artist value) artist,
    required TResult Function(MediaItem_Playlist value) playlist,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MediaItem_Track value)? track,
    TResult? Function(MediaItem_Album value)? album,
    TResult? Function(MediaItem_Artist value)? artist,
    TResult? Function(MediaItem_Playlist value)? playlist,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MediaItem_Track value)? track,
    TResult Function(MediaItem_Album value)? album,
    TResult Function(MediaItem_Artist value)? artist,
    TResult Function(MediaItem_Playlist value)? playlist,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MediaItemCopyWith<$Res> {
  factory $MediaItemCopyWith(MediaItem value, $Res Function(MediaItem) then) =
      _$MediaItemCopyWithImpl<$Res, MediaItem>;
}

/// @nodoc
class _$MediaItemCopyWithImpl<$Res, $Val extends MediaItem>
    implements $MediaItemCopyWith<$Res> {
  _$MediaItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$MediaItem_TrackImplCopyWith<$Res> {
  factory _$$MediaItem_TrackImplCopyWith(_$MediaItem_TrackImpl value,
          $Res Function(_$MediaItem_TrackImpl) then) =
      __$$MediaItem_TrackImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Track field0});
}

/// @nodoc
class __$$MediaItem_TrackImplCopyWithImpl<$Res>
    extends _$MediaItemCopyWithImpl<$Res, _$MediaItem_TrackImpl>
    implements _$$MediaItem_TrackImplCopyWith<$Res> {
  __$$MediaItem_TrackImplCopyWithImpl(
      _$MediaItem_TrackImpl _value, $Res Function(_$MediaItem_TrackImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$MediaItem_TrackImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as Track,
    ));
  }
}

/// @nodoc

class _$MediaItem_TrackImpl extends MediaItem_Track {
  const _$MediaItem_TrackImpl(this.field0) : super._();

  @override
  final Track field0;

  @override
  String toString() {
    return 'MediaItem.track(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MediaItem_TrackImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MediaItem_TrackImplCopyWith<_$MediaItem_TrackImpl> get copyWith =>
      __$$MediaItem_TrackImplCopyWithImpl<_$MediaItem_TrackImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Track field0) track,
    required TResult Function(AlbumSummary field0) album,
    required TResult Function(ArtistSummary field0) artist,
    required TResult Function(PlaylistSummary field0) playlist,
  }) {
    return track(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Track field0)? track,
    TResult? Function(AlbumSummary field0)? album,
    TResult? Function(ArtistSummary field0)? artist,
    TResult? Function(PlaylistSummary field0)? playlist,
  }) {
    return track?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Track field0)? track,
    TResult Function(AlbumSummary field0)? album,
    TResult Function(ArtistSummary field0)? artist,
    TResult Function(PlaylistSummary field0)? playlist,
    required TResult orElse(),
  }) {
    if (track != null) {
      return track(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MediaItem_Track value) track,
    required TResult Function(MediaItem_Album value) album,
    required TResult Function(MediaItem_Artist value) artist,
    required TResult Function(MediaItem_Playlist value) playlist,
  }) {
    return track(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MediaItem_Track value)? track,
    TResult? Function(MediaItem_Album value)? album,
    TResult? Function(MediaItem_Artist value)? artist,
    TResult? Function(MediaItem_Playlist value)? playlist,
  }) {
    return track?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MediaItem_Track value)? track,
    TResult Function(MediaItem_Album value)? album,
    TResult Function(MediaItem_Artist value)? artist,
    TResult Function(MediaItem_Playlist value)? playlist,
    required TResult orElse(),
  }) {
    if (track != null) {
      return track(this);
    }
    return orElse();
  }
}

abstract class MediaItem_Track extends MediaItem {
  const factory MediaItem_Track(final Track field0) = _$MediaItem_TrackImpl;
  const MediaItem_Track._() : super._();

  @override
  Track get field0;
  @JsonKey(ignore: true)
  _$$MediaItem_TrackImplCopyWith<_$MediaItem_TrackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MediaItem_AlbumImplCopyWith<$Res> {
  factory _$$MediaItem_AlbumImplCopyWith(_$MediaItem_AlbumImpl value,
          $Res Function(_$MediaItem_AlbumImpl) then) =
      __$$MediaItem_AlbumImplCopyWithImpl<$Res>;
  @useResult
  $Res call({AlbumSummary field0});
}

/// @nodoc
class __$$MediaItem_AlbumImplCopyWithImpl<$Res>
    extends _$MediaItemCopyWithImpl<$Res, _$MediaItem_AlbumImpl>
    implements _$$MediaItem_AlbumImplCopyWith<$Res> {
  __$$MediaItem_AlbumImplCopyWithImpl(
      _$MediaItem_AlbumImpl _value, $Res Function(_$MediaItem_AlbumImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$MediaItem_AlbumImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as AlbumSummary,
    ));
  }
}

/// @nodoc

class _$MediaItem_AlbumImpl extends MediaItem_Album {
  const _$MediaItem_AlbumImpl(this.field0) : super._();

  @override
  final AlbumSummary field0;

  @override
  String toString() {
    return 'MediaItem.album(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MediaItem_AlbumImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MediaItem_AlbumImplCopyWith<_$MediaItem_AlbumImpl> get copyWith =>
      __$$MediaItem_AlbumImplCopyWithImpl<_$MediaItem_AlbumImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Track field0) track,
    required TResult Function(AlbumSummary field0) album,
    required TResult Function(ArtistSummary field0) artist,
    required TResult Function(PlaylistSummary field0) playlist,
  }) {
    return album(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Track field0)? track,
    TResult? Function(AlbumSummary field0)? album,
    TResult? Function(ArtistSummary field0)? artist,
    TResult? Function(PlaylistSummary field0)? playlist,
  }) {
    return album?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Track field0)? track,
    TResult Function(AlbumSummary field0)? album,
    TResult Function(ArtistSummary field0)? artist,
    TResult Function(PlaylistSummary field0)? playlist,
    required TResult orElse(),
  }) {
    if (album != null) {
      return album(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MediaItem_Track value) track,
    required TResult Function(MediaItem_Album value) album,
    required TResult Function(MediaItem_Artist value) artist,
    required TResult Function(MediaItem_Playlist value) playlist,
  }) {
    return album(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MediaItem_Track value)? track,
    TResult? Function(MediaItem_Album value)? album,
    TResult? Function(MediaItem_Artist value)? artist,
    TResult? Function(MediaItem_Playlist value)? playlist,
  }) {
    return album?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MediaItem_Track value)? track,
    TResult Function(MediaItem_Album value)? album,
    TResult Function(MediaItem_Artist value)? artist,
    TResult Function(MediaItem_Playlist value)? playlist,
    required TResult orElse(),
  }) {
    if (album != null) {
      return album(this);
    }
    return orElse();
  }
}

abstract class MediaItem_Album extends MediaItem {
  const factory MediaItem_Album(final AlbumSummary field0) =
      _$MediaItem_AlbumImpl;
  const MediaItem_Album._() : super._();

  @override
  AlbumSummary get field0;
  @JsonKey(ignore: true)
  _$$MediaItem_AlbumImplCopyWith<_$MediaItem_AlbumImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MediaItem_ArtistImplCopyWith<$Res> {
  factory _$$MediaItem_ArtistImplCopyWith(_$MediaItem_ArtistImpl value,
          $Res Function(_$MediaItem_ArtistImpl) then) =
      __$$MediaItem_ArtistImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ArtistSummary field0});
}

/// @nodoc
class __$$MediaItem_ArtistImplCopyWithImpl<$Res>
    extends _$MediaItemCopyWithImpl<$Res, _$MediaItem_ArtistImpl>
    implements _$$MediaItem_ArtistImplCopyWith<$Res> {
  __$$MediaItem_ArtistImplCopyWithImpl(_$MediaItem_ArtistImpl _value,
      $Res Function(_$MediaItem_ArtistImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$MediaItem_ArtistImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as ArtistSummary,
    ));
  }
}

/// @nodoc

class _$MediaItem_ArtistImpl extends MediaItem_Artist {
  const _$MediaItem_ArtistImpl(this.field0) : super._();

  @override
  final ArtistSummary field0;

  @override
  String toString() {
    return 'MediaItem.artist(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MediaItem_ArtistImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MediaItem_ArtistImplCopyWith<_$MediaItem_ArtistImpl> get copyWith =>
      __$$MediaItem_ArtistImplCopyWithImpl<_$MediaItem_ArtistImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Track field0) track,
    required TResult Function(AlbumSummary field0) album,
    required TResult Function(ArtistSummary field0) artist,
    required TResult Function(PlaylistSummary field0) playlist,
  }) {
    return artist(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Track field0)? track,
    TResult? Function(AlbumSummary field0)? album,
    TResult? Function(ArtistSummary field0)? artist,
    TResult? Function(PlaylistSummary field0)? playlist,
  }) {
    return artist?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Track field0)? track,
    TResult Function(AlbumSummary field0)? album,
    TResult Function(ArtistSummary field0)? artist,
    TResult Function(PlaylistSummary field0)? playlist,
    required TResult orElse(),
  }) {
    if (artist != null) {
      return artist(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MediaItem_Track value) track,
    required TResult Function(MediaItem_Album value) album,
    required TResult Function(MediaItem_Artist value) artist,
    required TResult Function(MediaItem_Playlist value) playlist,
  }) {
    return artist(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MediaItem_Track value)? track,
    TResult? Function(MediaItem_Album value)? album,
    TResult? Function(MediaItem_Artist value)? artist,
    TResult? Function(MediaItem_Playlist value)? playlist,
  }) {
    return artist?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MediaItem_Track value)? track,
    TResult Function(MediaItem_Album value)? album,
    TResult Function(MediaItem_Artist value)? artist,
    TResult Function(MediaItem_Playlist value)? playlist,
    required TResult orElse(),
  }) {
    if (artist != null) {
      return artist(this);
    }
    return orElse();
  }
}

abstract class MediaItem_Artist extends MediaItem {
  const factory MediaItem_Artist(final ArtistSummary field0) =
      _$MediaItem_ArtistImpl;
  const MediaItem_Artist._() : super._();

  @override
  ArtistSummary get field0;
  @JsonKey(ignore: true)
  _$$MediaItem_ArtistImplCopyWith<_$MediaItem_ArtistImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MediaItem_PlaylistImplCopyWith<$Res> {
  factory _$$MediaItem_PlaylistImplCopyWith(_$MediaItem_PlaylistImpl value,
          $Res Function(_$MediaItem_PlaylistImpl) then) =
      __$$MediaItem_PlaylistImplCopyWithImpl<$Res>;
  @useResult
  $Res call({PlaylistSummary field0});
}

/// @nodoc
class __$$MediaItem_PlaylistImplCopyWithImpl<$Res>
    extends _$MediaItemCopyWithImpl<$Res, _$MediaItem_PlaylistImpl>
    implements _$$MediaItem_PlaylistImplCopyWith<$Res> {
  __$$MediaItem_PlaylistImplCopyWithImpl(_$MediaItem_PlaylistImpl _value,
      $Res Function(_$MediaItem_PlaylistImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$MediaItem_PlaylistImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as PlaylistSummary,
    ));
  }
}

/// @nodoc

class _$MediaItem_PlaylistImpl extends MediaItem_Playlist {
  const _$MediaItem_PlaylistImpl(this.field0) : super._();

  @override
  final PlaylistSummary field0;

  @override
  String toString() {
    return 'MediaItem.playlist(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MediaItem_PlaylistImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MediaItem_PlaylistImplCopyWith<_$MediaItem_PlaylistImpl> get copyWith =>
      __$$MediaItem_PlaylistImplCopyWithImpl<_$MediaItem_PlaylistImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Track field0) track,
    required TResult Function(AlbumSummary field0) album,
    required TResult Function(ArtistSummary field0) artist,
    required TResult Function(PlaylistSummary field0) playlist,
  }) {
    return playlist(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Track field0)? track,
    TResult? Function(AlbumSummary field0)? album,
    TResult? Function(ArtistSummary field0)? artist,
    TResult? Function(PlaylistSummary field0)? playlist,
  }) {
    return playlist?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Track field0)? track,
    TResult Function(AlbumSummary field0)? album,
    TResult Function(ArtistSummary field0)? artist,
    TResult Function(PlaylistSummary field0)? playlist,
    required TResult orElse(),
  }) {
    if (playlist != null) {
      return playlist(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MediaItem_Track value) track,
    required TResult Function(MediaItem_Album value) album,
    required TResult Function(MediaItem_Artist value) artist,
    required TResult Function(MediaItem_Playlist value) playlist,
  }) {
    return playlist(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MediaItem_Track value)? track,
    TResult? Function(MediaItem_Album value)? album,
    TResult? Function(MediaItem_Artist value)? artist,
    TResult? Function(MediaItem_Playlist value)? playlist,
  }) {
    return playlist?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MediaItem_Track value)? track,
    TResult Function(MediaItem_Album value)? album,
    TResult Function(MediaItem_Artist value)? artist,
    TResult Function(MediaItem_Playlist value)? playlist,
    required TResult orElse(),
  }) {
    if (playlist != null) {
      return playlist(this);
    }
    return orElse();
  }
}

abstract class MediaItem_Playlist extends MediaItem {
  const factory MediaItem_Playlist(final PlaylistSummary field0) =
      _$MediaItem_PlaylistImpl;
  const MediaItem_Playlist._() : super._();

  @override
  PlaylistSummary get field0;
  @JsonKey(ignore: true)
  _$$MediaItem_PlaylistImplCopyWith<_$MediaItem_PlaylistImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$Suggestion {
  Object get field0 => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) query,
    required TResult Function(EntitySuggestion field0) entity,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? query,
    TResult? Function(EntitySuggestion field0)? entity,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? query,
    TResult Function(EntitySuggestion field0)? entity,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Suggestion_Query value) query,
    required TResult Function(Suggestion_Entity value) entity,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Suggestion_Query value)? query,
    TResult? Function(Suggestion_Entity value)? entity,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Suggestion_Query value)? query,
    TResult Function(Suggestion_Entity value)? entity,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SuggestionCopyWith<$Res> {
  factory $SuggestionCopyWith(
          Suggestion value, $Res Function(Suggestion) then) =
      _$SuggestionCopyWithImpl<$Res, Suggestion>;
}

/// @nodoc
class _$SuggestionCopyWithImpl<$Res, $Val extends Suggestion>
    implements $SuggestionCopyWith<$Res> {
  _$SuggestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$Suggestion_QueryImplCopyWith<$Res> {
  factory _$$Suggestion_QueryImplCopyWith(_$Suggestion_QueryImpl value,
          $Res Function(_$Suggestion_QueryImpl) then) =
      __$$Suggestion_QueryImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class __$$Suggestion_QueryImplCopyWithImpl<$Res>
    extends _$SuggestionCopyWithImpl<$Res, _$Suggestion_QueryImpl>
    implements _$$Suggestion_QueryImplCopyWith<$Res> {
  __$$Suggestion_QueryImplCopyWithImpl(_$Suggestion_QueryImpl _value,
      $Res Function(_$Suggestion_QueryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$Suggestion_QueryImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$Suggestion_QueryImpl extends Suggestion_Query {
  const _$Suggestion_QueryImpl(this.field0) : super._();

  @override
  final String field0;

  @override
  String toString() {
    return 'Suggestion.query(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Suggestion_QueryImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$Suggestion_QueryImplCopyWith<_$Suggestion_QueryImpl> get copyWith =>
      __$$Suggestion_QueryImplCopyWithImpl<_$Suggestion_QueryImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) query,
    required TResult Function(EntitySuggestion field0) entity,
  }) {
    return query(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? query,
    TResult? Function(EntitySuggestion field0)? entity,
  }) {
    return query?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? query,
    TResult Function(EntitySuggestion field0)? entity,
    required TResult orElse(),
  }) {
    if (query != null) {
      return query(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Suggestion_Query value) query,
    required TResult Function(Suggestion_Entity value) entity,
  }) {
    return query(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Suggestion_Query value)? query,
    TResult? Function(Suggestion_Entity value)? entity,
  }) {
    return query?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Suggestion_Query value)? query,
    TResult Function(Suggestion_Entity value)? entity,
    required TResult orElse(),
  }) {
    if (query != null) {
      return query(this);
    }
    return orElse();
  }
}

abstract class Suggestion_Query extends Suggestion {
  const factory Suggestion_Query(final String field0) = _$Suggestion_QueryImpl;
  const Suggestion_Query._() : super._();

  @override
  String get field0;
  @JsonKey(ignore: true)
  _$$Suggestion_QueryImplCopyWith<_$Suggestion_QueryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$Suggestion_EntityImplCopyWith<$Res> {
  factory _$$Suggestion_EntityImplCopyWith(_$Suggestion_EntityImpl value,
          $Res Function(_$Suggestion_EntityImpl) then) =
      __$$Suggestion_EntityImplCopyWithImpl<$Res>;
  @useResult
  $Res call({EntitySuggestion field0});
}

/// @nodoc
class __$$Suggestion_EntityImplCopyWithImpl<$Res>
    extends _$SuggestionCopyWithImpl<$Res, _$Suggestion_EntityImpl>
    implements _$$Suggestion_EntityImplCopyWith<$Res> {
  __$$Suggestion_EntityImplCopyWithImpl(_$Suggestion_EntityImpl _value,
      $Res Function(_$Suggestion_EntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$Suggestion_EntityImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as EntitySuggestion,
    ));
  }
}

/// @nodoc

class _$Suggestion_EntityImpl extends Suggestion_Entity {
  const _$Suggestion_EntityImpl(this.field0) : super._();

  @override
  final EntitySuggestion field0;

  @override
  String toString() {
    return 'Suggestion.entity(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Suggestion_EntityImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$Suggestion_EntityImplCopyWith<_$Suggestion_EntityImpl> get copyWith =>
      __$$Suggestion_EntityImplCopyWithImpl<_$Suggestion_EntityImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) query,
    required TResult Function(EntitySuggestion field0) entity,
  }) {
    return entity(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? query,
    TResult? Function(EntitySuggestion field0)? entity,
  }) {
    return entity?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? query,
    TResult Function(EntitySuggestion field0)? entity,
    required TResult orElse(),
  }) {
    if (entity != null) {
      return entity(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Suggestion_Query value) query,
    required TResult Function(Suggestion_Entity value) entity,
  }) {
    return entity(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Suggestion_Query value)? query,
    TResult? Function(Suggestion_Entity value)? entity,
  }) {
    return entity?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Suggestion_Query value)? query,
    TResult Function(Suggestion_Entity value)? entity,
    required TResult orElse(),
  }) {
    if (entity != null) {
      return entity(this);
    }
    return orElse();
  }
}

abstract class Suggestion_Entity extends Suggestion {
  const factory Suggestion_Entity(final EntitySuggestion field0) =
      _$Suggestion_EntityImpl;
  const Suggestion_Entity._() : super._();

  @override
  EntitySuggestion get field0;
  @JsonKey(ignore: true)
  _$$Suggestion_EntityImplCopyWith<_$Suggestion_EntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
