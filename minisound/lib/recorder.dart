import "dart:async";
import "dart:io";
import "dart:isolate";
import "dart:math" as math;
import "dart:typed_data";

import "package:minisound_platform_interface/minisound_platform_interface.dart";

export "package:minisound_platform_interface/minisound_platform_interface.dart"
    show
        MinisoundPlatformException,
        MinisoundPlatformOutOfMemoryException,
        RecEncoding,
        RecFormat;

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
  /// `periodMs` - affects sounds latency (lower period means lower latency but possibble crackles). Clamped between `0` and `1000` (1s). Probably has no effect on the web.
  Future<void> init([int periodMs = 32]) =>
      _recorder.init(periodMs.clamp(0, 1000));

  /// Starts the recorder.
  Future<void> start() async => _recorder.start();

  /// Creates a file and starts recording into it.
  ///
  /// Parameters directly influence the resulting file size.
  ///
  /// `encoding` - currently only WAV is supported, so there's no need in this parameter.
  /// `format` - the amount of different amplitude levels of the data. S16 is a standard value.
  /// `channelCount` - must be in range `1..254` inclusive. Using `1` (in case mono audio is ok) will reduce data size in half.
  /// `sampleRate` - controls sound frequencies that can be properly captured in a recording. Must be in range `1000..384000` inclusive. `44100` is a standard value.
  /// `dataAvailabilityThresholdMs` - the period before new data is written to a file. Clamped between the recorder period and `1000`.
  FileRec recordFile(
    String filePath, {
    RecEncoding encoding = RecEncoding.wav,
    RecFormat format = RecFormat.s16,
    int channelCount = 2,
    int sampleRate = 44100,
    int dataAvailabilityThresholdMs = 0,
  }) =>
      _record(
        (recorder) => FileRec._(File(filePath), recorder),
        encoding: encoding,
        format: format,
        channelCount: channelCount,
        sampleRate: sampleRate,
        dataAvailabilityThresholdMs: dataAvailabilityThresholdMs,
      );

  /// Starts recording into in-RAM buffer. After the recording is stopped, it can be directly fed into `Engine::loadSound`.
  ///
  /// Parameters directly influence the resulting buffer size.
  ///
  /// `encoding` - currently only WAV is supported, so there's no need in this parameter.
  /// `format` - the amount of different amplitude levels of the data. S16 is a standard value.
  /// `channelCount` - must be in range `1..254` inclusive. Using `1` (in case mono audio is ok) will reduce data size in half.
  /// `sampleRate` - controls sound frequencies that can be properly captured in a recording. Must be in range `1000..384000` inclusive. `44100` is a standard value.
  /// `dataAvailabilityThresholdMs` - the period before new data is written to a file. Clamped between the recorder period and `1000`.
  RamRec recordRam({
    RecEncoding encoding = RecEncoding.wav,
    RecFormat format = RecFormat.s16,
    int channelCount = 2,
    int sampleRate = 44100,
    int dataAvailabilityThresholdMs = 0,
  }) =>
      _record(
        RamRec._,
        encoding: encoding,
        format: format,
        channelCount: channelCount,
        sampleRate: sampleRate,
        dataAvailabilityThresholdMs: dataAvailabilityThresholdMs,
      );

  T _record<T extends Rec>(
    T Function(Recorder recorder) createRec, {
    RecEncoding encoding = RecEncoding.wav,
    RecFormat format = RecFormat.s16,
    int channelCount = 2,
    int sampleRate = 44100,
    int dataAvailabilityThresholdMs = 0,
  }) {
    assert(1 <= channelCount && channelCount <= 254);
    assert(1000 <= sampleRate && sampleRate <= 384000);

    final rec = createRec(this);
    final platformRec = _recorder.record(
      encoding: encoding,
      format: format,
      channelCount: channelCount,
      sampleRate: sampleRate,
      dataAvailabilityThresholdMs: dataAvailabilityThresholdMs.clamp(0, 1000),
      onDataFn: rec._onData,
      seekDataFn: rec._seekData,
    );
    rec._rec = platformRec;
    _recsFinalizer.attach(rec, platformRec);
    return rec;
  }
}
