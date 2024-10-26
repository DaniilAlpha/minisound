# Changelog

## 2.0.0

Recording and generation API got rewritten.
Changes how automatic sound unloading works.

## 1.6.0 

Fixed.

## 1.5.1 (broken)

Temporary patch.
Appeared to be broken.

## 1.5.0

Uses Float32Array instead of Uint8Array for audio data.
Adds Recorder.
Adds Generator.
Uses built emscripten instead of cached.

## 1.4.1

Got rid of unnecessary pthreads in emscripten build, should decrease library size and possiby increase performance.

## 1.4.0

Added an ability to add delay between loops.
Changed behavoiur when playing sound while already playing: stops and starts again instead of doing nothing.

## 1.3.8

Changed dependency for the older `js` due to compatibility issues.

## 1.3.7

-

## 1.3.6

Unnecessary `flutter` dependency removed.

## 1.3.5

Changed dependency for the newest `js`.

## 1.3.4

Changed dependency for the newest `minisound_platform_intergace`.

## 1.3.3

Changed dependency newer `minisound_platform_intergace`.

## 1.3.0

Slightly changed error messages.
Added looping feature.
Volume now can exceed `1` (needs proper testing on different platforms).

## 1.2.0

Changed error handling. It helps to avoid some crashes during runtime.

## 1.1.0

Sound loading was slightly changed.

## 1.0.0

Initial release.
