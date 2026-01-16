final error =
    UnimplementedError("Files are not supported by `minisound` on the web.");

final class File {
  File(String path) {
    throw error;
  }

  void createSync({bool recursive = false, bool exclusive = false}) =>
      throw error;

  Future<File> writeAsBytes(List<int> bytes, {bool flush = false}) =>
      throw error;
}
