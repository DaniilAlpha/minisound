import "dart:async";
import "dart:typed_data";

import "package:minisound_platform_interface/minisound_platform_interface.dart";

export "package:minisound_platform_interface/minisound_platform_interface.dart"
    show
        MinisoundPlatformException,
        MinisoundPlatformOutOfMemoryException,
        RecorderFormat;

/// Controls audio recodfing.
final class Recorder {
  Recorder() {
    _finalizer.attach(this, _recorder);
  }

  static final _finalizer =
      Finalizer<PlatformRecorder>((recorder) => recorder.dispose());
  static final _recordingsFinalizer =
      Finalizer<Recording>((recording) => recording.dispose());

  final _recorder = PlatformRecorder();

  var _isInit = false;
  bool get isInit => _isInit;

  bool get isRecording => _recorder.isRecording;

  /// Initializes the recorder. All parameters directly influence the amount of memory that recording will take.
  ///
  /// `channelCount` must be in range 1..254 inclusive.
  /// `sampleRate` must be in range 8000..384000 inclusive.
  Future<void> init({
    RecorderFormat format = RecorderFormat.s16,
    int channelCount = 2,
    int sampleRate = 44100,
  }) async {
    assert(1 <= channelCount && channelCount <= 254);
    assert(8000 <= sampleRate && sampleRate <= 384000);

    if (_isInit) return;

    await _recorder.init(
      sampleRate: sampleRate,
      channelCount: channelCount,
      format: format,
    );
    _isInit = true;
  }

  /// Starts the recorder.
  ///
  /// Records into memory.
  /// This'll be fine for under an hour for sure, but if you are recording larger sounds it is recommended to process (save, send, etc.) recording by splitting it into multiple smaller ones. Delay for stopping and starting again is unnoticeable in general and is smaller for smaller recordings.
  ///
  /// Formula for calculating the exact size in case you needed:
  /// `s = l * f * n * s0`,
  ///   where `l` - length in seconds, `f` - sample rate, `n` - channel count, `s0` - format size (`1` for `u8`, `2` for `s16`, `3` for `s24`, `4` for `s32` and `f32`).
  Future<void> start() async => _recorder.start();

  /// Stops the recorder and returns what have been recorded.
  /// Each recording should be disposed when not needed anymore.
  Future<Recording> stop() async {
    final platformRecording = _recorder.stop();
    final recording = Recording._(platformRecording);
    _recordingsFinalizer.attach(this, recording);
    return recording;
  }
}

final class Recording {
  Recording._(PlatformRecording recording) : _recording = recording;

  final PlatformRecording _recording;

  /// Buffer that contains recorded data in a WAV format. Can be directly used to load `Sound`s from.
  Uint8List get buffer => _recording.buffer;

  void dispose() => _recording.dispose();
}
