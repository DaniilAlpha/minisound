// ignore_for_file: non_constant_identifier_names

part of "wasm.dart";

class Heap {
  const Heap();

  Uint8List get _u8s => _HEAPU8.toDart;
  Uint16List get _u16s => _HEAPU16.toDart;
  Uint32List get _u32s => _HEAPU32.toDart;

  void copyUint8List(int addr, Uint8List data) => _u8s.setAll(addr, data);

  int u8(int addr) => _u8s[addr];
  void setu8(int addr, int value) => _u8s[addr] = value;

  int u16(int addr) {
    assert(addr % 2 == 0);
    return _u16s[addr ~/ 2];
  }

  void setu16(int addr, int value) {
    assert(addr % 2 == 0);
    _u16s[addr ~/ 2] = value;
  }

  int u32(int addr) {
    assert(addr % 4 == 0);
    return _u32s[addr ~/ 4];
  }

  void setu32(int addr, int value) {
    assert(addr % 4 == 0);
    _u32s[addr ~/ 4] = value;
  }
}

const heap = Heap();

// js interop

@JS("HEAPU8")
external JSUint8Array get _HEAPU8;
@JS("HEAPU16")
external JSUint16Array get _HEAPU16;
@JS("HEAPU32")
external JSUint32Array get _HEAPU32;
