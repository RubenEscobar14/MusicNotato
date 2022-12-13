import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
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
  Map<String, Uint8List> audioFiles = <String, Uint8List>{};
  ConcatenatingAudioSource playlist = ConcatenatingAudioSource(children: []);

  late AudioPlayer player;

  PlayingPage(this.homePage) {
    score = homePage.score;
    tempo = homePage.tempo;
    signature_ = homePage.signatureBottom;
    audioFiles = homePage.audio;
    renderAudio();
  }

  void renderAudio() async {
    // No point in trying to add loaded data if the data's not loaded
    if (audioFiles.isEmpty) return;
    for (Note note in score.allNotes) {
      double duration = calculateDuration(note.duration, dotted: note.dotted);
      if (note.getNoteName() == "R") {
        playlist.add(bytesToData(note.getNoteName(), duration));
      } else {
        String noteData = "${note.getNoteName()}${note.octave}";
        playlist.add(bytesToData(noteData, duration));
      }
    }
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

  /// Calculates the length in seconds that a note should play given the tempo
  /// (theoretically - tempo is not yet a feature) and duration. Dotted is currently
  /// unused, as duration contains all the duration information, so it can be passed
  /// in with or without dotted.
  double calculateDuration(int noteDuration, {int dotted = 0}) {
    // Two quarter notes per second. This'll use math so that tempo can be easy to change
    double bpm = 120;
    //https://flutterigniter.com/checking-null-aware-operators-dart/
    // If there's no matching value in durationRatios, use 1/4 instead (as if
    // there's a quarter note)
    double ratio = durationRatios[noteDuration] ??= 1 / 4;
    return (bpm * ratio) / 60;
  }

  /// Plays back the music written on the staff
  Future<void> playBack() async {
    // Try fetching the audio again if this page was loaded before the audio files
    if (audioFiles.isEmpty) {
      audioFiles = homePage.audio;
      renderAudio();
    }
    player = AudioPlayer();
    await player.setAudioSource(playlist);
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
