import "dart:typed_data";
import "package:minisound_platform_interface/minisound_platform_interface.dart";
import "package:minisound_web/src/minisound_web_bindings.dart" as c;
import "package:minisound_web/src/minisound_web_bindings.dart"
    as _binds; // ignore: no_leading_underscores_for_library_prefixes
import "package:minisound_web/src/wasm/wasm.dart";

part "web_engine.dart";
part "web_audio_common.dart";
part "web_sound.dart";
part "web_recorder.dart";
part "web_rec.dart";

class MinisoundWeb extends MinisoundPlatform {
  MinisoundWeb._();

  static void registerWith(dynamic _) =>
      MinisoundPlatform.instance = MinisoundWeb._();

  @override
  final createEngine = WebEngine._;
  @override
  final createRecorder = WebRecorder._;
}
