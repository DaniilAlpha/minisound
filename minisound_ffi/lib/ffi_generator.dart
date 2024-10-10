part of "minisound_ffi.dart";

/* class FfiGenerator implements PlatformGenerator {
  FfiGenerator._(Pointer<c.Generator> self) : _self = self;

  final Pointer<c.Generator> _self;

  late var _volume = _bindings.generator_get_volume(_self);
  @override
  double get volume => _volume;
  @override
  set volume(double value) {
    _bindings.generator_set_volume(_self, value);
    _volume = value;
  }

  @override
  Future<void> init({
    required SoundFormat format,
    required int channels,
    required int sampleRate,
    required double bufferLenS,
  }) async {
    final r = _bindings.generator_init(
      _self,
      format.toC(),
      channels,
      sampleRate,
      bufferLenS,
    );
    if (r != c.GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException(
          "Failed to initialize generator (code: $r).");
    }
  }

  @override
  void dispose() {
    _bindings.generator_uninit(_self);
    malloc.free(_self);
  }

  @override
  void setWaveform({
    required GeneratorWaveformType type,
    required double frequency,
    required double amplitude,
  }) {
    final r = _bindings.generator_set_waveform(
      _self,
      type.toC(),
      frequency,
      amplitude,
    );
    if (r != c.GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException("Failed to set waveform (code: $r).");
    }
  }

  @override
  void setPulsewave({
    required double frequency,
    required double amplitude,
    required double dutyCycle,
  }) {
    final r = _bindings.generator_set_pulsewave(
      _self,
      frequency,
      amplitude,
      dutyCycle,
    );
    if (r != c.GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException("Failed to set pulse wave (code: $r).");
    }
  }

  @override
  void setNoise({
    required GeneratorNoiseType type,
    required double amplitude,
    required int seed,
  }) {
    final r = _bindings.generator_set_noise(_self, type.toC(), seed, amplitude);
    if (r != c.GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException("Failed to set noise (code: $r).");
    }
  }

  @override
  void start() {
    final r = _bindings.generator_start(_self);
    if (r != c.GeneratorResult.GENERATOR_OK) {
      throw MinisoundPlatformException("Failed to start generator (code: $r).");
    }
  }

  @override
  void stop() => _bindings.generator_stop(_self);

  @override
  int get availableFloatCount =>
      _bindings.generator_get_available_float_count(_self);
  @override
  Float32List getBuffer(int floatsToRead) {
    final bufPtr = malloc.allocate<Float>(floatsToRead * sizeOf<Float>());
    if (bufPtr == nullptr) {
      throw MinisoundPlatformOutOfMemoryException();
    }

    final floatsRead =
        _bindings.generator_load_buffer(_self, bufPtr, floatsToRead);

    // copy data from allocated C memory to Dart list
    final buffer = Float32List.fromList(bufPtr.asTypedList(floatsRead));

    malloc.free(bufPtr);

    return buffer;
  }
}

 */
