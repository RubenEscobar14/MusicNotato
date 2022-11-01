import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music_notato/screens/home_page.dart';

class PlayingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Play your music"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            
          },
          child: const Text("Back to writing"),
        ),
      ),
    );
  }
}