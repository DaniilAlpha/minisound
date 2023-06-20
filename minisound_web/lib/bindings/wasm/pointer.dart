part of "wasm.dart";

class Pointer<T> {
  const Pointer(this.addr);

  final int addr;

  int get value => heap[addr];
  set value(int value) => heap[addr] = value;

  Pointer elementAt(int index) => Pointer(addr + index);

  @override
  bool operator ==(Object other) =>
      other is Pointer &&
      ((other.runtimeType == Pointer<T>) ||
          (other.runtimeType == Pointer<dynamic>)) &&
      other.addr == addr;

  @override
  int get hashCode => Object.hash(addr, T);
}

const nullptr = Pointer(0);
