export "package:minisound_platform_interface/minisound_platform_interface.dart"
    show
        MinisoundPlatformException,
        MinisoundPlatformOutOfMemoryException,
        NoiseType,
        WaveformType;

// /// A generator for waveforms and noise.
// final class Generator {
//   Generator({Engine? mainEngine}) : engine = mainEngine ?? Engine();
//
//   final _generator = PlatformGenerator();
//
//   final Engine engine;
//
//   bool _isInit = false;
//   bool get isInit => _isInit;
//
//   bool _isGenerating = false;
//   bool get isGenerating => _isGenerating;
//
//   double get volume => _generator.volume;
//   set volume(double value) => _generator.volume = value < 0 ? 0 : value;
//
//   /// Initializes the generator's engine.
//   Future initEngine([int periodMs = 10]) async => engine.init(periodMs);
//
//   /// Initializes the generator.
//   Future<void> init({
//     SoundFormat format = SoundFormat.f32,
//     int channels = 1,
//     int sampleRate = 44100,
//     double bufferLenS = 5,
//   }) async {
//     if (!_isInit) {
//       if (!engine.isInit) await initEngine();
//
//       await _generator.init(
//         format: format,
//         channels: channels,
//         sampleRate: sampleRate,
//         bufferLenS: bufferLenS,
//       );
//
//       _isInit = true;
//     }
//   }
//
//   /// Disposes of the generator resources.
//   void dispose() => _generator.dispose();
//
//   /// Sets the waveform type, frequency, and amplitude.
//   void setWaveform({
//     GeneratorWaveformType type = GeneratorWaveformType.sine,
//     double frequency = 440.0,
//     double amplitude = 0.5,
//   }) =>
//       _generator.setWaveform(
//         type: type,
//         frequency: frequency,
//         amplitude: amplitude,
//       );
//
//   /// Sets the pulse wave frequency, amplitude, and duty cycle.
//   void setPulsewave({
//     double frequency = 440.0,
//     double amplitude = 0.5,
//     double dutyCycle = 0.5,
//   }) =>
//       _generator.setPulsewave(
//         frequency: frequency,
//         amplitude: amplitude,
//         dutyCycle: dutyCycle,
//       );
//
//   /// Sets the noise type, seed, and amplitude.
//   void setNoise({
//     GeneratorNoiseType type = GeneratorNoiseType.white,
//     int seed = 0,
//     double amplitude = 0.5,
//   }) =>
//       _generator.setNoise(type: type, seed: seed, amplitude: amplitude);
//
//   /// Starts the generator.
//   void start() {
//     _generator.start();
//     _isGenerating = true;
//   }
//
//   /// Stops the generator.
//   void stop() {
//     _generator.stop();
//     _isGenerating = false;
//   }
//
//   /// Gets the number of available frames in the generator's buffer.
//   int get availableFloatCount => _generator.availableFloatCount;
//
//   /// Reads generated data.
//   Float32List getBuffer(int floatsToRead) => _generator.getBuffer(floatsToRead);
// }
