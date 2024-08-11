part of "minisound_ffi.dart";

final class FfiEngine implements PlatformEngine {
  FfiEngine._(Pointer<c.Engine> self) : _self = self;

  final Pointer<c.Engine> _self;

  @override
  Future<void> init(int periodMs) async {
    final r = _bindings.engine_init(_self, periodMs);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException("Failed to init the engine (code: $r).");
    }
  }

  @override
  void dispose() {
    _bindings.engine_uninit(_self);
    malloc.free(_self);
  }

  @override
  void start() {
    final r = _bindings.engine_start(_self);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException(
          "Failed to start the engine (code: $r).");
    }
  }

  @override
  Future<PlatformSound> loadSound(AudioData audioData) async {
    final dataPtr = malloc.allocate<Float>(audioData.buffer.length);
    if (dataPtr == nullptr) {
      throw MinisoundPlatformOutOfMemoryException();
    }

    // TODO! maybe was needed
    // final floatList = dataPtr.asTypedList(audioData.buffer.length);
    // floatList.setAll(0, audioData.buffer);

    final sound = _bindings.sound_alloc();
    if (sound == nullptr) {
      malloc.free(dataPtr);
      throw MinisoundPlatformException("Failed to allocate a sound.");
    }

    final r = _bindings.engine_load_sound(
      _self,
      sound,
      dataPtr,
      audioData.buffer.lengthInBytes,
      audioData.format.toC(),
      audioData.sampleRate,
      audioData.channels,
    );

    if (r != c.Result.Ok) {
      malloc.free(dataPtr);
      malloc.free(sound);
      throw MinisoundPlatformException("Failed to load a sound (code: $r).");
    }

    return FfiSound._fromPtrs(sound, dataPtr);
  }
}
