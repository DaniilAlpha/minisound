import "package:flutter_test/flutter_test.dart";
import "package:minisound/minisound.dart";
import "package:minisound_platform_interface/minisound_platform.dart";

import "minisound_mock.dart";

void main() {
  test("minisound works", () async {
    MinisoundPlatform.instance = MinisoundMock();

    final engine = Engine();
    await engine.init();

    final sound = await engine.loadSoundFile("./test/laser_shoot.wav");
    sound.volume = .5;

    await engine.start();
    sound.play();
    sound.pause();
    sound.stop();

    await engine.unloadSound(sound);
    await engine.dispose();
  });
}
