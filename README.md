# minisound

A high-level real-time audio playback library based on [miniaudio](https://miniaud.io). The library offers basic functionality and quite low latency. Not really suitable for big sounds right now. Supports MP3, WAV and FLAC formats.

## Platform support

| Platform | Tested                              | Supposed to work                        | Unsupported                                |
| -------- | ----------------------------------- | --------------------------------------- | ------------------------------------------ |
| Android  | SDK 31, 19                          | SDK 16+                                 | SDK 15-                                    |
| iOS      | None                                | Unknown                                 | Unknown                                    |
| Windows  | 11, 7 (x64)                         | Vista+                                  | XP-                                        |
| macOS    | None                                | Unknown                                 | Unknown                                    |
| Linux    | Debian 11 (WSL)                     | Any                                     | None                                       |
| Web      | Chrome 93+, Firefox 79+, Safari 16+ | Browsers with an `AudioWorklet` support | Browsers without an `AudioWorklet` support |

## Getting started on the web

While the main script is quite large, there are a loader script provided. Include it in the `web/index.html` file like this

```html
  <script src="assets/packages/minisound_web/js/minisound_web.loader.js"></script>
```

> It is highly recommended NOT to make the script `defer`, as loading may not work properly. Also, it is very small (only 18 lines).

And at the bottom, at the body's `<script>` do like this

```js
window.addEventListener(
  'load',
  // ADD 'async'
  async function (ev) {
      // ADD THIS LINE AT THE TOP
      await _minisound.loader.load();

      // LEAVE THE REST IN PLACE
      // Download main.dart.js
      _flutter.loader.loadEntrypoint({
        serviceWorker: {
          serviceWorkerVersion: serviceWorkerVersion
        },
        onEntrypointLoaded: function (engineInitializer) {
          engineInitializer.initializeEngine().then(function (appRunner) {
            appRunner.runApp();
          });
        }
      });
    }
  );
``` 

`Minisound` uses `SharedArrayBuffer` feature, so you should [enable cross-origin isolation on your site](https://web.dev/cross-origin-isolation-guide/).

## Usage

To use this plugin, add `minisound` as a [dependency in your pubspec.yaml file](https://flutter.dev/platform-plugins/).

```dart
import "package:minisound/minisound.dart" as minisound;

void main() {
  final engine = minisound.Engine();

  // this method takes an update period in milliseconds as an argument, which
  // determines the length of the latency (does not currently affect the web)
  await engine.init(); 

  // there is also a 'loadSound' method to load a sound from the Uint8List
  final sound = await engine.loadSoundAsset("asset/path.mp3");
  sound.volume = 0.5;

  // this may cause a MinisoundPlatformException to be thrown on the web
  // before any user interaction due to the autoplay policy
  await engine.start(); 

  sound.play();

  await Future.delayed(sound.duration*.5);

  sound.pause(); // this method saves sound position
  sound.stop(); // but this does not

  // you should unload any loaded sound before disposing an engine
  await engine.unloadSound(sound);
  await engine.dispose();
}
```
