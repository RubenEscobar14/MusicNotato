import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_notato/models/note.dart';
import 'package:music_notato/screens/home_page.dart';
import 'save.dart';

// Music Library: https://theremin.music.uiowa.edu/MISpiano.html
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //https://mightytechno.com/screen-orientation-in-flutter/
  // Sets screen to be sideways on mobile
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(const MyApp());
  });
}

Save save = Save();
List<Note> _allNotes = List.empty(growable: true);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Notato',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Music Notato', storage: Save()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.storage});
  final Save storage;
  final String title;

  @override
  State<MyHomePage> createState() => HomePage();
}