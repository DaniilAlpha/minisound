part of "wasm.dart";

const nullptr = Pointer(0);

final class Pointer<T> extends Uint32 {
  const Pointer(this.addr);

  final int addr;

  Pointer<R> cast<R>() => Pointer(addr);

  Pointer<T> operator +(int offset) => Pointer(addr + offset);

  @override
  bool operator ==(Object other) =>
      other is Pointer &&
      ((other.runtimeType == Pointer<T>) ||
          (other.runtimeType == Pointer<dynamic>)) &&
      other.addr == addr;
  @override
  int get hashCode => Object.hash(addr, T);

  void copy(TypedData data) =>
      heap.copyUint8List(addr, data.buffer.asUint8List());
}

extension PointerUint8AsTypedList on Pointer<Uint8> {
  Uint8List asTypedList(int length) => heap._u8s.sublist(addr, addr + length);
}

extension Uint8PointerValue on Pointer<Uint8> {
  int get value => heap.u8(addr);
  set value(int value) => heap.setu8(addr, value);
}

extension Uint32PointerValue on Pointer<Uint32> {
  int get value => heap.u32(addr);
  set value(int value) => heap.setu32(addr, value);
}

extension PointerPointerValue<T> on Pointer<Pointer<T>> {
  Pointer<T> get value => Pointer(heap.u32(addr));
  set value(Pointer<T> value) => heap.setu32(addr, value.addr);
}
