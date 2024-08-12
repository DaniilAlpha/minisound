import "dart:ffi";
import "dart:io";
import "dart:typed_data";

import "package:ffi/ffi.dart";
import "package:minisound_ffi/minisound_ffi_bindings.dart" as c;
import "package:minisound_platform_interface/minisound_platform_interface.dart";

part "ffi_engine.dart";
part "ffi_sound.dart";
part "ffi_generator.dart";
part "ffi_recorder.dart";

// dynamic lib

const String _libName = "minisound_ffi";
final _bindings = c.MinisoundFfiBindings(() {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open("$_libName.framework/$_libName");
  } else if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open("lib$_libName.so");
  } else if (Platform.isWindows) {
    return DynamicLibrary.open("$_libName.dll");
  }
  throw UnsupportedError("Unsupported platform: ${Platform.operatingSystem}");
}());

extension PointerFloatCopy on Pointer<Float> {
  void copy(Float32List data) => asTypedList(data.length).setAll(0, data);
}

extension PointerInt32Copy on Pointer<Int32> {
  void copy(Int32List data) => asTypedList(data.length).setAll(0, data);
}

extension PointerInt16Copy on Pointer<Int16> {
  void copy(Int16List data) => asTypedList(data.length).setAll(0, data);
}

extension PointerCopy on Pointer {
  void copy(TypedData typedData) {
    final data = typedData.buffer.asUint8List();
    cast<Uint8>().asTypedList(data.length).setAll(0, data);
  }
}

// minisound ffi

class MinisoundFfi extends MinisoundPlatform {
  MinisoundFfi._();

  static void registerWith() => MinisoundPlatform.instance = MinisoundFfi._();

  @override
  PlatformEngine createEngine() {
    final self = _bindings.engine_alloc();
    if (self == nullptr) throw MinisoundPlatformOutOfMemoryException();
    return FfiEngine._(self);
  }

  @override
  PlatformRecorder createRecorder() {
    final self = _bindings.recorder_create();
    if (self == nullptr) throw MinisoundPlatformOutOfMemoryException();
    return FfiRecorder._(self);
  }

  @override
  PlatformGenerator createGenerator() {
    final self = _bindings.generator_create();
    if (self == nullptr) throw MinisoundPlatformOutOfMemoryException();
    return FfiGenerator._(self);
  }
}
