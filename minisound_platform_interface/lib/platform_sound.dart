part of "minisound_platform_interface.dart";

enum SoundFormat { u8, s16, s24, s32, f32 }

typedef PlatformSoundLooping = (bool isLooped, int delayMs);

abstract interface class PlatformSound {
  double get volume;
  set volume(double value);

  double get duration;

  PlatformSoundLooping get looping;
  set looping(PlatformSoundLooping value);

  void unload();

  void play();
  void replay();
  void pause();
  void stop();
}
