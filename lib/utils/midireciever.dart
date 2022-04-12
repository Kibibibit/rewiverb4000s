import 'dart:typed_data';

import 'package:geoff/utils/system/log.dart';
import 'package:rewiverb4000s/models/patch/ewi_patch.dart';
import 'package:rewiverb4000s/utils/midihelper.dart';

class MidiReciever {
  final Log _logger = Log("MidiReciever");

  late MidiHelper midiHelper;

  MidiReciever(this.midiHelper);

  void recieveMessage(Uint8List message) {
    message = Uint8List.fromList(message.getRange(1, message.length).toList());
    if (message[0] != MidiHelper.MIDI_SYSEX_AKAI_ID.value ||
        message[1] != MidiHelper.MIDI_SYSEX_AKAI_EWI4K.value) {
      _logger.warning("Message in wrong format, rejecting");
      return;
    }

    if (message[3] == MidiHelper.MIDI_PRESET_DUMP.value) {
      if (message.length != (MidiHelper.EWI_SYSEX_PRESET_DUMP_LEN - 1)) {
        _logger.error(
            "Invalid preset dump SysEx received from EWI (${message.length} bytes)");
        return;
      }

      EwiPatch patch = EwiPatch();
      patch.patchBlob[0] = 0xf0;
      for (int b = 0; b < (MidiHelper.EWI_SYSEX_PRESET_DUMP_LEN - 1); b++) {
        patch.patchBlob[b + 1] = message[b];
      }

      patch.patchBlob[MidiHelper.EWI_SYSEX_PRESET_DUMP_LEN - 1] = 0xf7;
      patch.decodeBlob();

      if (patch.header[3] == MidiHelper.MIDI_SYSEX_ALLCHANNELS.value) {
        int patchNum = patch.internalPatchNum.value;
        if (patchNum < 0 || patchNum >= EwiPatch.EWI_NUM_PATCHES) {
          _logger.error("Invalid patch number ($patchNum) received from EWI");
        } else {
          // adjust thisPatchNum to be displayed version of the patch number
          if (patchNum == 99) {
            patchNum = 0;
          } else {
            patchNum++;
          }
          //if (thisPatchNum == 99) sharedData.setLastPatchLoaded( thisPatchNum );
          //sharedData.patchQ.add( thisPatchNum );
          _logger.debug("Patch: ${patch.getName()} ($patchNum) received");
        }
      }
      return;
    }
  }
}
