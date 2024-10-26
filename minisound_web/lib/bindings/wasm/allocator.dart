part of "wasm.dart";

abstract interface class Allocator {
  Pointer allocate<T>(int size);
  void free(Pointer ptr);
}

class Malloc implements Allocator {
  const Malloc();

  @override
  Pointer<T> allocate<T>(int size) => Pointer(_malloc(size));

  @override
  void free(Pointer ptr) => _free(ptr.addr);
}

const malloc = Malloc();

// *************
// ** JS part **
// *************

@JS()
external int _malloc(int size);
@JS()
external void _free(int ptr);
