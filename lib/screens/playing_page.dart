import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_notato/models/note.dart';
import 'package:music_notato/models/score.dart';
import 'package:music_notato/screens/home_page.dart';

/// Class responsible for playing back the music written on the staff
class PlayingPage extends StatelessWidget {
  // Setting these variables like this is useless; they'll all have null values
  Score score = HomePage().getScore();
  int tempo = HomePage().getTempo();
  int signature_ = HomePage().getSignature_();

  final player = AudioPlayer();

  // Map of duration values to fraction of a measure using whole note = 1
  Map<int, double> durationRatios = {
    32: 1 / 32,
    48: 3 / 64,
    16: 1 / 16,
    24: 3 / 32,
    8: 1 / 8,
    12: 3 / 16,
    4: 1 / 4,
    6: 3 / 8,
    2: 1 / 2,
    3: 3 / 4,
    1: 1,
    0: 3 / 2,
  };

  /// Plays back the music written on the staff
  Future<void> playBack() async {
    for (Note note in score.getAllNotes()) {
      String noteName = note.getNoteName();
      int octave = note.octave;
      int duration = note.duration;
      int accidental = note.accidental; // not implemented yet
    }
    // https://www.fluttercampus.com/guide/221/play-soud-from-assets-folder-flutter/
    String a0Location = 'assets/audio/Piano.ff.A0.flac';
    ByteData bytes = await rootBundle.load(a0Location);
    Uint8List soundbytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    final audioSource = await player
        .setAudioSource(AudioSource.uri(Uri.dataFromBytes(soundbytes)));
    await player.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Play your music"),
      ),
      body: Center(
        // child: ElevatedButton(
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        //   child: const Text("Back to writing"),
        // ),
        child: Column(children: <Widget>[
          IconButton(
            onPressed: () {
              playBack();
            },
            icon: const Icon(Icons.play_arrow),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Back to writing"),
          ),
        ]),
      ),
    );
  }
}
