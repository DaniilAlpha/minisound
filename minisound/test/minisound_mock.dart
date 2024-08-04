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
  PlatformWave createWave() => WaveMock();
}

// engine mock

enum EngineState { uninit, init, started }

class EngineMock implements PlatformEngine {
  var state = EngineState.uninit;

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
  Future<PlatformSound> loadSound(Uint8List data) async {
    if (state == EngineState.uninit) {
      throw MinisoundPlatformException("cannot load sound");
    }
    return SoundMock(data);
  }

  @override
  void start() {
    if (state != EngineState.init && state != EngineState.started) {
      throw MinisoundPlatformException("cannot start engine");
    }
    state = EngineState.started;
  }
}

// sound mock

enum SoundState { playing, paused, stopped }

class SoundMock implements PlatformSound {
  SoundMock(this.data);

  final Uint8List data;

  var state = SoundState.stopped;

  @override
  var volume = 1.0;

  @override
  double get duration => double.infinity;

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
  final List<Uint8List> recordedBuffers = [];

  @override
  Future<void> initFile(String filename) async {
    this.filename = filename;
    state = RecorderState.ready;
  }

  @override
  Future<void> initStream() async {
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
  Uint8List getBuffer(int framesToRead) {
    if (state == RecorderState.uninit) {
      throw MinisoundPlatformException("Recorder not initialized");
    }
    final buffer = Uint8List(framesToRead);
    for (var i = 0; i < framesToRead; i++) {
      buffer[i] = i.toDouble() / framesToRead;
    }
    recordedBuffers.add(buffer);
    return buffer;
  }

  @override
  void dispose() {
    state = RecorderState.uninit;
    filename = null;
    recordedBuffers.clear();
  }
}

// wave mock

enum WaveType { sine, square, triangle, sawtooth }

class WaveMock implements PlatformWave {
  WaveType type = WaveType.sine;
  double frequency = 440.0;
  double amplitude = 1.0;
  int sampleRate = 44100;

  @override
  Future<void> init(
      int type, double frequency, double amplitude, int sampleRate) async {
    this.type = WaveType.values[type];
    this.frequency = frequency;
    this.amplitude = amplitude;
    this.sampleRate = sampleRate;
  }

  @override
  void setType(int type) {
    this.type = WaveType.values[type];
  }

  @override
  void setFrequency(double frequency) {
    this.frequency = frequency;
  }

  @override
  void setAmplitude(double amplitude) {
    this.amplitude = amplitude;
  }

  @override
  void setSampleRate(int sampleRate) {
    this.sampleRate = sampleRate;
  }

  @override
  Float32List read(int framesToRead) {
    final buffer = Float32List(framesToRead);
    final period = sampleRate / frequency;
    for (var i = 0; i < framesToRead; i++) {
      final t = (i % period) / period;
      switch (type) {
        case WaveType.sine:
          buffer[i] = amplitude * math.sin(2 * math.pi * t);
        case WaveType.square:
          buffer[i] = amplitude * (t < 0.5 ? 1 : -1);
        case WaveType.triangle:
          buffer[i] = amplitude * (t < 0.5 ? 4 * t - 1 : 3 - 4 * t);
        case WaveType.sawtooth:
          buffer[i] = amplitude * (2 * t - 1);
      }
    }
    return buffer;
  }

  @override
  void dispose() {
    // Reset to default values
    type = WaveType.sine;
    frequency = 440.0;
    amplitude = 1.0;
    sampleRate = 44100;
  }
}
