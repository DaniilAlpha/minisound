// ignore_for_file: non_constant_identifier_names, slash_for_doc_comments

part of "wasm.dart";

class Heap {
  const Heap();

  Uint8List get _heapU8 => _GROWABLE_HEAP_U8();
  Int32List get _heapI32 => _GROWABLE_HEAP_I32();
  Float32List get _heapF32 => _GROWABLE_HEAP_F32();
  Float64List get _heapF64 => _GROWABLE_HEAP_F64();

  int operator [](int index) => _heapU8[index];
  void operator []=(int index, int value) => _heapU8[index] = value;

  void copyUint8List(Pointer ptr, Uint8List data) =>
      _heapU8.setRange(ptr.addr, ptr.addr + data.lengthInBytes, data);

  void copyInt32List(Pointer ptr, Int32List data) =>
      _heapI32.setRange(ptr.addr ~/ 4, ptr.addr ~/ 4 + data.length, data);

  void copyFloat32List(Pointer ptr, Float32List data) =>
      _heapF32.setRange(ptr.addr ~/ 4, ptr.addr ~/ 4 + data.length, data);

  void copyFloat64List(Pointer ptr, Float64List data) =>
      _heapF64.setRange(ptr.addr ~/ 8, ptr.addr ~/ 8 + data.length, data);

  void copyAudioData(Pointer ptr, dynamic data, AudioFormat format) {
    if (data is ByteBuffer) {
      data = _getTypedDataViewFromByteBuffer(data, format);
    }

    if (data is! TypedData) {
      throw ArgumentError('Data must be either ByteBuffer or TypedData');
    }

    switch (format) {
      case AudioFormat.uint8:
        copyUint8List(ptr, data as Uint8List);
        break;
      case AudioFormat.int16:
        // Handle int16 as special case
        _copyInt16ListAsInt32(ptr, data as Int16List);
        break;
      case AudioFormat.int32:
        copyInt32List(ptr, data as Int32List);
        break;
      case AudioFormat.float32:
        copyFloat32List(ptr, data as Float32List);
        break;
      default:
        throw ArgumentError('Unsupported audio format: $format');
    }
  }

  void _copyInt16ListAsInt32(Pointer ptr, Int16List data) {
    // Copy Int16List data into Int32List view of the heap
    for (int i = 0; i < data.length; i++) {
      _heapI32[ptr.addr ~/ 4 + i] = data[i];
    }
  }

  TypedData _getTypedDataViewFromByteBuffer(
      ByteBuffer buffer, AudioFormat format) {
    switch (format) {
      case AudioFormat.uint8:
        return buffer.asUint8List();
      case AudioFormat.int16:
        return buffer.asInt16List();
      case AudioFormat.int32:
        return buffer.asInt32List();
      case AudioFormat.float32:
        return buffer.asFloat32List();
      default:
        throw ArgumentError('Unsupported audio format: $format');
    }
  }
}

const heap = Heap();

@JS("GROWABLE_HEAP_U8")
external Uint8List _GROWABLE_HEAP_U8();

@JS("GROWABLE_HEAP_I32")
external Int32List _GROWABLE_HEAP_I32();

@JS("GROWABLE_HEAP_F32")
external Float32List _GROWABLE_HEAP_F32();

@JS("GROWABLE_HEAP_F64")
external Float64List _GROWABLE_HEAP_F64();
