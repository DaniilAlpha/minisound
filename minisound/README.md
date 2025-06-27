# minisound

A high-level real-time audio playback library based on [miniaudio](https://miniaud.io). The library offers basic functionality for realtime audio applications and quite low latency. Supports MP3, WAV and FLAC formats.


## Platform support

|Platform |Tested     |Supposed to work|Unsupported|
|-------- |-----------|----------------|-----------|
|Android  |SDK 31, 19 |Any*            |None*      |
|Windows  |11,        |Any*            |None*      |
|GNU/Linux|Fedora 42, Mint 22|Any*     |None*      |
|iOS      |None       |Unknown         |Unknown    |
|macOS    |None       |Unknown         |Unknown    |
|Web      |Chrome(ium) 93+, Firefox 79+, Safari 16+|Browsers with an `AudioWorklet` support|Browsers without an `AudioWorklet` support|
|Wasm     |Chrome(ium) 137+ |Any*      |None*      |

> \* This refers to platforms, for which apps can be actually compiled. E.g. Windows 7 support is dropped by Dart itself, so it is technically cannot be supported.


## Migration

There was some pretty major changes in 2.0.0 version, see the [migration guide](#migration-guide) down below.


## Getting started 

### Web / Wasm

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


### Playback

```dart
// if you are using flutter, use
import "package:minisound/engine_flutter.dart" as minisound;
// and with plain dart use
import "package:minisound/engine.dart" as minisound;
// the difference is that flutter version allows you to load from assets, which is a concept specific to flutter

void main() async {
  final engine = minisound.Engine();

  // engine initialization
  {
    // you can pass `periodMs` as an argument, to change determines the latency (does not affect web). can cause crackles if too low
    await engine.init(); 

    // for web: this should be executed after the first user interaction due to browsers' autoplay policy
    await engine.start(); 
  }


  // there is a base `Sound` interface that is implemented by `LoadedSound` (which reads data from a defined length memory location) 
  final LoadedSound sound;

  // sound loading
  {
    // there are also `loadSoundFile` and `loadSound` methods to load sounds from file (by filename) and `TypedData` respectfully
    final sound = await engine.loadSoundAsset("asset/path.ext");

    // you can get and set sound's volume (1 by default)
    sound.volume *= 0.5;
  }


  // playing, pausing and stopping
  {
    sound.play();

    await Future.delayed(sound.duration * .5); // waiting while the first half plays

    sound.pause(); 
    // when sound is paused, `resume` will continue the sound and `play` will start from the beginning
    sound.resume(); 

    sound.stop(); 
  }

  
  // looping
  {
    final loopDelay = const Duration(seconds: 1);

    sound.playLooped(delay: loopDelay); // sound will be looped with one second period

    // btw, sound duration does not account loop delay
    await Future.delayed((sound.duration + loopDelay) * 5); // waiting for sound to loop 5 times (with all the delays)

    sound.stop();
  }

  // engine and sounds will be automatically disposed when gets garbage-collected
}
```


### Generation 

```dart
// you may want to read previous example first for more detailed explanation

import "package:minisound/engine_flutter.dart" as minisound;

void main() async {
  final engine = minisound.Engine();
  await engine.init(); 
  await engine.start(); 

  // `Sound` is also implemented by a `GeneratedSound` which is extended by `WaveformSound`, `NoiseSound` and `PulseSound` 

  // there are four types of a waveform: sine, square, triangle and sawtooth; the type can be changed later
  final WaveformSound wave = engine.genWaveform(WaveformType.sine);
  // and three types of a noise: white, pink and brownian; CANNOT be changed later
  final NoiseSound noise = engine.genNoise(NoiseType.white);
  // pulsewave is basically a square wave with a different ratio between high and low levels (which is represented by the `dutyCycle`)
  final PulseSound pulse = engine.genPulse(dutyCycle: 0.25);

  wave.play();
  noise.play();
  pulse.play();
  // generated sounds have no duration, which makes sense if you think about it; for this reason they cannot be looped
  await Future.delayed(const Duration(seconds: 1))
  wave.stop();
  noise.stop();
  pulse.stop();
}
```


### Recording

```dart
import "package:minisound/recorder.dart" as minisound;

void main() async {
  // recorder records into memory using the wav format 
  final recorder = minisound.Recorder();

  // recording format characteristics can be changed via this function params
  recorder.init();

  // just starts the engine
  await recorder.start();

  await Future.delayed(const Duration(seconds: 1));

  // returns what've been recorded
  final recording = await recorder.stop();

  // all data is provided via buffer; sound can be used from it via `engine.loadSound(recording.buffer)`
  print(recording.buffer);

  // recordings will be automatically disposed when gets garbage-collected
}
```


## Migration guide

### 1.6.0 -> 2.0.0

- Recording and generation APIs got heavily changed. See examples for new usage.

- Sound autounloading logic got changed, now they depend on the sound object itself, rather than the engine.
```dart
  // remove
  // sound.unload();
```
As a result, when `Sound` objects get garbage collected (which may be immediately after or not at the moment they go out of scope), they stop and unload. If you want to prevent this, you are probably doing something wrong, as this means you are creating an indefenetely played sound with no way to access it. Though this behaviour can still be disabled via the `doAddToFinalizer` parameter to sound loading and generation methods of the `Engine` class. However, it disables any finalization, so you'll need to manage `Sound`s completely yourself. If you believe your usecase is valid, create a github issue and provide the code. Maybe it will change my mind.


### 1.4.0 -> 1.6.0

- The main file (`minisound.dart`) became `engine_flutter.dart`.
```dart
// import "package:minisound/minisound.dart";
// becomes two files
import "package:minisound/engine_flutter.dart";
import "package:minisound/engine.dart";
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

4. For the development work, it's useful to run `ffigen` from the `minisound_ffi` directory:

    ```bash
    cd ./minisound_ffi/
    dart run ffigen
    ```
