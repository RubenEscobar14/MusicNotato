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

  SavePage(this.homePage, {super.key}) {
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
          for(int i = 1; i < 6; i++) 
            Column(children: <Widget> [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  homePage.onLoad(1);
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.indigoAccent)),
                child: Text('Save $i'),
              ),
            ]
          ),
        ]),
      ),
    );
  }
}
