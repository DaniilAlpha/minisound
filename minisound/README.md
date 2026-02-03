# minisound

A high-level real-time audio library for playback, generation and recording, focusing on ease of use and performance. Suitable for realtime audio applications and games, where low latency is essential. Based on [miniaudio](https://miniaud.io).

## Features

- Aim to support all platforms Dart itself works on, including the web and wasm.

- Configurable low latency, perfect for realtime audio applications.

- Full support (playing and recording) of WAV, MP3 and FLAC formats.

- Leverages native audio APIs under the hood.

- Uniform object oriented APIs for audio playback, generation and recording, focusing on ease of use.

- Annotated public API and comprehensive examples.

- Automatic resource management (uses Dart's `Finalizer`s internally), so you don't need to `dispose()` anything.

- Advanced looping controls, with an ability to set a precise delay.

- Configurable recording parameters like sample format, channel count and sample rate.

- An ability to record multiple recordings at once, including in different formats/encodings.


## Platform support

|Platform |Tested                      |Supported* (best efforts)|
|---------|----------------------------|-------------------------|
|Android  |SDK 31                      |Any                      |
|Windows  |Latest (GH Action)          |Any                      |
|GNU/Linux|Latest Arch Linux           |Any                      |
|iOS      |Latest Simulator (GH Action)|Any                      |
|macOS    |Latest (GH Action)          |Any                      |
|Web      |Latest Chromium             |[Browsers with an `AudioWorklet` support](https://developer.mozilla.org/en-US/docs/Web/API/AudioWorklet#browser_compatibility)|
|Wasm     |Latest Chromium             |Any                      |

> \* 'Any' reffering to platforms supported by the Dart compiler itself. E.g. Windows 7 support is dropped in Dart, so it technically cannot be supported on it.


## Migration

There was some pretty major API changes in the 3.0.0, see [migration guide](#migration-guide) down below.


## Getting started 

For some platforms, you have to request permission from the user at runtime. This can be done easily using the [`permission_handler` package](https://pub.dev/packages/permission_handler) (you can look at the [example app](/minisound/example/lib/main.dart) to see some code).


### GNU/Linux

The library works best with the PulseAudio, but can also work through ALSA to broaden the support. Development libraries should be installed accordingly.


### macOS and iOS 

Testing for this platforms is a bit problematic, so this should be considered experimental. Feel free to report any issues to the GitHub repo.


### Web and Wasm

While the main script is quite large, there is a loader script provided. Include it in the `<head>` of `/web/index.html` like this

```html
<script src="assets/packages/minisound_web/src/build/minisound_web.loader.js"></script>
```

> [!note]
> It is highly recommended NOT to make the script `defer`, as loading may not work properly. This won't save you much either, as it is very small (around 20 lines).

And at the bottom, inside the `<body>`'s `<script>` do the following (comments in caps indicate needed changes)

```js
                                // ADD 'async'
window.addEventListener('load', async function (ev) {
    {{flutter_js}}
    {{flutter_build_config}}

    // ADD THIS BLOCK TO LOAD THE LIBRARY 
    await _minisound.loader.load({
        // this argument is optional, but it allows to see some helpful logs in the debug build
        useDebugBuild: _flutter.buildConfig.builds[0].compileTarget == "dartdevc"
    });

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
});
```

`minisound` depends on the `SharedArrayBuffer` feature, so you should [enable cross-origin isolation on your site](https://web.dev/cross-origin-isolation-guide/).

To still be able to run the app locally, you can use the following command:
```bash
flutter run -d chrome --web-browser-flag '--enable-features=SharedArrayBuffer'
```


## Usage

To use this plugin, add `minisound` as a [dependency in your pubspec.yaml file](https://flutter.dev/platform-plugins/).

Apart from these simple examples you may want to look at the [example app](/minisound/example/lib/main.dart).

### Playback

```dart
// if you are using flutter, use
import "package:minisound/player_flutter.dart" as minisound;
// and with plain dart use
import "package:minisound/player.dart" as minisound;
// the difference is that flutter version allows you to load from assets, which is a concept specific to flutter

void main() async {
  final player = minisound.Player();

  // player initialization
  {
    // you can pass `periodMs` as an argument, to change the latency (does not affect web). can cause crackles if the value is too low
    await player.init(); 

    // for the web: this should be executed after the first user interaction due to browsers' autoplay policy
    // no one stops you to call this on every sound play as well, but i'd still prefer not to
    await player.start(); 
  }


  // there is a base `Sound` interface that is implemented by `LoadedSound` (which reads data from a defined length memory location) 
  final LoadedSound sound;

  // sound loading
  {
    // there are also `loadSoundFile` and `loadSound` methods to load sounds from file (by filename) and `TypedData` respectfully
    final sound = await player.loadSoundAsset("asset/path.ext");

    // you can get and set sound's volume (1 by default)
    sound.volume *= 0.5;
    // pitch can also be changed (affects speed as well)
    sound.pitch += 0.1;
  }

  // playing, pausing and stopping
  {
    sound.play();

    await Future.delayed(sound.duration * 0.5); // waiting while the first half plays

    sound.pause(); 
    // when sound is paused, `resume` will continue the sound and `play` will start from the beginning
    sound.resume(); 

    sound.stop(); 

    // `cursor` can be used to get and set the current position; when sound is playing, it will update on every read
    sound.cursor = sound.duration * 0.5; 
  }
  
  // looping
  {
    sound.isLooped = true;
    sound.loopDelay = const Duration(seconds: 1);

    sound.play(); // now it will be looped with one second between loops; cursor stays at the end while the sound waits

    // btw, sound duration does not account loop delay
    await Future.delayed((sound.duration + sound.loopDelay) * 5); // waiting for 5 full loops (with all the delays)

    sound.stop();
  }

  // player and sounds will be automatically disposed on GC run
}
```

### Generation 

```dart
// you may want to read previous example first for more detailed explanation of the basics

import "package:minisound/player_flutter.dart" as minisound;

void main() async {
  final player = minisound.Player();
  await player.init(); 
  await player.start(); 

  // `Sound` is also implemented by a `GeneratedSound` which is extended by `WaveformSound` and `NoiseSound`
  // there are four different types of waveforms: sine, square, triangle and sawtooth; the type can be changed at any time
  WaveformSound wave = player.genWaveform(WaveformType.sine);
  // and three different types of noise: white, pink and brownian; CANNOT be changed later
  NoiseSound noise = player.genNoise(NoiseType.white);

  wave.play();
  noise.play();
  // generated sounds have no duration, which makes sense if you think about it; for this reason they don't provide looping controls
  await Future.delayed(const Duration(seconds: 1))
  wave.stop();
  noise.stop();

  // player and sounds will be automatically disposed on GC run
}
```

### Recording

```dart
import "package:minisound/recorder.dart" as minisound;

void main() async {
    // the constructor takes a max number of concurrent recordings as an argument; most of the times the default value will be sufficient; paused recordings are not counted here
  final recorder = minisound.Recorder();
  // `periodMs` can be passed here as well
  await recorder.init();
  await recorder.start();

  // recording parameters like `encoding`, `sampleFormat`, `channelCount` and `sampleRate` control quality and the resulting size
  // there's also `saveRecFile` to automatically save the recording into the file when it's ended
  BufRec rec = await recorder.saveRecBuf();

  await Future.delayed(const Duration(seconds: 1));
  rec.pause();
  await Future.delayed(const Duration(seconds: 1));
  rec.resume();
  await Future.delayed(const Duration(seconds: 1));

  final result = await rec.end(); // in this case, `end` returns the resulting buffer

  // this result can be fed directly into the `loadSound` method of the player
  minisound.Player().loadSound(result);

  // recorder and recs will be automatically disposed on GC run
}
```


## Migration guide

### 2.x.x ➔ 3.0.0

- **[web]** Minisound loader script changed its location and got updated a bit. You'll need to redo steps from the [web and wasm](#web-and-wasm) section.

- Recording API got heavily changed. See the [usage](#usage) for new usage.

- The `Engine` class was renamed into `Player`. File names changed to `player.dart` and `player_flutter.dart` as well.

- Replace `sound.playLooped(loopDelay: loopDelay)` with `sound.isLooped = true` and `sound.loopDelay = loopDelay`. Fields can now be set independently.

- Manual sound management got completely removed.

- Method `engine.genPulse` is deprecated, as it made the API inconsistent and is not very useful either. Some time in the future i might add `dutyCycle` to `WaveformSound`s and remove pulsewaves completely.


## Developing and contributing

To run the project locally, you'll need to clone the repo. It defaults to the latest dev version, where all the development work should be done.
```bash
git clone https://github.com/DaniilAlpha/minisound.git --recurse-submodules
```

You can use `make` to run some common commands sets:

- `projs-get` - get dependencies for all the packages
- `projs-clean` - clean all the packages
- `proj-main-example-run` - run the example app 
- `proj-ffi-gen-bindings` - generate Dart FFI bindings
- `proj-ffi-native-test-run` - semi-automatic test to test the underlying C library (not guaranteed to work with compilers other than GCC)
- `proj-web-lib-build-debug` and `proj-web-lib-build-release` - build debug and release versions respectfully of the web library 
