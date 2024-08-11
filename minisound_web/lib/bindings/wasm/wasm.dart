@JS()
library wasm;

import "dart:async";
import "dart:typed_data";

import "package:js/js.dart";

// TODO!!! should not reference outside types
import "package:minisound_platform_interface/minisound_platform_interface.dart";

part "heap.dart";
part "allocator.dart";
part "opaque.dart";
part "pointer.dart";
part "primitive.dart";
