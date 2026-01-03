part of "minisound_ffi.dart";

class FfiRec implements PlatformRec {
  factory FfiRec._(Pointer<c.Rec> self) => _nativeRecs[self] ?? FfiRec.__(self);

  FfiRec.__(Pointer<c.Rec> self) : _self = self;

  static final _nativeRecs = <Pointer<c.Rec>, FfiRec>{};

  final Pointer<c.Rec> _self;

  @override
  Uint8List read() {
    final outData = malloc.allocate<Pointer<Uint8>>(sizeOf<Pointer<Uint8>>()),
        outDataSize = malloc.allocate<Size>(sizeOf<Size>());
    if (outData == nullptr) throw MinisoundPlatformOutOfMemoryException();
    _binds.rec_read(_self, outData, outDataSize);
    final data = outData.value, dataSize = outDataSize.value;
    malloc.free(outData);
    malloc.free(outDataSize);

    final readData = data.asTypedList(dataSize);
    malloc.free(data);
    return readData;
  }

  @override
  void dispose() {
    _nativeRecs.remove(_self);

    _binds.rec_uninit(_self);
    malloc.free(_self);
  }
}
