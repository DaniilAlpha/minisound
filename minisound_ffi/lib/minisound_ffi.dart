import "dart:ffi";
import "dart:io";
import "dart:typed_data";

import "package:ffi/ffi.dart";
import "package:minisound_ffi/src/minisound_ffi_bindings.dart" as c;
import "package:minisound_platform_interface/minisound_platform_interface.dart";

part "ffi_engine.dart";
part "ffi_sound.dart";
part "ffi_recorder.dart";
part "ffi_rec.dart";
part "ffi_audio_common.dart";

// dynamic lib

const String _libName = "minisound_ffi";
final _binds = c.MinisoundFfiBindings(() {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open("$_libName.framework/$_libName");
  } else if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open("lib$_libName.so");
  } else if (Platform.isWindows) {
    return DynamicLibrary.open("$_libName.dll");
  }
  throw UnsupportedError("Unsupported platform: ${Platform.operatingSystem}");
}());

extension PointerCopy on Pointer {
  void copy(TypedData typedData) => cast<Uint8>()
      .asTypedList(typedData.lengthInBytes)
      .setAll(0, typedData.buffer.asUint8List());
}

// minisound ffi

class MinisoundFfi extends MinisoundPlatform {
  MinisoundFfi._();

  static void registerWith() => MinisoundPlatform.instance = MinisoundFfi._();

  @override
  final createEngine = FfiEngine._;
  @override
  final createRecorder = FfiRecorder._;
}
