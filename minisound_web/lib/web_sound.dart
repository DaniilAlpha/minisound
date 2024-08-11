part of "minisound_web.dart";

final class WebSound implements PlatformSound {
  WebSound._fromPtrs(Pointer<c.Sound> self, Pointer data)
      : _self = self,
        _data = data;

  final Pointer<c.Sound> _self;
  final Pointer _data;

  late var _volume = c.sound_get_volume(_self);
  @override
  double get volume => _volume;
  @override
  set volume(double value) {
    c.sound_set_volume(_self, value);
    _volume = value;
  }

  @override
  late final duration = c.sound_get_duration(_self);

  var _looping = (false, 0);
  @override
  PlatformSoundLooping get looping => _looping;
  @override
  set looping(PlatformSoundLooping value) {
    c.sound_set_looped(_self, value.$1, value.$2);
    _looping = value;
  }

  @override
  void unload() {
    c.sound_unload(_self);
    malloc.free(_data);
  }

  @override
  void play() {
    final r = c.sound_play(_self);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException("Failed to play the sound (code: $r).");
    }
  }

  @override
  void replay() {
    final r = c.sound_replay(_self);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException(
          "Failed to replay the sound (code: $r).");
    }
  }

  @override
  void pause() => c.sound_pause(_self);
  @override
  void stop() => c.sound_stop(_self);
}

extension SoundFormatToC on SoundFormat {
  int toC() => switch (this) {
        SoundFormat.u8 => c.SoundFormat.SOUND_FORMAT_U8,
        SoundFormat.s16 => c.SoundFormat.SOUND_FORMAT_S16,
        SoundFormat.s24 => c.SoundFormat.SOUND_FORMAT_S24,
        SoundFormat.s32 => c.SoundFormat.SOUND_FORMAT_S32,
        SoundFormat.f32 => c.SoundFormat.SOUND_FORMAT_F32,
      };
}
