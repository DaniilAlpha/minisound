part of "wasm.dart";

class Pointer<T> {
  const Pointer(this.addr);

  final int addr;

  // int get value => heap[addr];
  //
  // set value(int value) => heap[addr] = value;

  Pointer<R> cast<R>() => Pointer<R>(addr);

  Pointer<T> operator +(int offset) => Pointer<T>(addr + offset);

  @override
  bool operator ==(Object other) =>
      other is Pointer &&
      ((other.runtimeType == Pointer<T>) ||
          (other.runtimeType == Pointer<dynamic>)) &&
      other.addr == addr;

  @override
  int get hashCode => Object.hash(addr, T);
}

extension PointerFloatLists on Pointer<Float> {
  Float32List asTypedList(int length) =>
      heap._heapF32.sublist(addr ~/ 4, addr ~/ 4 + length);

  void copy(Float32List data) => heap.copyFloat32List(addr, data);
}

extension PointerInt32Lists on Pointer<Int32> {
  Int32List asTypedList(int length) =>
      heap._heapI32.sublist(addr ~/ 4, addr ~/ 4 + length);

  void copy(Int32List data) => heap.copyInt32List(addr, data);
}

extension PointerInt16Lists on Pointer<Int16> {
  Int16List asTypedList(int length) =>
      heap._heapI16.sublist(addr ~/ 2, addr ~/ 2 + length);

  void copy(Int16List data) => heap.copyInt16List(addr, data);
}

extension PointerUint8AsTypedList on Pointer<Uint8> {
  Uint8List asTypedList(int length) =>
      heap._heapU8.sublist(addr, addr + length);
}

extension PointerCopy on Pointer {
  void copy(TypedData data) =>
      heap.copyUint8List(addr, data.buffer.asUint8List());
}

const nullptr = Pointer(0);
