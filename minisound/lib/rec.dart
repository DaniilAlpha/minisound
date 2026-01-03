part of "recorder.dart";

abstract class Rec {
  Rec._(Recorder recorder) : _recorder = recorder;

  final Recorder _recorder;

  late final PlatformRec _rec;

  bool get isRecording => _recorder._recorder.isRecording(_rec);

  /// Continues the recording if was paused.
  void resume() => _recorder._recorder.resumeRec(_rec);

  /// Stops recording, but don't ends it yet.
  ///
  /// Gives less latency than starting a new recording, so if data should come sequentially, use this instead.
  void pause() => _recorder._recorder.pauseRec(_rec);

  /// Stops recording and ends it. Cannot be resumed after this call.
  void stop() => _recorder._recorder.stopRec(_rec);

  void _onData(Uint8List data);
  void _seekData(int offset, int origin);
}

final class FileRec extends Rec {
  FileRec._(this.file, super.recorder) : super._() {
    file.createSync();
    _wfile = file.openSync(mode: FileMode.writeOnly);
  }

  final File file;
  late final RandomAccessFile _wfile;

  @override
  void stop() {
    super.stop();

    _wfile.writeFromSync([1, 2, 3, 4, 5, 65]);
    _wfile.closeSync();
  }

  @override
  void _onData(Uint8List data) {
    _wfile.writeFromSync(data);
  }

  @override
  void _seekData(int offset, int origin) {
    _wfile.setPositionSync(switch (origin) {
      0 => offset,
      1 => _wfile.positionSync() + offset,
      2 => _wfile.lengthSync() - offset,
      _ => _wfile.positionSync(),
    });
  }
}

final class RamRec extends Rec {
  RamRec._(super.recorder) : super._();

  // TODO takes 8x more RAM, but i currently have no idea how to do it in another way
  final List<int> buf = [];
  var position = 0;

  Uint8List? _data;
  Uint8List? get data => _data;

  @override
  void stop() {
    super.stop();
    _data = Uint8List.fromList(buf);
    buf.clear();
    position = 0;
  }

  @override
  void _onData(Uint8List data) {
    final endPosition = position + data.length;
    if (position < buf.length) {
      final existingEndPosition = math.min(buf.length, endPosition);
      buf.setRange(position, existingEndPosition, data);
      position = existingEndPosition;
    }
    if (endPosition > buf.length) {
      buf.addAll(data.skip(endPosition - position));
      position = endPosition;
    }
  }

  @override
  void _seekData(int offset, int origin) => position = switch (origin) {
        0 => offset,
        1 => position + offset,
        2 => buf.length - offset,
        _ => position,
      };
}
