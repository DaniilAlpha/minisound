part of "wasm.dart";

sealed class NativeInteger {
  const NativeInteger();
}

final class Uint8 extends NativeInteger {
  const Uint8();
}

final class Uint16 extends NativeInteger {
  const Uint16();
}

final class Uint32 extends NativeInteger {
  const Uint32();
}

final class Size extends Uint32 {
  const Size();
}

final class _SizeOfHelper<T> {
  const _SizeOfHelper();
}

int sizeOf<T extends NativeInteger>() => switch (_SizeOfHelper<T>()) {
      _SizeOfHelper<Uint32>() => 4,
      _SizeOfHelper<Uint8>() => 1,
      _ => 1,
    };
