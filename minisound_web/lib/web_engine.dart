part of "minisound_web.dart";

final class WebEngine implements PlatformEngine {
  WebEngine._(Pointer<c.Engine> self) : _self = self;

  final Pointer<c.Engine> _self;

  @override
  Future<void> init(int periodMs) async {
    final r = await c.engine_init(_self, periodMs);
    if (r != c.Result.Ok) {
      throw MinisoundPlatformException("Failed to init the engine (code: $r).");
    }
  }

  @override
  void dispose() {
    c.engine_uninit(_self);
    malloc.free(_self);
  }

  @override
  void start() {
    final r = c.engine_start(_self);
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

    heap.copyAudioData(dataPtr, audioData.buffer, audioData.format);

    final sound = c.sound_alloc(audioData.buffer.lengthInBytes);
    if (sound == nullptr) {
      malloc.free(dataPtr);
      throw MinisoundPlatformException("Failed to allocate a sound.");
    }

    final r = c.engine_load_sound(
      _self,
      sound,
      dataPtr,
      audioData.buffer.lengthInBytes,
      audioData.format.toC(),
      audioData.channels,
      audioData.sampleRate,
    );
    if (r != c.Result.Ok) {
      malloc.free(dataPtr);
      malloc.free(sound);
      throw MinisoundPlatformException("Failed to load a sound (code: $r).");
    }

    return WebSound._fromPtrs(sound, dataPtr);
  }
}
