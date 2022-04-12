// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:typed_data';

import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:rewiverb4000s/models/patch/ewi_patch.dart';
import 'package:rewiverb4000s/models/sendmsg.dart';
import 'package:rewiverb4000s/models/types/byte.dart';
import 'package:rewiverb4000s/utils/midireciever.dart';

class MidiHelper {
  static final Byte MIDI_PRESET_DUMP = Byte(0x00);
  static final Byte MIDI_PRESET_DUMP_REQ = Byte(0x40);
  static final Byte MIDI_QUICKPC_DUMP = Byte(0x01);
  static final Byte MIDI_QUICKPC_DUMP_REQ = Byte(0x41);
  static final Byte MIDI_EDIT_LOAD = Byte(0x10);
  static final Byte MIDI_EDIT_STORE = Byte(0x11);
  static final Byte MIDI_EDIT_DUMP = Byte(0x20);
  static final Byte MIDI_EDIT_DUMP_REQ = Byte(0x60);

  static final Byte MIDI_SYSEX_HEADER = Byte(0xf0); // 0xf0
  static final Byte MIDI_SYSEX_TRAILER = Byte(0xf7); // 0xf7
  static final Byte MIDI_SYSEX_GEN_INFO = Byte(0x06);
  static final Byte MIDI_SYSEX_ID_REQ = Byte(0x01);
  static final Byte MIDI_SYSEX_ID = Byte(0x02);
  static final Byte MIDI_SYSEX_AKAI_ID = Byte(0x47); // 71.
  static final Byte MIDI_SYSEX_AKAI_EWI4K = Byte(0x64); // 100.
  static final Byte MIDI_SYSEX_CHANNEL = Byte(0x00);
  static final Byte MIDI_SYSEX_NONREALTIME = Byte(0x7e);
  static final Byte MIDI_SYSEX_ALLCHANNELS = Byte(0x7f);

  static final Byte MIDI_CC_DATA_ENTRY = Byte(0x06);
  static final Byte MIDI_CC_NRPN_LSB = Byte(0x62);
  static final Byte MIDI_CC_NRPN_MSB = Byte(0x63);

  static const int MAX_SYSEX_LENGTH = 262144;
  static const int EWI_SYSEX_PRESET_DUMP_LEN = EwiPatch.EWI_PATCH_LENGTH;
  static const int EWI_SYSEX_QUICKPC_DUMP_LEN = 91;
  static const int EWI_SYSEX_ID_RESPONSE_LEN = 15;

  static const int EWI_NUM_QUICKPCS = 84;

  //N.B. MIDI_TIMEOUT_MS must be significantly longer than MIDI_MESSAGE_LONG_PAUSE_MS
  // otherwise send & receive can get out of sync

  static const int MIDI_MESSAGE_SHORT_PAUSE_MS = 100;
  static const int MIDI_MESSAGE_LONG_PAUSE_MS = 250;
  static const int MIDI_TIMEOUT_MS = 3000;

  static final Log _logger = Log("SerialHelper");

  late MidiCommand _midiCommand;
  MidiDevice? _midiDevice;
  bool _devicePresent = false;

  late MidiReciever _reciever;

  MidiHelper() {
    _reciever = MidiReciever(this);
    _midiCommand = MidiCommand();
  }

  MidiReciever get reciever {
    return _reciever;
  }

  MidiCommand get midiCommand {
    return _midiCommand;
  }

  Future<bool> getDevicePresent() async {
    await _midiCommand.devices.then((List<MidiDevice>? devices) {
      if (devices == null) {
        _logger.error("Devices came back null!");
        _devicePresent = false;
      } else if (devices.isEmpty) {
        _devicePresent = false;
        _logger.warning("No midi device connected!");
      } else {
        _midiDevice = devices[0];
        _logger.info("Found midi device ${_midiDevice!.id}");
        _devicePresent = true;
      }
    });
    return devicePresent;
  }

  void connect() {
    if (_devicePresent) {
      _midiCommand.connectToDevice(_midiDevice!);
    } else {
      _logger.info("No device currently found!");
    }
  }

  void disconnect() {
    if (_devicePresent) {
      _midiCommand.disconnectDevice(_midiDevice!);
      _midiDevice = null;
      _devicePresent = false;
    } else {
      _logger.warning("No device to disconnect");
    }
  }

  void requestPatch(final int p) {
    if (p < 0 || p >= EwiPatch.EWI_NUM_PATCHES) {
      _logger.error("Attempt to request out-of-range patch ($p)");
      return;
    }

    Uint8List reqMsg = Uint8List(7);

    reqMsg[0] = MIDI_SYSEX_HEADER.value;
    reqMsg[1] = MIDI_SYSEX_AKAI_ID.value; // 0x47 71.
    reqMsg[2] = MIDI_SYSEX_AKAI_EWI4K.value; // 0x64 100.
    reqMsg[3] = MIDI_SYSEX_CHANNEL.value; // 0x00
    reqMsg[4] = MIDI_PRESET_DUMP_REQ.value; // 0x40 64.
    reqMsg[5] = p;
    reqMsg[6] = MIDI_SYSEX_TRAILER.value; // 0xf7 -9.

    if (_devicePresent) {
      _logger.info("Sending data!");
      _midiCommand.sendData(reqMsg);
    } else {
      _logger.warning("No device!");
    }

    //bool gotIt = false;

    // try {
    //   while (!gotIt) {
    //     _logger.debug( "Sending request for patch: 0 (Internal patch #: 99)" );
    //     sendSysEx( reqMsg, DelayType.SHORT );
    //     // wait for a patch to be received, or timeout
    //     Integer pGot = sharedData.patchQ.poll( MIDI_TIMEOUT_MS, TimeUnit.MILLISECONDS );
    //     if (pGot == null)  {
    //       _logger.debug( "Ppatch request timed out" );
    //       sharedData.patchQ.clear();
    //       // sendSystemReset();
    //     } else 	if (pGot == p) {
    //       gotIt = true;
    //     } else if (pGot != p) {
    //       _logger.debug( "Got out-of-sync patch: $p" );
    //       sharedData.patchQ.clear();
    //     }
    //   }
    // } catch( InterruptedException e ) {
    //   e.printStackTrace();
    // }
  }

  void sendSysEx(Uint8List sysexBytes, DelayType pause) {
    SendMsg msg = SendMsg();
    msg.msgType = MidiMsgType.SYSEX;
    msg.bytes = sysexBytes;
    msg.delay = pause;
    //sharedData.sendQ.add( msg );
  }

  bool get devicePresent {
    return _devicePresent;
  }
}
