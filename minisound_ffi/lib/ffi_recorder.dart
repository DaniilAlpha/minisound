part of "minisound_ffi.dart";

class FfiRecorder implements PlatformRecorder {
  FfiRecorder._(Pointer<c.Recorder> self) : _self = self;

  final Pointer<c.Recorder> _self;

  @override
  bool get isRecording => _bindings.recorder_is_recording(_self);

  @override
  Future<void> initFile(
    String filename, {
    required int sampleRate,
    required int channels,
    required SoundFormat format,
  }) async {
    final filenamePtr = filename.toNativeUtf8();
    try {
      final r = _bindings.recorder_init_file(
        _self,
        filenamePtr.cast(),
        sampleRate,
        channels,
        format.toC(),
      );
      if (r != c.RecorderResult.RECORDER_OK) {
        throw MinisoundPlatformException(
            "Failed to initialize recorder with file (code: $r).");
      }
    } finally {
      malloc.free(filenamePtr);
    }
  }

  @override
  Future<void> initStream({
    required int sampleRate,
    required int channels,
    required SoundFormat format,
    required int bufferDurationSeconds,
  }) async {
    final r = _bindings.recorder_init_stream(
      _self,
      sampleRate,
      channels,
      format.toC(),
      bufferDurationSeconds,
    );
    if (r != c.RecorderResult.RECORDER_OK) {
      throw MinisoundPlatformException(
          "Failed to initialize recorder stream (code: $r).");
    }
  }

  @override
  void dispose() => _bindings.recorder_destroy(_self);

  @override
  void start() {
    final r = _bindings.recorder_start(_self);
    if (r != c.RecorderResult.RECORDER_OK) {
      throw MinisoundPlatformException("Failed to start recording (code: $r).");
    }
  }

  @override
  void stop() {
    final r = _bindings.recorder_stop(_self);
    if (r != c.RecorderResult.RECORDER_OK) {
      throw MinisoundPlatformException("Failed to stop recording (code: $r).");
    }
  }

  @override
  int getAvailableFrames() => _bindings.recorder_get_available_frames(_self);
  @override
  Float32List getBuffer(int framesToRead) {
    // TODO! probably should multiply by channels, but cannot test at the moment
    final floatsToRead = framesToRead * sizeOf<Float>();

    final bufPtr = malloc.allocate<Float>(floatsToRead);
    if (bufPtr == nullptr) {
      throw MinisoundPlatformOutOfMemoryException();
    }

    final floatsRead =
        _bindings.recorder_get_buffer(_self, bufPtr, floatsToRead);

    // copy data from allocated C memory to Dart list
    final buffer = Float32List.fromList(bufPtr.asTypedList(floatsRead));

    malloc.free(bufPtr);

    return buffer;
  }
}
