import 'dart:collection';

import 'package:flutter/services.dart';

/// Class to store methods that might be too unweildy to use in other classes,
/// or that perhaps we want to use across classes.
class Helper {
  // https://www.fluttercampus.com/guide/221/play-soud-from-assets-folder-flutter/
  /// Returns a list of the data for all 88 piano audio files
  static Future<Map<String, Uint8List>> loadAudioFiles() async {
    Map<String, Uint8List> toReturn = HashMap();

    String pathBeginning = "assets/audio/";
    List<String> names = [
      'A',
      'Ab',
      'B',
      'Bb',
      'C',
      'D',
      'Db',
      'E',
      'Eb',
      'F',
      'G',
      'Gb'
    ];
    // 1-7 of all notes (84/88)
    for (int i = 1; i <= 7; i++) {
      for (int j = 0; j < 12; j++) {
        String name = "${names[j]}$i";
        ByteData bytes =
            await rootBundle.load("${pathBeginning}Piano.ff.$name.flac");
        Uint8List soundbytes =
            bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
        toReturn[name] = soundbytes;
      }
    }

    // The last 4 notes (A0, B0, Bb0, and C8)
    ByteData aBytes = await rootBundle.load("${pathBeginning}Piano.ff.A0.flac");
    ByteData bBytes = await rootBundle.load("${pathBeginning}Piano.ff.B0.flac");
    ByteData bbBytes =
        await rootBundle.load("${pathBeginning}Piano.ff.Bb0.flac");
    ByteData cBytes = await rootBundle.load("${pathBeginning}Piano.ff.C8.flac");
    ByteData rBytes = await rootBundle.load("${pathBeginning}rest.mp3");
    Uint8List aSoundbytes =
        aBytes.buffer.asUint8List(aBytes.offsetInBytes, aBytes.lengthInBytes);
    Uint8List bSoundbytes =
        bBytes.buffer.asUint8List(bBytes.offsetInBytes, bBytes.lengthInBytes);
    Uint8List bbSoundbytes = bbBytes.buffer
        .asUint8List(bbBytes.offsetInBytes, bbBytes.lengthInBytes);
    Uint8List cSoundbytes =
        cBytes.buffer.asUint8List(cBytes.offsetInBytes, cBytes.lengthInBytes);
    Uint8List rSoundbytes =
        rBytes.buffer.asUint8List(rBytes.offsetInBytes, rBytes.lengthInBytes);
    toReturn["A0"] = aSoundbytes;
    toReturn["B0"] = bSoundbytes;
    toReturn["Bb0"] = bbSoundbytes;
    toReturn["C8"] = cSoundbytes;
    toReturn["R"] = rSoundbytes;

    return toReturn;
  }
}
