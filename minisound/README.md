# minisound

A high-level real-time audio playback library based on [miniaudio](https://miniaud.io). The library offers basic functionality and quite low latency. Not really suitable for big sounds right now. Supports MP3, WAV and FLAC formats.

Run `make help` from the root project directory to get started.

## Platform support

| Platform | Tested     | Supposed to work | Unsupported |
| -------- | -----------| -----------------| ------------|
| Android | SDK 31, 19  | SDK 16+          | SDK 15-     |
| iOS     | None        | Unknown          | Unknown     |
| Windows | 11, 7 (x64) | Vista+           | XP-         |
| macOS   | None        | Unknown          | Unknown     |
| Linux   | Fedora 39-40, Mint 22 | Any    | None        |
| Web     | Chrome 93+, Firefox 79+, Safari 16+ | Browsers with an `AudioWorklet` support | Browsers without an `AudioWorklet` support |

## Getting started on the web

While the main script is quite large, there are a loader script provided. Include it in the `web/index.html` file like this

```html
  <script src="assets/packages/minisound_web/build/minisound_web.loader.js"></script>
```

> It is highly recommended NOT to make the script `defer`, as loading may not work properly. Also, it is very small (only 18 lines).

And at the bottom, at the body's `<script>` do like this

```js
                                // ADD 'async'
window.addEventListener('load', async function (ev) {
    {{flutter_js}}
    {{flutter_build_config}}

    // ADD THIS LINE TO LOAD THE LIBRARY 
    await _minisound.loader.load();

    // LEAVE THE REST IN PLACE
    // Download main.dart.js
    _flutter.loader.load({
        serviceWorker: {
            serviceWorkerVersion: {{flutter_service_worker_version}},
        },
        onEntrypointLoaded: function (engineInitializer) {
            engineInitializer.initializeEngine().then(function (appRunner) {
                appRunner.runApp();
            });
        },
    });
    }
  );
```

`Minisound` uses `SharedArrayBuffer` feature, so you should [enable cross-origin isolation on your site](https://web.dev/cross-origin-isolation-guide/).

## Usage

To use this plugin, add `minisound` as a [dependency in your pubspec.yaml file](https://flutter.dev/platform-plugins/).

```dart
import "package:minisound/engine.dart" as minisound;

void main() {
  final engine = minisound.Engine();

  // this method takes an update period in milliseconds as an argument, which
  // determines the length of the latency (does not currently affect the web)
  await engine.init(); 

  // there is also a 'loadSound' method to load a sound from the Uint8List
  final sound = await engine.loadSoundAsset("asset/path.ext");
  sound.volume = 0.5;

  // this may cause a MinisoundPlatformException to be thrown on the web
  // before any user interaction due to the autoplay policy
  await engine.start(); 

  sound.play();

  await Future.delayed(sound.duration*.5);

  sound.pause(); // this method saves sound position
  sound.stop(); // but this does not

  final loopDelay=Duratoin(seconds: 1);
  sound.playLooped(delay: loopDelay); // sound will be looped with one second period

  await Future.delayed((sound.duration + loopDelay) * 5); // sound duration does not account loop delay

  sound.stop();

  // it is recommended to unload sounds manually to prevent memory leaks
  sound.unload(); 

  // the engine and all loaded sounds will be automatically disposed when 
  // engine gets garbage-collected
}
```

### Recorder Example

```dart
import "package:minisound/recorder.dart" as minisound;

void main() async {
  final recorder = minisound.Recorder();

  // Initialize the recorder's engine
  await recorder.initEngine();

  // Initialize the recorder for streaming
  await recorder.initStream(
    sampleRate: 48000,
    channels: 1,
    format: minisound.AudioFormat.float32,
    bufferLenS: 5,
  );

  // Start recording
  recorder.start();

  // Wait for some time while recording
  await Future.delayed(Duration(seconds: 5));

  // Stop recording
  recorder.stop();

  // Get the recorded buffer
  final buffer = recorder.getBuffer(recorder.availableFloatCount);

  // Process the recorded buffer as needed
  // ...

  // Dispose of the recorder resources
  recorder.dispose();
}
```

### Generator Example

```dart
import "package:minisound/generator.dart" as minisound;

void main() async {
  final generator = minisound.Generator();

  // Initialize the generator's engine
  await generator.initEngine();

  // Initialize the generator
  await generator.init(
    minisound.AudioFormat.float32,
    2,
    48000,
    5,
  );

  // Set the waveform type, frequency, and amplitude
  generator.setWaveform(minisound.WaveformType.sine, 440.0, 0.5);

  // Set the noise type, seed, and amplitude
  generator.setNoise(minisound.NoiseType.white, 0, 0.2);

  // Start the generator
  generator.start();

  // Generate and process audio data in a loop
  while (true) {
    final buffer = generator.getBuffer(generator.availableFloatCount);

    // Process the generated buffer as needed
    // ...

    await Future.delayed(Duration(milliseconds: 100));
  }

  // Stop the generator
  generator.stop();

  // Dispose of the generator resources
  generator.dispose();
}
```

## Building the project

A Makefile is provided with recipes to build the project and ease development. Type `make help` to see a list of available commands.

To manually build the project, follow these steps:

1. Initialize the submodules:

    ```bash
    git submodule update --init --recursive
    ```

2. Run the following commands to build the project using emcmake:

    ```bash
    emcmake cmake -S ./minisound_ffi/src/ -B ./minisound_web/lib/build/cmake_stuff 
    cmake --build ./minisound_web/lib/build/cmake_stuff 
    ```

    If you encounter issues or want to start fresh, clean the `build` folder and rerun the cmake commands:

    ```bash
    rm -rf *
    emcmake cmake -S ./minisound_ffi/src/ -B ./minisound_web/lib/build/cmake_stuff 
    cmake --build ./minisound_web/lib/build/cmake_stuff 
    ```

4. For development work, it's useful to run `ffigen` from the `minisound_ffi` directory:

    ```bash
    cd ./minisound_ffi/
    dart run ffigen
    ```

## TODO

- [ ] Fix non-intuitiveness of pausing and stopping, then playing again looped sounds
<!-- - [ ] Stop crash when no devices found for playback or capture -->
<!-- - [ ] Extract buffer stuff to unified AV Buffer packages dart and C. -->
<!-- - [ ] Switch engine init to state machine. -->
