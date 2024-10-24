part of "minisound_web.dart";

class WebRecording implements PlatformRecording {
  WebRecording._(c.Recording self) : _self = self;

  final c.Recording _self;

  @override
  Uint8List get buffer => _self.buf.asTypedList(_self.size);

  @override
  void dispose() => malloc.free(_self.buf);
}

class WebRecorder implements PlatformRecorder {
  WebRecorder._(Pointer<c.Recorder> self) : _self = self;

  final Pointer<c.Recorder> _self;

  @override
  bool get isRecording => c.recorder_get_is_recording(_self);

  @override
  Future<void> init({
    required RecorderFormat format,
    required int channelCount,
    required int sampleRate,
  }) async {
    final r =
        await c.recorder_init(_self, format.toC(), channelCount, sampleRate);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException(
          "Failed to initialize recorder with file (code: $r).");
    }
  }

  @override
  void dispose() {
    c.recorder_uninit(_self);
    malloc.free(_self);
  }

  @override
  void start() {
    final r = c.recorder_start(
      _self,
      c.RecordingEncoding.RECORDING_ENCODING_WAV,
    );
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException(
          "Failed to start the recorder (code: $r).");
    }
  }

  @override
  WebRecording stop() {
    if (!c.recorder_get_is_recording(_self)) {
      throw MinisoundPlatformException("Recording has no data.");
    }
    final recording = c.recorder_stop(_self);
    return WebRecording._(recording);
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
