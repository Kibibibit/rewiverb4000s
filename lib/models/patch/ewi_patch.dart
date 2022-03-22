// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:typed_data';

import 'package:geoff/utils/system/log.dart';
import 'package:rewiverb4000s/models/patch/filter.dart';
import 'package:rewiverb4000s/models/patch/nrpn.dart';
import 'package:rewiverb4000s/models/patch/osc.dart';
import 'package:rewiverb4000s/models/types/byte.dart';

class EwiPatch {
  static final Log _logger = Log("EwiPatch");

  static const int EWI_NUM_PATCHES = 100; // 0..99
  static const int EWI_PATCH_LENGTH = 206; // bytes
  static const int EWI_PATCHNAME_LENGTH = 32;
  static final Byte EWI_EDIT = Byte(0x20);
  static final Byte EWI_SAVE = Byte(0x00);

  late Uint8List patchBlob;

  late Uint8List header; // 4 bytes
  late Byte mode; // 0x00 to store, 0x20 to edit
  late Byte internalPatchNum;
  late Byte filler2;
  late Byte filler3;
  late Byte filler4;
  late Byte filler5;
  late Byte filler6;
  late Byte filler7;
  late String name;
  late Osc osc1; // 64,18
  late Osc osc2; // 65,18
  late Filter oscFilter1; // 72,12
  late Filter oscFilter2; // 73,12
  late Filter noiseFilter1; // 74,12
  late Filter noiseFilter2; // 75,12
  late Nrpn antiAliasNRPN; // 79,3
  late Byte antiAliasSwitch;
  late Byte antiAliasCutoff;
  late Byte antiAliasKeyFollow;
  late Nrpn noiseNRPN; // 80,3
  late Byte noiseTime;
  late Byte noiseBreath;
  late Byte noiseLevel;
  late Nrpn miscNRPN; // 81,10
  late Byte bendRange;
  late Byte bendStepMode;
  late Byte biteVibrato;
  late Byte oscFilterLink;
  late Byte noiseFilterLink;
  late Byte formantFilter;
  late Byte osc2Xfade;
  late Byte keyTrigger;
  late Byte filler10;
  late Byte chorusSwitch;
  late Nrpn ampNRPN; // 88,3
  late Byte biteTremolo;
  late Byte ampLevel;
  late Byte octaveLevel;
  late Nrpn chorusNRPN; // 112,9
  late Byte chorusDelay1;
  late Byte chorusModLev1;
  late Byte chorusWetLev1;
  late Byte chorusDelay2;
  late Byte chorusModLev2;
  late Byte chorusWetLev2;
  late Byte chorusFeedback;
  late Byte chorusLFOfreq;
  late Byte chorusDryLevel;
  late Nrpn delayNRPN; // 113,5
  late Byte delayTime;
  late Byte delayFeedback;
  late Byte delayDamp;
  late Byte delayLevel;
  late Byte delayDry; // ZJ
  late Nrpn reverbNRPN; // 114,5
  late Byte reverbDry; // ZJ
  late Byte reverbLevel;
  late Byte reverbDensity;
  late Byte reverbTime;
  late Byte reverbDamp;
  late Byte trailer_f7; // 0xf7 !!!

  late bool _empty;

  bool get empty {
    return _empty;
  }

  void setEmpty(bool e) {
    _empty = e;
  }

  String getName() {
    return name.trim();
  }

  void setName(String name) {
    this.name = name.substring(0, EWI_PATCHNAME_LENGTH);
    nameToBlob();
  }

  void nameToBlob() {
    for (int ix = 12; ix < (12 + EWI_PATCHNAME_LENGTH); ix++) {
      patchBlob[ix] = name.codeUnits[ix - 12];
    }
  }

  EwiPatch() {
    patchBlob = Uint8List(EWI_PATCH_LENGTH);
    header = Uint8List(4);
    name = "";
    osc1 = Osc();
    osc2 = Osc();
    oscFilter1 = Filter();
    oscFilter2 = Filter();
    noiseFilter1 = Filter();
    noiseFilter2 = Filter();
    antiAliasNRPN = Nrpn();
    noiseNRPN = Nrpn();
    miscNRPN = Nrpn();
    ampNRPN = Nrpn();
    chorusNRPN = Nrpn();
    delayNRPN = Nrpn();
    reverbNRPN = Nrpn();

    setEmpty(true);
  }

  static EwiPatch fromBlob(Uint8List blob) {
    EwiPatch patch = EwiPatch();
    patch.patchBlob = blob;
    patch.decodeBlob();
    patch.setEmpty(false);
    return patch;
  }

  void setInternalPatchNum(int num) {
    internalPatchNum = Byte(num % EWI_NUM_PATCHES);
    patchBlob[5] = internalPatchNum.value;
  }

  void setPatchMode(Byte newMode) {
    if (newMode != EWI_SAVE && newMode != EWI_EDIT) {
      _logger.error(
          "Error - Internal error in EWI4000sPatch: Invalid Edit/Save mode requested");
      return;
    }
    mode = newMode;
    patchBlob[4] = mode.value;
  }

  void decodeBlob() {
    header = Uint8List.fromList(patchBlob.getRange(0, 4).toList());
    mode = Byte(patchBlob[4]); // 0x00 to store, 0x20 to edit
    internalPatchNum = Byte(patchBlob[5]);
    filler2 = Byte(patchBlob[6]);
    filler3 = Byte(patchBlob[7]);
    filler4 = Byte(patchBlob[8]);
    filler5 = Byte(patchBlob[9]);
    filler6 = Byte(patchBlob[10]);
    filler7 = Byte(patchBlob[11]);
    name = "";
    for (int ix = 12; ix < (12 + EWI_PATCHNAME_LENGTH); ix++) {
      name += String.fromCharCode(patchBlob[ix]);
    }
    osc1.decode(
        Uint8List.fromList(patchBlob.getRange(44, 65).toList())); // 64,18
    osc2.decode(
        Uint8List.fromList(patchBlob.getRange(65, 86).toList())); // 65,18
    oscFilter1.decode(
        Uint8List.fromList(patchBlob.getRange(86, 101).toList())); // 72,12
    oscFilter2.decode(
        Uint8List.fromList(patchBlob.getRange(101, 116).toList())); // 73,12
    noiseFilter1.decode(
        Uint8List.fromList(patchBlob.getRange(116, 131).toList())); // 74,12
    noiseFilter2.decode(
        Uint8List.fromList(patchBlob.getRange(131, 146).toList())); // 75,12
    antiAliasNRPN.decode(
        Uint8List.fromList(patchBlob.getRange(146, 149).toList())); // 79,3
    antiAliasSwitch = Byte(patchBlob[149]);
    antiAliasCutoff = Byte(patchBlob[150]);
    antiAliasKeyFollow = Byte(patchBlob[151]);
    noiseNRPN.decode(
        Uint8List.fromList(patchBlob.getRange(152, 155).toList())); // 80,3
    noiseTime = Byte(patchBlob[155]);
    noiseBreath = Byte(patchBlob[156]);
    noiseLevel = Byte(patchBlob[157]);
    miscNRPN.decode(
        Uint8List.fromList(patchBlob.getRange(158, 161).toList())); // 81,10
    bendRange = Byte(patchBlob[161]);
    bendStepMode = Byte(patchBlob[162]);
    biteVibrato = Byte(patchBlob[163]);
    oscFilterLink = Byte(patchBlob[164]);
    noiseFilterLink = Byte(patchBlob[165]);
    formantFilter = Byte(patchBlob[166]);
    osc2Xfade = Byte(patchBlob[167]);
    keyTrigger = Byte(patchBlob[168]);
    filler10 = Byte(patchBlob[169]);
    chorusSwitch = Byte(patchBlob[170]);
    ampNRPN.decode(
        Uint8List.fromList(patchBlob.getRange(171, 174).toList())); // 88,3
    biteTremolo = Byte(patchBlob[174]);
    ampLevel = Byte(patchBlob[175]);
    octaveLevel = Byte(patchBlob[176]);
    chorusNRPN.decode(
        Uint8List.fromList(patchBlob.getRange(177, 180).toList())); // 112,9
    chorusDelay1 = Byte(patchBlob[180]);
    chorusModLev1 = Byte(patchBlob[181]);
    chorusWetLev1 = Byte(patchBlob[182]);
    chorusDelay2 = Byte(patchBlob[183]);
    chorusModLev2 = Byte(patchBlob[184]);
    chorusWetLev2 = Byte(patchBlob[185]);
    chorusFeedback = Byte(patchBlob[186]);
    chorusLFOfreq = Byte(patchBlob[187]);
    chorusDryLevel = Byte(patchBlob[188]);
    delayNRPN.decode(
        Uint8List.fromList(patchBlob.getRange(189, 192).toList())); // 113,5
    delayTime = Byte(patchBlob[192]);
    delayFeedback = Byte(patchBlob[193]);
    delayDamp = Byte(patchBlob[194]);
    delayLevel = Byte(patchBlob[195]);
    delayDry = Byte(patchBlob[196]); // ZJ
    reverbNRPN.decode(
        Uint8List.fromList(patchBlob.getRange(197, 200).toList())); // 114,5
    reverbDry = Byte(patchBlob[200]); // ZJ
    reverbLevel = Byte(patchBlob[201]);
    reverbDensity = Byte(patchBlob[202]);
    reverbTime = Byte(patchBlob[203]);
    reverbDamp = Byte(patchBlob[204]);
    trailer_f7 = Byte(patchBlob[205]); // 0xf7 !!!

    setEmpty(false);
  }

  void encodeBlob() {
    int ix;

    for (ix = 0; ix < 4; ix++) {
      patchBlob[ix] = header[ix];
    }
    patchBlob[4] = mode.value; // 0x00 to store, 0x20 to edit
    patchBlob[5] = internalPatchNum.value;
    patchBlob[6] = filler2.value;
    patchBlob[7] = filler3.value;
    patchBlob[8] = filler4.value;
    patchBlob[9] = filler5.value;
    patchBlob[10] = filler6.value;
    patchBlob[11] = filler7.value;
    nameToBlob();
    for (ix = 0; ix < osc1.toBytes().length; ix++) {
      patchBlob[44 + ix] = osc1.toBytes()[ix];
    }
    for (ix = 0; ix < osc2.toBytes().length; ix++) {
      patchBlob[65 + ix] = osc2.toBytes()[ix];
    }

    for (ix = 0; ix < oscFilter1.toBytes().length; ix++) {
      patchBlob[86 + ix] = oscFilter1.toBytes()[ix];
    }
    for (ix = 0; ix < oscFilter2.toBytes().length; ix++) {
      patchBlob[101 + ix] = oscFilter2.toBytes()[ix];
    }

    for (ix = 0; ix < noiseFilter1.toBytes().length; ix++) {
      patchBlob[116 + ix] = noiseFilter1.toBytes()[ix];
    }
    for (ix = 0; ix < noiseFilter2.toBytes().length; ix++) {
      patchBlob[131 + ix] = noiseFilter2.toBytes()[ix];
    }
    for (ix = 0; ix < antiAliasNRPN.toBytes().length; ix++) {
      patchBlob[146 + ix] = antiAliasNRPN.toBytes()[ix];
    }
    patchBlob[149] = antiAliasSwitch.value;
    patchBlob[150] = antiAliasCutoff.value;
    patchBlob[151] = antiAliasKeyFollow.value;

    for (ix = 0; ix < noiseNRPN.toBytes().length; ix++) {
      patchBlob[152 + ix] = noiseNRPN.toBytes()[ix];
    }

    patchBlob[155] = noiseTime.value;
    patchBlob[156] = noiseBreath.value;
    patchBlob[157] = noiseLevel.value;
    for (ix = 0; ix < miscNRPN.toBytes().length; ix++) {
      patchBlob[158 + ix] = miscNRPN.toBytes()[ix];
    }
    patchBlob[161] = bendRange.value;
    patchBlob[162] = bendStepMode.value;
    patchBlob[163] = biteVibrato.value;
    patchBlob[164] = oscFilterLink.value;
    patchBlob[165] = noiseFilterLink.value;
    patchBlob[166] = formantFilter.value;
    patchBlob[167] = osc2Xfade.value;
    patchBlob[168] = keyTrigger.value;
    patchBlob[169] = filler10.value;
    patchBlob[170] = chorusSwitch.value;
    for (ix = 0; ix < ampNRPN.toBytes().length; ix++) {
      patchBlob[171 + ix] = ampNRPN.toBytes()[ix];
    }
    patchBlob[174] = biteTremolo.value;
    patchBlob[175] = ampLevel.value;
    patchBlob[176] = octaveLevel.value;
    for (ix = 0; ix < chorusNRPN.toBytes().length; ix++) {
      patchBlob[176 + ix] = chorusNRPN.toBytes()[ix];
    }
    patchBlob[180] = chorusDelay1.value;
    patchBlob[181] = chorusModLev1.value;
    patchBlob[182] = chorusWetLev1.value;
    patchBlob[183] = chorusDelay2.value;
    patchBlob[184] = chorusModLev2.value;
    patchBlob[185] = chorusWetLev2.value;
    patchBlob[186] = chorusFeedback.value;
    patchBlob[187] = chorusLFOfreq.value;
    patchBlob[188] = chorusDryLevel.value;
    for (ix = 0; ix < delayNRPN.toBytes().length; ix++) {
      patchBlob[189 + ix] = delayNRPN.toBytes()[ix];
    }
    patchBlob[192] = delayTime.value;
    patchBlob[193] = delayFeedback.value;
    patchBlob[194] = delayDamp.value;
    patchBlob[195] = delayLevel.value;
    patchBlob[196] = delayDry.value;
    for (ix = 0; ix < reverbNRPN.toBytes().length; ix++) {
      patchBlob[197 + ix] = reverbNRPN.toBytes()[ix];
    }
    patchBlob[200] = reverbDry.value;
    patchBlob[201] = reverbLevel.value;
    patchBlob[202] = reverbDensity.value;
    patchBlob[203] = reverbTime.value;
    patchBlob[204] = reverbDamp.value;
    patchBlob[205] = trailer_f7.value;
  }
}
