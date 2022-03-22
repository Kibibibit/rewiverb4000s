import 'dart:typed_data';
import 'package:rewiverb4000s/models/types/byte.dart';

/// Absolutely no clue what this is
class Nrpn {
  late Byte lsb;
  late Byte msb;
  late Byte offset;

  void decode(Uint8List raw) {
    lsb = Byte(raw.elementAt(0));
    msb = Byte(raw.elementAt(1));
    offset = Byte(raw.elementAt(2));
  }

  Uint8List toBytes() {
    Uint8List blob = Uint8List(3);
    blob[0] = lsb.value;
    blob[1] = msb.value;
    blob[2] = offset.value;
    return blob;
  }
}
