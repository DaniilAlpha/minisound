part of "minisound_ffi.dart";

final class FfiSound implements PlatformSound {
  FfiSound._fromPtrs(Pointer<c.Sound> self, Pointer data)
      : _self = self,
        _data = data;

  final Pointer<c.Sound> _self;
  final Pointer _data;

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
    _bindings.sound_set_looped(_self, value.$1, value.$2);
    _looping = value;
  }

  @override
  void unload() {
    _bindings.sound_unload(_self);
    malloc.free(_data);
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

extension on SoundFormat {
  int toC() => switch (this) {
        SoundFormat.u8 => c.SoundFormat.SOUND_FORMAT_U8,
        SoundFormat.s16 => c.SoundFormat.SOUND_FORMAT_S16,
        SoundFormat.s24 => c.SoundFormat.SOUND_FORMAT_S24,
        SoundFormat.s32 => c.SoundFormat.SOUND_FORMAT_S32,
        SoundFormat.f32 => c.SoundFormat.SOUND_FORMAT_F32,
      };
}
