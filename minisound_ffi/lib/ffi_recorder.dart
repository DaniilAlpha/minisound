part of "minisound_ffi.dart";

class FfiRecording implements PlatformRecording {
  FfiRecording._(c.RecorderBufferFlush self) : _self = self;

  final c.RecorderBufferFlush _self;

  @override
  Uint8List get buffer => _self.buf.asTypedList(_self.size);

  @override
  void dispose() => malloc.free(_self.buf);
}

class FfiRecorder implements PlatformRecorder {
  FfiRecorder._(Pointer<c.Recorder> self) : _self = self;

  final Pointer<c.Recorder> _self;

  @override
  bool get isRecording => _bindings.recorder_get_is_recording(_self);

  @override
  Future<void> init({
    required RecorderFormat format,
    required int channelCount,
    required int sampleRate,
  }) async {
    final r =
        _bindings.recorder_init(_self, format.toC(), channelCount, sampleRate);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException(
          "Failed to initialize recorder with file (code: $r).");
    }
  }

  @override
  void dispose() {
    _bindings.recorder_uninit(_self);
    malloc.free(_self);
  }

  @override
  void start() {
    final r = _bindings.recorder_start(
      _self,
      c.RecordingEncoding.RECORDING_ENCODING_WAV,
    );
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException(
          "Failed to start the recorder (code: $r).");
    }
  }

  @override
  FfiRecording flush() {
    if (!_bindings.recorder_get_is_recording(_self)) {
      throw MinisoundPlatformException("Recorder has no data.");
    }
    final recording = _bindings.recorder_flush(_self);
    return FfiRecording._(recording);
  }

  @override
  FfiRecording stop() {
    if (!_bindings.recorder_get_is_recording(_self)) {
      throw MinisoundPlatformException("Recorder has no data.");
    }
    final recording = _bindings.recorder_stop(_self);
    return FfiRecording._(recording);
  }
}

extension on RecorderFormat {
  int toC() => switch (this) {
        RecorderFormat.u8 => c.RecorderFormat.RECORDER_FORMAT_U8,
        RecorderFormat.s16 => c.RecorderFormat.RECORDER_FORMAT_S16,
        RecorderFormat.s24 => c.RecorderFormat.RECORDER_FORMAT_S24,
        RecorderFormat.s32 => c.RecorderFormat.RECORDER_FORMAT_S32,
        RecorderFormat.f32 => c.RecorderFormat.RECORDER_FORMAT_F32,
      };
}
