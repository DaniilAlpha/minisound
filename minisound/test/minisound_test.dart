import "package:minisound/minisound.dart";
import "package:minisound_platform_interface/minisound_platform_interface.dart";

void main() async {
  final engine = Engine();
  await engine.init(10);
}
