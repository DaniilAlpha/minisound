part of "minisound_ffi.dart";

class FfiRecording implements PlatformRecording {
  FfiRecording._(Pointer<c.Recording> self) : _self = self;

  final Pointer<c.Recording> _self;

  @override
  Uint8List get buffer => _binds
      .recording_get_buf(_self)
      .asTypedList(_binds.recording_get_size(_self));

  @override
  void dispose() {
    _binds.recording_uninit(_self);
    malloc.free(_self);
  }
}

class FfiRecorder implements PlatformRecorder {
  FfiRecorder._() : _self = _binds.recorder_alloc() {
    if (_self == nullptr) throw MinisoundPlatformOutOfMemoryException();
  }

  final Pointer<c.Recorder> _self;

  @override
  bool get isRecording => _binds.recorder_get_is_recording(_self);

  @override
  Future<void> init() async {
    final r = _binds.recorder_init(_self);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException(
        "Failed to init the recorder (code: $r).",
      );
    }
  }

  @override
  void dispose() {
    _binds.recorder_uninit(_self);
    malloc.free(_self);
  }

  @override
  void start({
    required RecordingFormat format,
    required int channelCount,
    required int sampleRate,
  }) {
    final r = _binds.recorder_start(
      _self,
      c.RecordingEncoding.RECORDING_ENCODING_WAV,
      format.toC(),
      channelCount,
      sampleRate,
    );
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException(
        "Failed to start the recorder (code: $r).",
      );
    }
  }

  @override
  FfiRecording stop() {
    if (!_binds.recorder_get_is_recording(_self)) {
      throw MinisoundPlatformException("Recording is not started.");
    }
    final recording = _binds.recorder_stop(_self);
    if (recording == nullptr) throw MinisoundPlatformOutOfMemoryException();
    return FfiRecording._(recording);
  }
}

extension on RecordingFormat {
  c.RecordingFormat toC() => switch (this) {
    RecordingFormat.u8 => c.RecordingFormat.RECORDING_FORMAT_U8,
    RecordingFormat.s16 => c.RecordingFormat.RECORDING_FORMAT_S16,
    RecordingFormat.s24 => c.RecordingFormat.RECORDING_FORMAT_S24,
    RecordingFormat.s32 => c.RecordingFormat.RECORDING_FORMAT_S32,
    RecordingFormat.f32 => c.RecordingFormat.RECORDING_FORMAT_F32,
  };
}
