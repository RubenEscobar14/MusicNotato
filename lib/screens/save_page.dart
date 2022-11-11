import 'package:flutter/material.dart';
import 'package:music_notato/Save.dart';
import 'package:music_notato/models/note.dart';
import 'package:music_notato/models/score.dart';
import 'package:music_notato/screens/home_page.dart';

/// A page for selecting a save file and opening it in a HomePage
class SavePage extends StatelessWidget {
  Score score = HomePage().getScore();
  int tempo = HomePage().getTempo();
  int signature_ = HomePage().getSignature_();
  Save save = Save();

  /// Main graphics - contains the top bar and a list of buttons that each
  /// correspond to a save
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Save or load a composition"),
      ),
      body: Center(
        child: Column(children: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.indigoAccent)),
            child: const Text('Save 1'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.indigoAccent)),
            child: const Text('Save 2'),
          ),
        ]),
      ),
    );
  }
}
