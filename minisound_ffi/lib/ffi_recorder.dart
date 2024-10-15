part of "minisound_ffi.dart";

class FfiRecording implements PlatformRecording {
  FfiRecording._(Pointer<c.Recording> self) : _self = self;

  final Pointer<c.Recording> _self;

  @override
  Uint8List get buffer => _bindings
      .recording_get_buf(_self)
      .asTypedList(_bindings.recording_get_size(_self));

  @override
  void dispose() {
    _bindings.recording_uninit(_self);
    malloc.free(_self);
  }
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
  FfiRecording stop() => FfiRecording._(_bindings.recorder_stop(_self));
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
