import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:rewiverb4000s/utils/midihelper.dart';

class SerialPage extends StatefulWidget {
  const SerialPage({Key? key}) : super(key: key);

  @override
  State<SerialPage> createState() => _SerialPageState();
}

class _SerialPageState extends State<SerialPage> {
  final Log _logger = Log("SerialPage");
  late MidiHelper midiHelper;
  StreamSubscription<String>? _setupSubscription;
  StreamSubscription<MidiPacket>? _dataSubscription;
  StreamSubscription<Uint8List>? _sentStream;

  @override
  void initState() {
    super.initState();
    setState(() {
      midiHelper = MidiHelper();
      _setupSubscription = midiHelper.midiCommand.onMidiSetupChanged?.listen((event) async {
        _logger.debug("SETUP: $event");
      });
      _dataSubscription = midiHelper.midiCommand.onMidiDataReceived?.listen((event) async { 
        _logger.debug("GOT: (length: ${event.data.length}) ${event.data} from ${event.device.id}");
      });
      _sentStream = midiHelper.midiCommand.onMidiDataSent.listen((event) {
        _logger.debug("SENT: ${event.toString()}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            midiHelper.getDevicePresent();
          },
          child: const Text("Find device"),
        ),
        ElevatedButton(
          onPressed: () async {
            midiHelper.connect();
          },
          child: const Text("Connect"),
        ),
        ElevatedButton(
          onPressed: () async {
            midiHelper.requestPatch(0);
            midiHelper.requestPatch(99);
            midiHelper.requestPatch(39);
          },
          child: const Text("Ask for packet"),
        ),
      ],
    );
  }
}
