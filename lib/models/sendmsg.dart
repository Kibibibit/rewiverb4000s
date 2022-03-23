// ignore_for_file: constant_identifier_names

import 'dart:typed_data';

class SendMsg {
  late MidiMsgType msgType;
  late DelayType delay;

  // sysex body...
  late Uint8List bytes;

  // control change properties...
  //  public int channel;
  int? cc;
  int? value;

  SendMsg() {
    delay = DelayType.NONE;
  }
}

enum MidiMsgType { SYSEX, CC, SYSTEM_RESET }

enum DelayType { NONE, SHORT, LONG }
