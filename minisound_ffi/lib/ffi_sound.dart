part of "minisound_ffi.dart";

final class FfiSound implements PlatformSound {
  FfiSound._(Pointer<c.Sound> self, [Pointer? data])
      : _self = self,
        _data = data;

  final Pointer<c.Sound> _self;
  final Pointer? _data;

  late var _volume = _bindings.sound_get_volume(_self);
  @override
  double get volume => _volume;
  @override
  set volume(double value) {
    _bindings.sound_set_volume(_self, value);
    _volume = value;
  }

  @override
  late final duration = _bindings.sound_get_duration(_self);

  var _looping = (false, 0);
  @override
  PlatformSoundLooping get looping => _looping;
  @override
  set looping(PlatformSoundLooping value) {
    // TODO!!! unsafe and crappy and fix later
    final data = _bindings.sound_get_data(_self).cast<Pointer<Void>>();
    _bindings.encoded_sound_data_set_looped(
        (data + 1).value.cast(), value.$1, value.$2);
    _looping = value;
  }

  @override
  void unload() {
    _bindings.sound_unload(_self);
    if (_data != null) malloc.free(_data!);
  }

  @override
  void play() {
    final r = _bindings.sound_play(_self);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException("Failed to play the sound (code: $r).");
    }
  }

  @override
  void replay() {
    final r = _bindings.sound_replay(_self);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException(
          "Failed to replay the sound (code: $r).");
    }
  }

  @override
  void pause() => _bindings.sound_pause(_self);
  @override
  void stop() => _bindings.sound_stop(_self);
}
