import "package:flutter/services.dart";
import "package:minisound/engine.dart";

extension EngineLoadSoundAsset on Engine {
  /// Loads a sound asset and creates a `Sound` from it.
  Future<Sound> loadSoundAsset(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return loadSound(AudioData.detectFromBuffer(data.buffer.asFloat32List()));
  }
}
