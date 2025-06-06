# Changelog

## 2.0.5

Add gradle namespace to fix Android build.

## 2.0.4

An attempt to fix iOS build.

## 2.0.3

Fix compiler flags on windows.

## 2.0.2

Fix more strange playback bugs.

## 2.0.1

Fix strange bugs on specific audio formats on the web.

## 2.0.0

Recording and generation API got rewritten.
Changes how automatic sound unloading works.

## 1.6.0

Fixed.

## 1.5.1 (broken)

Temporary patch.
Appears to be broken.

## 1.5.0

CMake refactor with output path for Emscripten.
Adds Recorder.
Adds Generator.
Adds Circular Buffer to native code.
Uses Float32Array instead of Uint8Array for audio data.

## 1.4.0

Added an ability to add delay between loops.
Changed behavoiur when playing sound while already playing: stops and starts again instead of doing nothing.

## 1.3.11

Fix annoying error.

## 1.3.10

Disabled logging by default as not needed anymore.

## 1.3.9

Fixed iOS and MacOS compilation error.

## 1.3.8

-

## 1.3.7

Fixed bug with include path of `milo.h`.

## 1.3.6

-

## 1.3.5

Unnecessary `flutter` dependency removed.

## 1.3.4

Changed dependency for the newest `minisound_platform_intergace`.

## 1.3.0

Slightly changed error messages.
Added looping feature.
Volume now can exceed `1` (needs proper testing on different platforms).

## 1.2.0

Changed error handling. It helps to avoid some crashes during runtime.

## 1.1.4

A problem with iOS and macOS compilation fixed.

## 1.1.0

Sound loading was slightly changed.

## 1.0.0

Initial release.
