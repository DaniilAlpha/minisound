part of "minisound_platform_interface.dart";

typedef PlatformSoundLooping = (bool isLooped, int delayMs);

abstract interface class PlatformSound {
  double get volume;
  set volume(double value);

  void unload();

  void play();
  void pause();
  void stop();
}

abstract interface class PlatformEncodedSound extends PlatformSound {
  double get duration;

  PlatformSoundLooping get looping;
  set looping(PlatformSoundLooping value);
}

abstract interface class PlatformWaveformSound extends PlatformSound {
  WaveformType get type;
  set type(WaveformType type);

  double get freq;
  set freq(double value);
}

abstract interface class PlatformNoiseSound extends PlatformSound {
  NoiseType get type;

  int get seed;
  set seed(int value);
}

abstract interface class PlatformPulseSound extends PlatformSound {
  double get freq;
  set freq(double type);

  double get dutyCycle;
  set dutyCycle(double value);
}
