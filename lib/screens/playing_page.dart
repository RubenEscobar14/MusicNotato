import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../main.dart';

class playingPage extends StatelessWidget {
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