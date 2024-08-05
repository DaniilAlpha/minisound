part of "wasm.dart";

final class Float extends Opaque {}

final class Int32 extends Opaque {}

final class Uint8 extends Opaque {}

class Pointer<T> {
  const Pointer(this.addr);

  final int addr;

  int get value => heap[addr];
  set value(int value) => heap[addr] = value;

  Pointer elementAt(int index) => Pointer(addr + index);

  Pointer<R> cast<R>() => Pointer<R>(addr);

  @override
  bool operator ==(Object other) =>
      other is Pointer &&
      ((other.runtimeType == Pointer<T>) ||
          (other.runtimeType == Pointer<dynamic>)) &&
      other.addr == addr;

  @override
  int get hashCode => Object.hash(addr, T);

  List<double> asTypedList(int length) {
    if (T == Float || T == double) {
      return heap._heapF32.sublist(addr ~/ 4, (addr ~/ 4) + length);
    } else if (T == Int32 || T == int) {
      return heap._heapI32
          .sublist(addr ~/ 4, (addr ~/ 4) + length)
          .map((e) => e.toDouble())
          .toList();
    } else if (T == Uint8 || T == int) {
      return heap._heapU8
          .sublist(addr, addr + length)
          .map((e) => e.toDouble())
          .toList();
    } else {
      throw UnsupportedError('Unsupported type for asTypedList: $T');
    }
  }
}

const nullptr = Pointer(0);
