import "dart:typed_data";

import "package:flutter_test/flutter_test.dart";
import "package:minisound/engine.dart";
import "package:minisound/engine_flutter.dart";
import "package:minisound/generator.dart";
import "package:minisound/recorder.dart";
import "package:minisound/test/minisound_mock.dart";
import "package:minisound_platform_interface/minisound_platform_interface.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("Engine Tests", () {
    late Engine engine;

    setUp(() {
      MinisoundPlatform.instance = MinisoundMock();
      engine = Engine();
    });

    test("Engine initialization", () async {
      expect(engine.isInit, false);
      await engine.init();
      expect(engine.isInit, true);
    });

    test("Engine start", () async {
      await engine.init();
      await engine.start();
      expect(null, null); // TODO!!!
    });

    test("Load sound from asset", () async {
      await engine.init();
      final sound = await engine.loadSoundAsset("assets/laser_shoot.wav");
      expect(sound, isInstanceOf<Sound>());
    });

    test("Load sound from file", () async {
      await engine.init();
      final sound = await engine.loadSoundFile("assets/laser_shoot.wav");
      expect(sound, isInstanceOf<Sound>());
    });
  });

  group("Sound Tests", () {
    late Engine engine;
    late Sound sound;

    setUp(() async {
      MinisoundPlatform.instance = MinisoundMock();
      engine = Engine();
      await engine.init();
      sound = await engine
          .loadSound(AudioData(Float32List(100), SoundFormat.f32, 44100, 1));
    });

    test("Sound play", () async {
      await engine.start();
      sound.play();
      expect((sound as SoundMock).state, SoundState.playing);
    });

    test("Sound pause", () {
      sound.play();
      sound.pause();
      expect((sound as SoundMock).state, SoundState.paused);
    });

    test("Sound stop", () {
      sound.play();
      sound.stop();
      expect((sound as SoundMock).state, SoundState.stopped);
    });

    test("Sound volume", () {
      sound.volume = 0.5;
      expect(sound.volume, 0.5);
    });

    test("Sound looped playback", () async {
      await engine.start();
      sound.playLooped(delay: const Duration(milliseconds: 500));
      expect((sound as SoundMock).state, SoundState.playing);
    });
  });

  group("Recorder Tests", () {
    late Recorder recorder;

    setUp(() {
      MinisoundPlatform.instance = MinisoundMock();
      recorder = Recorder();
    });

    test("Recorder initialization", () async {
      await recorder.initEngine();
      await recorder.initStream();
      expect(recorder.isInit, true);
    });

    test("Recorder start and stop", () async {
      await recorder.initEngine();
      await recorder.initStream();
      recorder.start();
      expect(recorder.isRecording, true);
      recorder.stop();
      expect(recorder.isRecording, false);
    });

    test("Recorder get buffer", () async {
      await recorder.initEngine();
      await recorder.initStream();
      recorder.start();
      final buffer = recorder.getBuffer(100);
      expect(buffer.length, 100);
      recorder.stop();
    });

    test("Recorder get available frames", () async {
      await recorder.initEngine();
      await recorder.initStream();
      recorder.start();
      final availableFrames = recorder.getAvailableFrames();
      expect(availableFrames, greaterThan(0));
      recorder.stop();
    });
  });

  group("Generator Tests", () {
    late Generator generator;

    setUp(() {
      MinisoundPlatform.instance = MinisoundMock();
      generator = Generator();
    });

    test("Generator initialization", () async {
      await generator.initEngine();
      await generator.init(
        format: SoundFormat.f32,
        channels: 2,
        sampleRate: 48000,
        bufferDurationSeconds: 5,
      );
      expect(generator.isInit, true);
    });

    test("Generator waveform", () async {
      await generator.initEngine();
      await generator.init(
        format: SoundFormat.f32,
        channels: 2,
        sampleRate: 48000,
        bufferDurationSeconds: 5,
      );
      generator.setWaveform(type: GeneratorWaveformType.sine);
      generator.start();
      expect(generator.getAvailableFrames(), greaterThan(0));
      final buffer = generator.getBuffer(100);
      expect(buffer.length, 100);
      generator.stop();
    });

    test("Generator noise", () async {
      await generator.initEngine();
      await generator.init(
        format: SoundFormat.f32,
        channels: 2,
        sampleRate: 48000,
        bufferDurationSeconds: 5,
      );
      generator.setNoise(type: GeneratorNoiseType.white);
      generator.start();
      expect(generator.getAvailableFrames(), greaterThan(0));
      final buffer = generator.getBuffer(100);
      expect(buffer.length, 100);
      generator.stop();
    });

    test("Generator pulse wave", () async {
      await generator.initEngine();
      await generator.init(
        format: SoundFormat.f32,
        channels: 2,
        sampleRate: 48000,
        bufferDurationSeconds: 5,
      );
      generator.setPulsewave();
      generator.start();
      expect(generator.getAvailableFrames(), greaterThan(0));
      final buffer = generator.getBuffer(100);
      expect(buffer.length, 100);
      generator.stop();
    });
  });
}
