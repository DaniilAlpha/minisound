// ignore_for_file: omit_local_variable_types

part of "wasm.dart";

abstract interface class Allocator {
  Pointer allocate<T>(int size);
  void free(Pointer ptr);
}

class Malloc implements Allocator {
  Malloc() {
    _startCleanupTimer();
  }

  final List<Pointer> _allocatedPointers = [];

  @override
  Pointer<T> allocate<T>(int size) {
    final ptr = _memoryPool.allocate(size);
    _allocatedPointers.add(ptr);
    return Pointer(ptr.addr, size);
  }

  @override
  void free(Pointer ptr) {
    if (!ptr.safe && ptr.refCount == 0) {
      _memoryPool.deallocate(ptr);
      _allocatedPointers.remove(ptr);
    }
  }

  void _startCleanupTimer() {
    Timer.periodic(const Duration(seconds: 10), (timer) {
      _cleanupPointers();
    });
  }

  void _cleanupPointers() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _allocatedPointers.removeWhere((ptr) {
      if (!ptr.safe && ptr.lastAccessTime < now - 5000) {
        free(ptr);
        return true;
      }
      return false;
    });
  }
}

class MemoryPool {
  List<int> freeBlocks = [];

  Pointer allocate(int size) {
    for (int i = 0; i < freeBlocks.length; i++) {
      final block = freeBlocks[i];
      if (block >= size) {
        freeBlocks.removeAt(i);
        return Pointer(block, size);
      }
    }
    final addr = _malloc(size);
    if (addr == 0) {
      throw ArgumentError("Number of bytes cannot be satisfied.");
    }
    return Pointer(addr, size);
  }

  void deallocate(Pointer ptr) {
    freeBlocks.add(ptr.addr);
  }
}

final _memoryPool = MemoryPool();
Malloc malloc = Malloc();

//js
@JS()
external int _malloc(int size);
