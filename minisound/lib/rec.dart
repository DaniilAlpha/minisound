part of "recorder.dart";

abstract class Rec<T> {
  Rec._(Recorder recorder) : _recorder = recorder;

  final Recorder _recorder;
  late final PlatformRec _rec;

  /// Whether the recording is currently being recorded or not.
  ///
  /// Returns `false` when it's either paused or ended.
  bool get isRecording => _recorder._recorder.isRecording(_rec);

  /// Continues the recording if was paused.
  void resume() => _recorder._recorder.resumeRec(_rec);

  /// Stops recording, but don't ends it yet.
  ///
  /// Gives less latency than starting a new recording, so if data should come in sequence, this should be used instead.
  void pause() => _recorder._recorder.pauseRec(_rec);

  /// Stops recording and ends it. Cannot be resumed after this call.
  Future<T> end();

  Future<void> _end() async {
    await _rec.end();

    // meant for waiting until audio thread finishes its job, not sure if really needed
    await Future.delayed(const Duration(milliseconds: 50));
  }
}

/// A recording that provides its buffer after it's ended.
final class BufRec extends Rec<Uint8List> {
  BufRec._(super.recorder) : super._();

  @override
  Future<Uint8List> end() async {
    await super._end();
    return _rec.data;
  }
}

/// A recording that is written into a file immediately when ended.
final class FileRec extends Rec<File> {
  FileRec._(File file, super.recorder)
      : _file = file,
        super._();

  final File _file;

  @override
  Future<File> end() async {
    await super._end();
    await (_file..createSync()).writeAsBytes(_rec.data, flush: true);
    return _file;
  }
}
