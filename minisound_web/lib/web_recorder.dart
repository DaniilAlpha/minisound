part of "minisound_web.dart";

class WebRecorder implements PlatformRecorder {
  WebRecorder._(int maxRecCount) : _self = _binds.recorder_alloc(maxRecCount) {
    if (_self == nullptr) throw MinisoundPlatformOutOfMemoryException();
  }

  final Pointer<c.Recorder> _self;

  @override
  Future<void> init(int periodMs) async {
    final r = await _binds.recorder_init(_self, periodMs);
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
    rec as WebRec;

    return _binds.recorder_get_is_recording(_self, rec._self);
  }

  @override
  Future<WebRec> saveRec({
    required AudioEncoding encoding,
    required SampleFormat sampleFormat,
    required int channelCount,
    required int sampleRate,
  }) async {
    final rec = _binds.rec_alloc();
    if (rec == nullptr) throw MinisoundPlatformOutOfMemoryException();

    final dataPtr = malloc.allocate<Pointer<Uint8>>(sizeOf<Pointer<Uint8>>());
    if (dataPtr == nullptr) {
      malloc.free(rec);
      throw MinisoundPlatformOutOfMemoryException();
    }
    final dataSizePtr = malloc.allocate<Size>(sizeOf<Size>());
    if (dataSizePtr == nullptr) {
      malloc.free(dataPtr);
      malloc.free(rec);
      throw MinisoundPlatformOutOfMemoryException();
    }

    final r = _binds.recorder_save_rec(
      _self,
      rec,
      encoding.toC(),
      sampleFormat.toC(),
      channelCount,
      sampleRate,
      dataPtr,
      dataSizePtr,
    );
    if (r != c.Result.Ok) {
      malloc.free(rec);
      throw MinisoundPlatformException(
        "Failed to save a recording (code: $r).",
      );
    }

    return WebRec._(rec, dataPtr, dataSizePtr);
  }

  @override
  void pauseRec(PlatformRec rec) {
    rec as WebRec;

    final r = _binds.recorder_pause_rec(_self, rec._self);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException(
        "Failed to pause the recording (code: $r).",
      );
    }
  }

  @override
  void resumeRec(PlatformRec rec) {
    rec as WebRec;

    final r = _binds.recorder_resume_rec(_self, rec._self);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException(
        "Failed to resume the recording (code: $r).",
      );
    }
  }
}
