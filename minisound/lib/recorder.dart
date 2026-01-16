import "dart:async";
import "dart:io" if (dart.library.io) "package:minisound/src/dummy_file.dart";

import "package:flutter/foundation.dart";
import "package:minisound_platform_interface/minisound_platform_interface.dart";

export "package:minisound_platform_interface/minisound_platform_interface.dart"
    show
        AudioEncoding,
        MinisoundPlatformException,
        MinisoundPlatformOutOfMemoryException,
        SampleFormat;

part "rec.dart";

/// Controls audio recoding.
///
/// Should be initialized before doing anything.
final class Recorder {
  /// Creates the recorder.
  ///
  /// Creating multiple recorders working simulteniously is not recommended. Use multiple `Rec`s of a single recorder instead.
  ///
  /// `maxRecCount` - max simulteniously working recordings count. Affects performance of all core recorder operations in a linear way. Usually recording same data to multiple destinations is pointless, so this is pretty low by default.
  Recorder([int maxRecCount = 8]) : _recorder = PlatformRecorder(maxRecCount) {
    _finalizer.attach(this, _recorder);
  }

  static final _finalizer =
      Finalizer<PlatformRecorder>((recorder) => recorder.dispose());
  static final _recsFinalizer = Finalizer<PlatformRec>((rec) => rec.dispose());

  final PlatformRecorder _recorder;

  /// Initializes the recorder.
  ///
  /// `periodMs` - affects sounds latency (lower period means lower latency but possibble crackles). Clamped between `1` and `1000` (1s). Probably has no effect on the web.
  Future<void> init([int periodMs = 64]) =>
      _recorder.init(periodMs.clamp(1, 1000));

  /// Starts the recorder.
  Future<void> start() async => _recorder.start();

  /// Creates a file and starts recording into it.
  ///
  /// Parameters directly influence the resulting file size. If any are absent, they take values from the device, which is a bit faster.
  ///
  /// `encoding` - currently only WAV is supported, so there's no need in this parameter.
  /// `sampleFormat` - the amount of different amplitude levels of the data.
  /// `channelCount` - must be in range `1..254` inclusive.
  /// `sampleRate` - controls sound frequencies that can be properly captured in a recording. Must be in range `1000..384000` inclusive.
  Future<FileRec> saveRecFile(
    String filePath, {
    AudioEncoding encoding = AudioEncoding.wav,
    SampleFormat? sampleFormat,
    int? channelCount,
    int? sampleRate,
  }) =>
      kIsWeb
          ? throw UnimplementedError()
          : _saveRec(
              (recorder) => FileRec._(File(filePath), recorder),
              encoding: encoding,
              sampleFormat: sampleFormat,
              channelCount: channelCount,
              sampleRate: sampleRate,
            );

  /// Starts recording into in-RAM buffer. After the recording is stopped, it can be directly fed into `Engine::loadSound`.
  ///
  /// Parameters directly influence the resulting buffer size. If any are absent, they take values from the device, which is a bit faster.
  ///
  /// `encoding` - currently only WAV is supported, so there's no need in this parameter.
  /// `sampleFormat` - the amount of different amplitude levels of the data.
  /// `channelCount` - must be in range `1..254` inclusive.
  /// `sampleRate` - controls sound frequencies that can be properly captured in a recording. Must be in range `1000..384000` inclusive.
  Future<BufRec> saveRecBuf({
    AudioEncoding encoding = AudioEncoding.wav,
    SampleFormat? sampleFormat,
    int? channelCount,
    int? sampleRate,
  }) =>
      _saveRec(
        BufRec._,
        encoding: encoding,
        sampleFormat: sampleFormat,
        channelCount: channelCount,
        sampleRate: sampleRate,
      );

  Future<T> _saveRec<T extends Rec>(
    T Function(Recorder recorder) createRec, {
    required AudioEncoding encoding,
    required SampleFormat? sampleFormat,
    required int? channelCount,
    required int? sampleRate,
  }) async {
    if (channelCount != null) assert(1 <= channelCount && channelCount <= 254);
    if (sampleRate != null) assert(1000 <= sampleRate && sampleRate <= 384000);

    final rec = createRec(this);
    final platformRec = await _recorder.saveRec(
      encoding: encoding,
      sampleFormat: sampleFormat,
      channelCount: channelCount,
      sampleRate: sampleRate,
    );
    rec._rec = platformRec;
    _recsFinalizer.attach(rec, platformRec);
    return rec;
  }
}
