import "dart:typed_data";

import "package:minisound/engine.dart";
import "package:minisound_platform_interface/minisound_platform_interface.dart";

export "package:minisound_platform_interface/minisound_platform_interface.dart"
    show
        MinisoundPlatformException,
        MinisoundPlatformOutOfMemoryException,
        SoundFormat;

final class Recorder {
  Recorder({Engine? mainEngine}) : engine = mainEngine ?? Engine();

  final _recorder = PlatformRecorder();

  final Engine engine;

  bool _isInit = false;
  bool get isInit => _isInit;

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  /// Initializes the recorder's engine.
  Future<void> initEngine([int periodMs = 10]) async => engine.init(periodMs);

  /// Initializes the recorder to save to a file.
  Future<void> initFile(
    String filename, {
    int sampleRate = 44100,
    int channels = 1,
    SoundFormat format = SoundFormat.f32,
  }) async {
    if (sampleRate <= 0 || channels <= 0) {
      throw ArgumentError("Invalid recorder parameters");
    }
    if (!_isInit) {
      if (!engine.isInit) await initEngine();

      await _recorder.initFile(
        filename,
        sampleRate: sampleRate,
        channels: channels,
        format: format,
      );

      _isInit = true;
    }
  }

  /// Initializes the recorder for streaming.
  Future<void> initStream({
    int sampleRate = 44100,
    int channels = 1,
    SoundFormat format = SoundFormat.f32,
    double bufferLenS = 5.0,
  }) async {
    if (sampleRate <= 0 || channels <= 0 || bufferLenS <= 0) {
      throw ArgumentError("Invalid recorder parameters");
    }
    if (!_isInit) {
      if (!engine.isInit) await initEngine();

      await _recorder.initStream(
        sampleRate: sampleRate,
        channels: channels,
        format: format,
        bufferLenS: bufferLenS,
      );

      _isInit = true;
    }
  }

  /// Disposes of the recorder resources.
  void dispose() => _recorder.dispose();

  /// Starts recording.
  void start() {
    _recorder.start();
    _isRecording = true;
  }

  /// Stops recording.
  void stop() {
    _recorder.stop();
    _isRecording = false;
  }

  /// Gets available float from the recorder.
  int get availableFloatCount => _recorder.availableFloatCount;

  /// Gets the recorded buffer.
  Float32List getBuffer(int floatsToRead) => _recorder.getBuffer(floatsToRead);
}
