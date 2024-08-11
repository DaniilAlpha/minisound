part of "wasm.dart";

class Pointer<T> {
  Pointer(this.addr, this.size,
      {this.safe = false, this.dummy = false, this.refCount = 1}) {
    refCount = 1;
    lastAccessTime = DateTime.now().millisecondsSinceEpoch;
  }

  final int addr;
  // TODO get rid of this crap
  final int size;
  final bool safe;
  final bool dummy;
  int refCount;
  late int lastAccessTime;

  void retain() {
    refCount++;
  }

  void release() {
    refCount--;
    if (refCount == 0) {
      malloc.free(this);
    }
  }

  int get value {
    lastAccessTime = DateTime.now().millisecondsSinceEpoch;
    return heap[addr];
  }

  set value(int value) {
    lastAccessTime = DateTime.now().millisecondsSinceEpoch;
    heap[addr] = value;
  }

  Pointer elementAt(int index) => Pointer(addr + index, size, safe: safe);

  Pointer<R> cast<R>() => Pointer<R>(addr, size, safe: safe);

  @override
  bool operator ==(Object other) =>
      other is Pointer &&
      ((other.runtimeType == Pointer<T>) ||
          (other.runtimeType == Pointer<dynamic>)) &&
      other.addr == addr;

  @override
  int get hashCode => Object.hash(addr, T);
}

extension FloatPointerAsTypedList on Pointer<Float> {
  Float32List asTypedList(int length) =>
      heap._heapF32.sublist(addr ~/ 4, addr ~/ 4 + length);
}

extension Uint8PointerAsTypedList on Pointer<Uint8> {
  Uint8List asTypedList(int length) =>
      heap._heapU8.sublist(addr, addr + length);
}

extension Int32PointerAsTypedList on Pointer<Int32> {
  Int32List asTypedList(int length) =>
      heap._heapI32.sublist(addr ~/ 4, addr ~/ 4 + length);
}

final nullptr = Pointer(0, 1);
