import 'package:flutter/material.dart';
import 'package:music_notato/save.dart';
import 'package:music_notato/models/score.dart';
import 'package:music_notato/screens/home_page.dart';

/// A page for selecting a save file and opening it in a HomePage
class SavePage extends StatelessWidget {
  HomePage homePage;
  late Score score;
  late int tempo;
  late int signature_;
  Save save = Save();

  SavePage(this.homePage) {
    score = homePage.score;
    tempo = homePage.tempo;
    signature_ = homePage.signatureBottom;
  }

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
              homePage.onLoad(1);
            },
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.indigoAccent)),
            child: const Text('Save 1'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              homePage.onLoad(2);
            },
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.indigoAccent)),
            child: const Text('Save 2'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              homePage.onLoad(3);
            },
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.indigoAccent)),
            child: const Text('Save 3'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              homePage.onLoad(4);
            },
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.indigoAccent)),
            child: const Text('Save 4'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              homePage.onLoad(5);
            },
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.indigoAccent)),
            child: const Text('Save 5'),
          ),
        ]),
      ),
    );
  }
}
