import "dart:async";
import "dart:typed_data";

import "package:minisound_platform_interface/minisound_platform_interface.dart";

export "package:minisound_platform_interface/minisound_platform_interface.dart"
    show
        MinisoundPlatformException,
        MinisoundPlatformOutOfMemoryException,
        RecordingFormat;

/// Controls audio recoding.
///
/// Should be initialized before doing anything.
final class Recorder {
  Recorder() {
    _finalizer.attach(this, _recorder);
  }

  static final _finalizer =
      Finalizer<PlatformRecorder>((recorder) => recorder.dispose());
  static final _recordingsFinalizer =
      Finalizer<PlatformRecording>((recording) => recording.dispose());

  final _recorder = PlatformRecorder();

  bool get isRecording => _recorder.isRecording;

  /// Initializes the recorder.
  Future<void> init() => _recorder.init();

  /// Starts the recorder.
  ///
  /// Recording is saved into RAM. Parameters directly influence the amount of memory that the
  /// recording will take. This'll be fine for under an hour for sure, but if you are recording
  /// very large sounds, it is recommended to process (save, send, etc.) recording by splitting it
  /// into multiple smaller ones. Delay for restarting is generally unnoticeable, especially for
  /// shorter recordings.
  ///
  /// `channelCount` must be in range 1..254 inclusive.
  /// `sampleRate` must be in range 1000..384000 inclusive.
  ///
  /// And here is the formula for calculating occupied memory size in case you really need:
  /// `s = l * f * n * s0`,
  ///   where `l` - length in seconds, `f` - sample rate, `n` - channel count, `s0` - format size (`1` for `u8`, `2` for `s16`, `3` for `s24`, `4` for `s32` and `f32`).
  Future<void> start({
    RecordingFormat format = RecordingFormat.s16,
    int channelCount = 2,
    int sampleRate = 44100,
  }) async {
    assert(1 <= channelCount && channelCount <= 254);
    assert(1000 <= sampleRate && sampleRate <= 384000);

    _recorder.start(
      sampleRate: sampleRate,
      channelCount: channelCount,
      format: format,
    );
  }

  /// Stops the recorder and returns what have been recorded.
  Future<Recording> stop() async {
    final platformRecording = _recorder.stop();
    final recording = Recording._(platformRecording);
    _recordingsFinalizer.attach(recording, platformRecording);
    return recording;
  }
}

final class Recording {
  Recording._(PlatformRecording recording) : _recording = recording;

  final PlatformRecording _recording;

  /// Recorded data in the WAV format. Can be directly fed into the `loadSound` engine function.
  Uint8List get data => _recording.buffer;
}
