import "dart:io";
import "dart:typed_data";

import "package:flutter/services.dart";
import "package:minisound/minisound.dart";

extension LoadSounds on Engine {
  /// Loads a sound asset and creates a `Sound` from it.
  Future<Sound> loadSoundAsset(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return _loadSoundFromBuffer(data.buffer.asFloat32List(), assetPath);
  }

  /// Loads a sound file and creates a `Sound` from it.
  Future<Sound> loadSoundFile(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    return _loadSoundFromBuffer(bytes.buffer.asFloat32List(), filePath);
  }

  Future<Sound> _loadSoundFromBuffer(Float32List buffer, String path) async =>
      loadSound(AudioData(
          buffer,
          AudioFormat.float32, // We pass the raw data and let miniaudio decode
          0, // Sample rate will be detected by miniaudio
          0 // Channels will be detected by miniaudio
          ));
}
