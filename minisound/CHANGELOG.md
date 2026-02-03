# Change Log

## 3.0.1

- Fix `useDebugBuild` being mandatory in the web loader script.
- Update docs to mention web setup changes.

## 3.0.0

- Integrates GitHub actions to have at least some level of macOS/iOS testing. Fixes macOS/iOS build.
- Fixes sound absense on Android.

- Reworks underlying implementation to prevent crashes, even when used incorrectly.
- Properly distinguishes between debug and release builds, including on the web. Affects logging levels, as well as optimizations.
- Changes `miniaudio` to the submodule dependency.

- Renames `Engine` to `Player` (and import files accordingly).
- Adds `cursor` to the `Sound` objects, for getting and setting the current position.
- Adds `pitch` to the `Sound` objects.
- Adds `isLooping` and `loopDelay` instead of just `playLooped` for more granular control.

- Highly improves the `Recorder` interface. Fixes previous bugs.
- Adds support for recording MP3 and FLAC.

## 2.0.2

- Fixes strange playback bugs.

## 2.0.1

- Fixes strange bugs on specific audio formats on the web.
- Makes `Sound` class extendable from the outside.

## 2.0.0

- Rewrites recording and generation APIs.
- Changes how automatic sound unloading works.

## 1.6.0

- Minor fixes.

## 1.5.1 (broken)

- 

## 1.5.0

- Adds Recorder.
- Adds Generator.
- Adds native semi-automatic tests.
- Updates example to use new APIs.

## 1.4.1

- Loop delay is clamped positive from now on.

## 1.4.0

- Adds an ability to add delay between loops.
- Changes behavoiur of playing sound which is already playing: stops and starts again instead of doing nothing.

## 1.3.8

- Dependency updates.

## 1.3.7

- Adds a mandatory dependency on `flutter_web_plugins`.

## 1.3.6

- Updates dependencies `minisound_platform_intergace`, `minisound_ffi`, `minisound_web`.
- Fixes `README.md`.

## 1.3.4

- Updates dependencies `minisound_platform_intergace`, `minisound_ffi`, `minisound_web`.
- Fixes `README.md`.

## 1.3.2

- Updates dependencies `minisound_platform_intergace`, `minisound_ffi`, `minisound_web`.

## 1.3.1

- Fixes `README.md`.

## 1.3.0

- Slightly changes error messages.
- Adds looping feature.
- Make volume to be able to exceed `1` (needs proper testing on different platforms).

## 1.2.0

- Changes platform error handling, which may help to avoid crashes.

## 1.1.5

- Minor fixes.

## 1.1.4

- Fixes macOS and iOS compilation problem.

## 1.1.0

- Slightly changes sound loading.
- Adds finalizers which dispose `Engine` automatically.

## 1.0.3

- Fixes `README.md`.

## 1.0.0

- Initial release with basic functionality.
