import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music_notato/models/note.dart';
import 'package:music_notato/models/score.dart';
import 'package:music_notato/screens/home_page.dart';

class PlayingPage extends StatelessWidget {
  Score score = HomePage().getScore();
  int tempo = HomePage().getTempo();
  int signature_ = HomePage().getSignature_();

  final player = AudioPlayer();

  Map<int, double> durationRatios = {
    32: 1/32,
    48: 3/64,
    16: 1/16,
    24: 3/32,
    8: 1/8,
    12: 3/16,
    4: 1/4,
    6: 3/8,
    2: 1/2,
    3: 3/4,
    1: 1,
  };

  void playBack() {
    for(Note note in score.getAllNotes()) {
      String noteName = note.getNoteName();
      int octave = note.octave;
      int duration = note.duration;
      int accidental = note.accidental; // not implemented yet

      player.play(AssetSource('audio/Piano.ff.$noteName$octave.aiff'), position: const Duration(seconds: 1));
    }
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
        child: Column(
          children: <Widget>[
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