part of "wasm.dart";

abstract base class Primitive {}

final class Float extends Primitive {}

final class Int16 extends Primitive {}

final class Int32 extends Primitive {}

final class Uint8 extends Primitive {}

int sizeOf<T extends Primitive>() => switch (T) {
      const (Float) || const (Int32) => 4,
      const (Int16) => 2,
      const (Uint8) => 1,
      _ => 1,
    };
