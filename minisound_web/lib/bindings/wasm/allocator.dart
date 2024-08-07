// ignore_for_file: slash_for_doc_comments

part of "wasm.dart";

abstract interface class Allocator {
  Pointer allocate<T>(int size);

  void free(Pointer ptr);
}

class Malloc implements Allocator {
  Malloc();

  @override
  Pointer<T> allocate<T>(int size) {
    final addr = _malloc(size);
    if (addr == 0) {
      throw ArgumentError("Number of bytes cannot be satisfied.");
    }

    return Pointer(addr, size);
  }

  @override
  void free(Pointer ptr) {
    if (!ptr.safe) {
      _free(ptr.addr);
    }
  }
}

Malloc malloc = Malloc();

/********
 ** js **
 ********/

@JS()
external int _malloc(int size);
@JS()
external void _free(int ptr);
