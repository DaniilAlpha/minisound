import "dart:typed_data";
import "package:minisound_platform_interface/minisound_platform_interface.dart";
import "package:minisound_web/bindings/minisound_web_bindings.dart" as c;
import "package:minisound_web/bindings/wasm/wasm.dart";

part "web_engine.dart";
part "web_sound.dart";
part "web_recorder.dart";

class MinisoundWeb extends MinisoundPlatform {
  MinisoundWeb._();

  static void registerWith(dynamic _) =>
      MinisoundPlatform.instance = MinisoundWeb._();

  @override
  PlatformEngine createEngine() {
    final self = c.engine_alloc();
    if (self == nullptr) throw MinisoundPlatformOutOfMemoryException();
    return WebEngine._(self);
  }

  @override
  PlatformRecorder createRecorder() {
    final self = c.recorder_create();
    if (self == nullptr) throw MinisoundPlatformOutOfMemoryException();
    return WebRecorder._(self);
  }
}
