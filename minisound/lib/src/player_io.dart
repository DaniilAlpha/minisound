import "dart:io";

import "package:minisound/player.dart";

extension PlayerLoadSoundFile on Player {
  /// Loads a file and creates a `LoadedSound` from it.
  Future<LoadedSound> loadSoundFile(String filePath) async =>
      loadSound(await File(filePath).readAsBytes());
}
