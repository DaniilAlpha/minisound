// ignore_for_file: slash_for_doc_comments

part of "wasm.dart";

abstract interface class Allocator {
  Pointer allocate<T>(int size);

  void free(Pointer ptr);
}

class Malloc implements Allocator {
  Malloc({this.maxMemorySize = 1024 * 1024 * 5});

  final int maxMemorySize;
  int _currentMemorySize = 0;
  final Map<int, int> _activeSizes = {};

  @override
  Pointer<T> allocate<T>(int size) {
    print("currentMemorySize: $_currentMemorySize");
    // Check if memory limit is exceeded
    if (_currentMemorySize > maxMemorySize) {
      _pruneOldPointers();
    }
    final addr = _malloc(size);
    if (addr == 0) {
      throw ArgumentError("Number of bytes cannot be satisfied.");
    }

    _activeSizes[addr] = size;
    _currentMemorySize += size;

    return Pointer(addr);
  }

  @override
  void free(Pointer ptr) {
    final size = _activeSizes[ptr.addr];
    if (size == null) {
      throw ArgumentError("Pointer address is not allocated.");
    }

    _activeSizes.remove(ptr.addr);
    _currentMemorySize -= size;
    if (!ptr.safe) {
      _free(ptr.addr);
    }
  }

  void _pruneOldPointers() {
    final prunedAddresses = <int>[];

    // Sort allocations by address to prune oldest first
    final sortedAddresses = _activeSizes.keys.toList()..sort();

    for (final addr in sortedAddresses) {
      final size = _activeSizes[addr]!;
      prunedAddresses.add(addr);
      _currentMemorySize -= size;

      if (_currentMemorySize <= maxMemorySize) {
        break;
      }
    }
    for (final addr in prunedAddresses) {
      _activeSizes.remove(addr);
      _free(addr);
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
