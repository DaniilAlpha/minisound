part of "minisound_web.dart";

final class WebRecorder implements PlatformRecorder {
  WebRecorder._(Pointer<c.Recorder> self) : _self = self;

  final Pointer<c.Recorder> _self;

  @override
  bool get isRecording => c.recorder_get_is_recording(_self);

  @override
  Future<void> initFile(
    String filename, {
    required int sampleRate,
    required int channels,
    required SoundFormat format,
  }) async {
    final r = await c.recorder_init_file(
      _self,
      filename,
      sampleRate,
      channels,
      format.toC(),
    );
    if (r != c.RecorderResult.RECORDER_OK) {
      throw MinisoundPlatformException(
          "Failed to initialize recorder with file. Error code: $r");
    }
  }

  @override
  Future<void> initStream({
    required int sampleRate,
    required int channels,
    required SoundFormat format,
    required double bufferLenS,
  }) async {
    final r = await c.recorder_init_stream(
      _self,
      sampleRate,
      channels,
      format.toC(),
      bufferLenS,
    );
    if (r != c.RecorderResult.RECORDER_OK) {
      throw MinisoundPlatformException(
          "Failed to initialize recorder stream. Error code: $r");
    }
  }

  @override
  void dispose() {
    c.recorder_uninit(_self);
    malloc.free(_self);
  }

  @override
  void start() {
    final r = c.recorder_start(_self);
    if (r != c.RecorderResult.RECORDER_OK) {
      throw MinisoundPlatformException("Failed to start recording (code: $r).");
    }
  }

  @override
  void stop() => c.recorder_stop(_self);

  @override
  int get availableFloatCount => c.recorder_get_available_float_count(_self);
  @override
  Float32List getBuffer(int floatsToRead) {
    final bufPtr = malloc.allocate<Float>(floatsToRead * sizeOf<Float>());
    if (bufPtr == nullptr) {
      throw MinisoundPlatformOutOfMemoryException();
    }

    final floatsRead = c.recorder_load_buffer(_self, bufPtr, floatsToRead);

    // copy data from allocated C memory to Dart list
    final buffer = Float32List.fromList(bufPtr.asTypedList(floatsRead));

    malloc.free(bufPtr);

    return buffer;
  }
}
