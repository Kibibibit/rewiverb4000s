import 'dart:typed_data';

import 'package:rewiverb4000s/models/patch/nrpn.dart';
import 'package:rewiverb4000s/models/types/byte.dart';

class Filter {
    late Nrpn nrpn;
    late Byte mode;
    late Byte freq;
    late Byte q;
    late Byte keyFollow;
    late Byte breathMod;
    late Byte lfoFreq;
    late Byte lfoDepth;
    late Byte lfoBreath;
    late Byte lfoThreshold;
    late Byte sweepDepth;
    late Byte sweepTime;
    late Byte breathCurve;  
    
    Filter() {
      nrpn = Nrpn();
    }
 
    void decode( Uint8List raw ) {
      nrpn.decode( raw );
      mode    = Byte(raw[3]);
      freq    = Byte(raw[4]);
      q       = Byte(raw[5]);
      keyFollow = Byte(raw[6]);
      breathMod = Byte(raw[7]);
      lfoFreq   = Byte(raw[8]);
      lfoDepth  = Byte(raw[9]);
      lfoBreath = Byte(raw[10]);
      lfoThreshold  = Byte(raw[11]);
      sweepDepth    = Byte(raw[12]);
      sweepTime     = Byte(raw[13]);
      breathCurve   = Byte(raw[14]);
    }
    
    Uint8List toBytes() {
      Uint8List blob = Uint8List(15);
      blob.replaceRange(0, 2, nrpn.toBytes());
      blob[3] = mode.value;
      blob[4] = freq.value;
      blob[5] = q.value;
      blob[6] = keyFollow.value;
      blob[7] = breathMod.value;
      blob[8] = lfoFreq.value;
      blob[9] = lfoDepth.value;
      blob[10] = lfoBreath.value;
      blob[11] = lfoThreshold.value;
      blob[12] = sweepDepth.value;
      blob[13] = sweepTime.value;
      blob[14] = breathCurve.value;
      return blob;
    }

  }