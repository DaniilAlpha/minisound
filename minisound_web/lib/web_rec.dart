part of "minisound_web.dart";

class WebRec implements PlatformRec {
  WebRec._(Pointer<c.Rec> self, Pointer<Pointer<Uint8>> dataPtr,
      Pointer<Size> dataSizePtr)
      : _self = self,
        _dataPtr = dataPtr,
        _dataSizePtr = dataSizePtr;

  final Pointer<c.Rec> _self;

  final Pointer<Pointer<Uint8>> _dataPtr;
  final Pointer<Size> _dataSizePtr;

  Uint8List? data;

  @override
  void dispose() {
    malloc.free(_dataPtr);
    malloc.free(_dataSizePtr);

    _binds.rec_uninit(_self);
    malloc.free(_self);
  }

  @override
  Future<Uint8List> end() async {
    if (data != null) return data!;

    final r = await _binds.rec_end(_self);
    if (r != c.Result.Ok) {
      malloc.free(_dataPtr.value);
      throw MinisoundPlatformException("Failed to and a recording (code: $r).");
    }

    data = Uint8List.fromList(_dataPtr.value.asTypedList(_dataSizePtr.value));
    malloc.free(_dataPtr.value);
    _dataPtr.value = nullptr.cast();

    return data!;
  }
}
