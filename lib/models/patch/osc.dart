import 'dart:typed_data';

import 'package:rewiverb4000s/models/patch/nrpn.dart';
import 'package:rewiverb4000s/models/types/byte.dart';

class Osc {
  late Nrpn nrpn;
  late Byte octave; // Byte 64 +/-2
  late Byte semitone; // Byte 64 +/-12
  late Byte fine; // Byte -50 - +50 cents
  late Byte beat; // Byte 0% - 100%
  late Byte filler1; // this really is unused (for firmware 2.3 anyway)
  late Byte sawtooth; // %
  late Byte triangle; // %
  late Byte square; // %
  late Byte pulseWidth; // %
  late Byte pwmFreq; // %
  late Byte pwmDepth; // %
  late Byte sweepDepth; // %
  late Byte sweepTime; // %
  late Byte breathDepth; // %  ?-50/+50?
  late Byte breathAttain; // %
  late Byte breathCurve; // %  ? =50+50?
  late Byte breathThreshold; // %
  late Byte level; // %

  Osc() {
    nrpn = Nrpn();
  }

  void decode(Uint8List raw) {
    nrpn.decode(raw);
    octave = Byte(raw[3]);
    semitone = Byte(raw[4]);
    fine = Byte(raw[5]);
    beat = Byte(raw[6]);
    filler1 = Byte(raw[7]);
    sawtooth = Byte(raw[8]);
    triangle = Byte(raw[9]);
    square = Byte(raw[10]);
    pulseWidth = Byte(raw[11]);
    pwmFreq = Byte(raw[12]);
    pwmDepth = Byte(raw[13]);
    sweepDepth = Byte(raw[14]);
    sweepTime = Byte(raw[15]);
    breathDepth = Byte(raw[16]);
    breathAttain = Byte(raw[17]);
    breathCurve = Byte(raw[18]);
    breathThreshold = Byte(raw[19]);
    level = Byte(raw[20]);
  }

  Uint8List toBytes() {
    Uint8List blob = Uint8List(21);
    blob.replaceRange(0, 2, nrpn.toBytes());
    blob[3] = octave.value;
    blob[4] = semitone.value;
    blob[5] = fine.value;
    blob[6] = beat.value;
    blob[7] = filler1.value;
    blob[8] = sawtooth.value;
    blob[9] = triangle.value;
    blob[10] = square.value;
    blob[11] = pulseWidth.value;
    blob[12] = pwmFreq.value;
    blob[13] = pwmDepth.value;
    blob[14] = sweepDepth.value;
    blob[15] = sweepTime.value;
    blob[16] = breathDepth.value;
    blob[17] = breathAttain.value;
    blob[18] = breathCurve.value;
    blob[19] = breathThreshold.value;
    blob[20] = level.value;
    return blob;
  }
}
