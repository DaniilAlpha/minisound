import "dart:math" as math;
import "dart:typed_data";

import "package:minisound_platform_interface/minisound_platform_interface.dart";

// minisound mock

class MinisoundMock extends MinisoundPlatform {
  @override
  PlatformEngine createEngine() => EngineMock();

  @override
  PlatformRecorder createRecorder() => RecorderMock();

  @override
  PlatformGenerator createGenerator() => GeneratorMock();
}

// engine mock

enum EngineState { uninit, init, started }

class EngineMock implements PlatformEngine {
  final Map<int, SoundMock> loadedSounds = {};
  int nextSoundId = 0;

  EngineState state = EngineState.uninit;

  @override
  void dispose() => state = EngineState.uninit;

  @override
  Future<void> init(int periodMs) async {
    if (state != EngineState.uninit) {
      throw MinisoundPlatformException("cannot init engine");
    }
    state = EngineState.init;
  }

  @override
  Future<PlatformSound> loadSound(AudioData data) async {
    if (state == EngineState.uninit) {
      throw MinisoundPlatformException("cannot load sound");
    }
    final sound = SoundMock(nextSoundId++, data);
    loadedSounds[sound.id] = sound;
    return sound;
  }

  @override
  void start() {
    if (state != EngineState.init) {
      throw MinisoundPlatformException("cannot start engine");
    }
    state = EngineState.started;
  }
}

// sound mock

enum SoundState { playing, paused, stopped }

class SoundMock implements PlatformSound {
  SoundMock(this.id, this.data);

  final int id;
  final AudioData data;

  var state = SoundState.stopped;

  @override
  var volume = 1.0;

  @override
  double get duration => data.buffer.length / (data.sampleRate * data.channels);

  @override
  PlatformSoundLooping get looping => (false, 0);
  @override
  set looping(PlatformSoundLooping value) {}

  @override
  void play() => state = SoundState.playing;

  @override
  void replay() {
    state = SoundState.stopped;
    play();
  }

  @override
  void pause() => state = SoundState.paused;

  @override
  void stop() => state = SoundState.stopped;

  @override
  void unload() {}
}

// recorder mock

enum RecorderState { uninit, ready, recording }

class RecorderMock implements PlatformRecorder {
  var state = RecorderState.uninit;
  String? filename;
  int sampleRate = 0;
  int channels = 0;
  SoundFormat? format;
  final List<Float32List> recordedBuffers = [];

  @override
  Future<void> initFile(
    String filename, {
    required int sampleRate,
    required int channels,
    required SoundFormat format,
  }) async {
    this.filename = filename;
    this.sampleRate = sampleRate;
    this.channels = channels;
    this.format = format;
    state = RecorderState.ready;
  }

  @override
  Future<void> initStream({
    required int sampleRate,
    required int channels,
    required SoundFormat format,
    required double bufferLenS,
  }) async {
    this.sampleRate = sampleRate;
    this.channels = channels;
    this.format = format;
    state = RecorderState.ready;
  }

  @override
  void start() {
    if (state != RecorderState.ready) {
      throw MinisoundPlatformException("Recorder not initialized");
    }
    state = RecorderState.recording;
  }

  @override
  void stop() {
    if (state != RecorderState.recording) {
      throw MinisoundPlatformException("Recorder not recording");
    }
    state = RecorderState.ready;
  }

  @override
  bool get isRecording => state == RecorderState.recording;

  @override
  Float32List getBuffer(int floatsToRead) {
    if (state == RecorderState.uninit) {
      throw MinisoundPlatformException("Recorder not initialized");
    }
    final buffer = Float32List(floatsToRead);
    for (var i = 0; i < floatsToRead; i++) {
      buffer[i] = math.Random().nextDouble() * 2 - 1;
    }
    recordedBuffers.add(buffer);
    return buffer;
  }

  @override
  int get availableFloatCount {
    if (state == RecorderState.uninit) {
      throw MinisoundPlatformException("Recorder not initialized");
    }
    return math.Random().nextInt(4096);
  }

  @override
  void dispose() {
    state = RecorderState.uninit;
    filename = null;
    recordedBuffers.clear();
  }
}

// generator mock

class GeneratorMock implements PlatformGenerator {
  SoundFormat? format;
  int channels = 0;
  int sampleRate = 0;
  double bufferLenS = 0;

  @override
  var volume = 1.0;

  var isStarted = false;

  @override
  Future<void> init({
    required SoundFormat format,
    required int channels,
    required int sampleRate,
    required double bufferLenS,
  }) async {
    this.format = format;
    this.channels = channels;
    this.sampleRate = sampleRate;
    this.bufferLenS = bufferLenS;
  }

  @override
  void setWaveform({
    required GeneratorWaveformType type,
    required double frequency,
    required double amplitude,
  }) {}

  @override
  void setPulsewave({
    required double frequency,
    required double amplitude,
    required double dutyCycle,
  }) {}

  @override
  void setNoise({
    required GeneratorNoiseType type,
    required int seed,
    required double amplitude,
  }) {}

  @override
  void start() => isStarted = true;

  @override
  void stop() => isStarted = false;

  @override
  Float32List getBuffer(int floatsToRead) {
    final buffer = Float32List(floatsToRead);
    for (var i = 0; i < floatsToRead; i++) {
      buffer[i] = math.Random().nextDouble() * 2 - 1;
    }
    return buffer;
  }

  @override
  int get availableFloatCount => math.Random().nextInt(4096);

  @override
  void dispose() {}
}
