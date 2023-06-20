// ignore_for_file: non_constant_identifier_names, slash_for_doc_comments

part of "wasm.dart";

class Heap {
  const Heap();

  Uint8List get _heap => _GROWABLE_HEAP_U8();

  int operator [](int index) => _heap[index];
  void operator []=(int index, int other) => _heap[index] = other;

  void copy(Pointer ptr, Uint8List data) =>
      _heap.setRange(ptr.addr, ptr.addr + data.lengthInBytes, data);
}

const heap = Heap();

/********
 ** js **
 ********/

@JS("GROWABLE_HEAP_U8")
external Uint8List _GROWABLE_HEAP_U8();
