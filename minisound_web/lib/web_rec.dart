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

  @override
  Uint8List get data => _dataPtr.value.asTypedList(_dataSizePtr.value);

  @override
  void dispose() {
    _binds.rec_uninit(_self);
    malloc.free(_self);
  }

  @override
  Future<void> end() => _binds.rec_end(_self);
}
