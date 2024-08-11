// ignore_for_file: non_constant_identifier_names

part of "wasm.dart";

class Heap {
  const Heap();

  Uint8List get _heapU8 => _GROWABLE_HEAP_U8();
  Int32List get _heapI32 => _GROWABLE_HEAP_I32();
  Float32List get _heapF32 => _GROWABLE_HEAP_F32();
  Float64List get _heapF64 => _GROWABLE_HEAP_F64();

  int operator [](int index) => _heapU8[index];
  void operator []=(int index, int value) => _heapU8[index] = value;

  void copyUint8List(Pointer ptr, Uint8List data) {
    final end = ptr.addr + data.length;
    if (end > _heapU8.length) {
      throw ArgumentError("Heap out of bounds");
    }
    _heapU8.setRange(ptr.addr, end, data);
  }

  void copyInt32List(Pointer ptr, Int32List data) {
    final startIndex = ptr.addr ~/ 4;
    final endIndex = startIndex + data.length;
    if (endIndex > _heapI32.length) {
      throw ArgumentError("Heap out of bounds");
    }
    _heapI32.setRange(startIndex, endIndex, data);
  }

  void copyFloat32List(Pointer ptr, Float32List data) {
    final startIndex = ptr.addr ~/ 4;
    final endIndex = startIndex + data.length;
    if (endIndex > _heapF32.length) {
      throw ArgumentError("Heap out of bounds");
    }
    _heapF32.setRange(startIndex, endIndex, data);
  }

  void copyFloat64List(Pointer ptr, Float64List data) {
    final startIndex = ptr.addr ~/ 8;
    final endIndex = startIndex + data.length;
    if (endIndex > _heapF64.length) {
      throw ArgumentError("Heap out of bounds");
    }
    _heapF64.setRange(startIndex, endIndex, data);
  }

  void copyAudioData(Pointer ptr, dynamic data, SoundFormat format) {
    if (data is ByteBuffer) {
      // ignore: parameter_assignments
      data = _getTypedDataViewFromByteBuffer(data, format);
    }

    if (data is Float32List) {
      copyFloat32List(ptr, data);
    } else if (data is TypedData) {
      switch (format) {
        case SoundFormat.u8:
          copyUint8List(ptr, data as Uint8List);

        case SoundFormat.s16:
          _copyInt16ListAsInt32(ptr, data as Int16List);

        case SoundFormat.s32:
          copyInt32List(ptr, data as Int32List);

        default:
          throw ArgumentError("Unsupported audio format: $format");
      }
    } else {
      throw ArgumentError(
          "Data must be either ByteBuffer, Float32List, or TypedData");
    }
  }

  void _copyInt16ListAsInt32(Pointer ptr, Int16List data) {
    final startIndex = ptr.addr ~/ 4;
    final endIndex = startIndex + data.length;
    if (endIndex > _heapI32.length) {
      throw ArgumentError("Heap out of bounds");
    }

    for (var i = 0; i < data.length; i++) {
      _heapI32[startIndex + i] = data[i];
    }
  }

  TypedData _getTypedDataViewFromByteBuffer(
    ByteBuffer buffer,
    SoundFormat format,
  ) =>
      switch (format) {
        SoundFormat.u8 => buffer.asUint8List(),
        SoundFormat.s16 => buffer.asInt16List(),
        SoundFormat.s32 => buffer.asInt32List(),
        SoundFormat.f32 => buffer.asFloat32List(),
        // TODO!!! we need to support all formats
        _ => throw ArgumentError("Unsupported audio format: $format"),
      };
}

const heap = Heap();

// js interop
@JS("GROWABLE_HEAP_U8")
external Uint8List _GROWABLE_HEAP_U8();

@JS("GROWABLE_HEAP_I32")
external Int32List _GROWABLE_HEAP_I32();

@JS("GROWABLE_HEAP_F32")
external Float32List _GROWABLE_HEAP_F32();

@JS("GROWABLE_HEAP_F64")
external Float64List _GROWABLE_HEAP_F64();
