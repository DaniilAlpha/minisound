part of "minisound_ffi.dart";

class FfiRecorder implements PlatformRecorder {
  FfiRecorder._(int maxRecCount) : _self = _binds.recorder_alloc(maxRecCount) {
    if (_self == nullptr) throw MinisoundPlatformOutOfMemoryException();
  }

  final Pointer<c.Recorder> _self;

  @override
  Future<void> init(int periodMs) async {
    final r = _binds.recorder_init(_self, periodMs);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException(
          "Failed to init the recorder (code: $r).");
    }
  }

  @override
  void dispose() {
    _binds.recorder_uninit(_self);
    malloc.free(_self);
  }

  @override
  void start() {
    final r = _binds.recorder_start(_self);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException(
        "Failed to start the recorder (code: $r).",
      );
    }
  }

  @override
  bool isRecording(PlatformRec rec) {
    rec as FfiRec;

    return _binds.recorder_get_is_recording(_self, rec._self);
  }

  @override
  FfiRec record({
    required RecEncoding encoding,
    required RecFormat format,
    required int channelCount,
    required int sampleRate,
    required int dataAvailabilityThresholdMs,
    required void Function(Uint8List data) onDataFn,
    required void Function(int offset, int origin) seekDataFn,
  }) {
    final outRec = malloc.allocate<Pointer<c.Rec>>(sizeOf<Pointer<c.Rec>>());
    if (outRec == nullptr) throw MinisoundPlatformOutOfMemoryException();
    final r = _binds.recorder_record(
      _self,
      encoding.toC(),
      format.toC(),
      channelCount,
      sampleRate,
      dataAvailabilityThresholdMs,
      Pointer.fromFunction(_onDataFn),
      Pointer.fromFunction(_seekDataFn),
      outRec,
    );
    final rec = outRec.value;
    malloc.free(outRec);

    if (r != c.Result.Ok) {
      throw MinisoundPlatformException(
        "Failed to recor (code: $r).",
      );
    }

    return FfiRec._(rec);
  }

  @override
  void pauseRec(PlatformRec rec) {
    rec as FfiRec;

    final r = _binds.recorder_pause_rec(_self, rec._self);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException(
        "Failed to pause the recording (code: $r).",
      );
    }
  }

  @override
  void resumeRec(PlatformRec rec) {
    rec as FfiRec;

    final r = _binds.recorder_resume_rec(_self, rec._self);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException(
        "Failed to resume the recording (code: $r).",
      );
    }
  }

  @override
  void stopRec(PlatformRec rec) {
    rec as FfiRec;

    final r = _binds.recorder_stop_rec(_self, rec._self);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException(
        "Failed to stop the recording (code: $r).",
      );
    }
  }

  static void _onDataFn(Pointer<c.Rec> rec) {
    // (Pointer<c.Rec> rec) => onDataFn(FfiRec._(rec).read()),
  }
  static void _seekDataFn(Pointer<c.Rec> rec, int off, int origin) {
    // (Pointer<c.Rec> rec, int off, int origin) => seekDataFn(off, origin),
  }
}

extension on RecEncoding {
  c.RecEncoding toC() => switch (this) {
        // RecEncoding.raw => c.RecEncoding.REC_ENCODING_RAW,
        RecEncoding.wav => c.RecEncoding.REC_ENCODING_WAV,
      };
}

extension on RecFormat {
  c.RecFormat toC() => switch (this) {
        RecFormat.u8 => c.RecFormat.REC_FORMAT_U8,
        RecFormat.s16 => c.RecFormat.REC_FORMAT_S16,
        RecFormat.s24 => c.RecFormat.REC_FORMAT_S24,
        RecFormat.s32 => c.RecFormat.REC_FORMAT_S32,
        RecFormat.f32 => c.RecFormat.REC_FORMAT_F32,
      };
}
