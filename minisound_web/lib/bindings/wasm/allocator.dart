// ignore_for_file: slash_for_doc_comments

part of "wasm.dart";

abstract interface class Allocator {
  Pointer allocate<T>(int size);

  void free(Pointer ptr);
}

class Malloc implements Allocator {
  const Malloc();

  @override
  Pointer<T> allocate<T>(int size) {
    final addr = _malloc(size);
    if (addr == 0) throw ArgumentError("Number of bytes cannot be satisfied.");
    return Pointer(addr);
  }

  @override
  void free(Pointer ptr) => _free(ptr.addr);
}

const malloc = Malloc();

/********
 ** js **
 ********/

@JS()
external int _malloc(int size);
@JS()
external void _free(int ptr);
