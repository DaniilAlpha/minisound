// ignore_for_file: non_constant_identifier_names

part of "wasm.dart";

class Heap {
  const Heap();

  Uint8List get _heapU8 => _GROWABLE_HEAP_U8().toDart;
  // Int16List get _heapI16 => _GROWABLE_HEAP_I16();
  // Int32List get _heapI32 => _GROWABLE_HEAP_I32();
  // Float32List get _heapF32 => _GROWABLE_HEAP_F32();

  // void copyFloat32List(int addr, Float32List data) =>
  //     _heapF32.setAll(addr ~/ 4, data);
  // void copyInt32List(int addr, Int32List data) =>
  //     _heapI32.setAll(addr ~/ 4, data);
  // void copyInt16List(int addr, Int16List data) =>
  //     _heapI16.setAll(addr ~/ 2, data);
  void copyUint8List(int addr, Uint8List data) => _heapU8.setAll(addr, data);
}

const heap = Heap();

// js interop
@JS("GROWABLE_HEAP_U8")
external JSUint8Array _GROWABLE_HEAP_U8();
// @JS("GROWABLE_HEAP_I16")
// external JSUint16Array _GROWABLE_HEAP_I16();
// @JS("GROWABLE_HEAP_I32")
// external JSInt32Array _GROWABLE_HEAP_I32();
//
// @JS("GROWABLE_HEAP_F32")
// external JSFloat32Array _GROWABLE_HEAP_F32();
