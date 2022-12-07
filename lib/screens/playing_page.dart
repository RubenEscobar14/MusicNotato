import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_notato/helper.dart';
import 'package:music_notato/models/note.dart';
import 'package:music_notato/models/score.dart';
import 'package:music_notato/screens/home_page.dart';

/// Class responsible for playing back the music written on the staff
class PlayingPage extends StatelessWidget {
  // This homePage variable could be worth deleting
  late HomePage homePage;
  late Score score;
  late int tempo;
  late int signature_;
  late Map<String, Uint8List> audioFiles;
  ConcatenatingAudioSource playlist = ConcatenatingAudioSource(children: []);

  final player = AudioPlayer();

  PlayingPage(this.homePage) {
    score = homePage.getScore();
    tempo = homePage.getTempo();
    signature_ = homePage.getSignature_();
    audioFiles = homePage.getAudio();
    renderAudio();
  }

  void renderAudio() async {
    for (Note note in score.getAllNotes()) {
      if (note.getNoteName() == "R") {
        playlist.add(bytesToData(note.getNoteName(), 0.5));
      } else {
        String noteData = "${note.getNoteName()}${note.getOctave()}";
        playlist.add(bytesToData(noteData, 0.5));
      }
    }
    await player.setAudioSource(playlist);
  }

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
    await player.load();
    await player.play();
    player.dispose();
  }

  /// Returns an AudioSource of length seconds corresponding to the given note.
  ClippingAudioSource bytesToData(String note, double length) {
    return ClippingAudioSource(
        child: AudioSource.uri(Uri.dataFromBytes(audioFiles[note]!)),
        end: Duration(milliseconds: (length * 1000).floor()));
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
