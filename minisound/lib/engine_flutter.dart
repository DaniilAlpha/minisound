import "package:flutter/services.dart";
import "package:minisound/engine.dart";

export "package:minisound/engine.dart";

extension EngineLoadSoundAsset on Engine {
  /// Loads a sound asset and creates a `LoadedSound` from it.
  Future<LoadedSound> loadSoundAsset(String assetPath) async =>
      loadSound(await rootBundle.load(assetPath));
}
