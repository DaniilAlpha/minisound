import "package:flutter/services.dart";
import "package:minisound/player.dart";

export "package:minisound/player.dart";

extension PlayerLoadSoundAsset on Player {
  /// Loads a sound asset and creates a `LoadedSound` from it.
  Future<LoadedSound> loadSoundAsset(String assetPath) async =>
      loadSound(await rootBundle.load(assetPath));
}
