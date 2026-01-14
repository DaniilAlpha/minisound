// ignore_for_file: non_constant_identifier_names

part of "wasm.dart";

class Heap {
  const Heap();

  Uint8List get _heapU8 => _GROWABLE_HEAP_U8().toDart;
  Uint16List get _heapU16 => _GROWABLE_HEAP_U16().toDart;
  Uint32List get _heapU32 => _GROWABLE_HEAP_U32().toDart;
  // Float32List get _heapF32 => _GROWABLE_HEAP_F32();

  // void copyFloat32List(int addr, Float32List data) =>
  //     _heapF32.setAll(addr ~/ 4, data);
  // void copyInt32List(int addr, Int32List data) =>
  //     _heapI32.setAll(addr ~/ 4, data);
  // void copyInt16List(int addr, Int16List data) =>
  //     _heapI16.setAll(addr ~/ 2, data);
  void copyUint8List(int addr, Uint8List data) => _heapU8.setAll(addr, data);

  int getU8(int addr) => _heapU8[addr];
  int getU16(int addr) => _heapU16[addr];
  int getU32(int addr) => _heapU32[addr];
}

const heap = Heap();

// js interop
@JS("GROWABLE_HEAP_U8")
external JSUint8Array _GROWABLE_HEAP_U8();
@JS("GROWABLE_HEAP_U16")
external JSUint16Array _GROWABLE_HEAP_U16();
@JS("GROWABLE_HEAP_U32")
external JSUint32Array _GROWABLE_HEAP_U32();
//
// @JS("GROWABLE_HEAP_F32")
// external JSFloat32Array _GROWABLE_HEAP_F32();
