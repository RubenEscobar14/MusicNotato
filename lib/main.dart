import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'graphics.dart';
import 'note.dart';
import 'playing_page.dart';
import 'save.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //https://mightytechno.com/screen-orientation-in-flutter/
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(const MyApp());
  });
}

Save save = Save();
List<Note> _allNotes = save.getAllNotes();

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
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Note? currentNote;
  String currentNoteString = '';
  String noteName = '';
  double xPosition = 20;
  List<Note> noteList = [];
  List<double> notePosition = [];

  int duration = 0;
  int octave = 4;
  int dotted = 0;
  int accidental =
      0; // not implemented yet (when it is implemented, will also have to implement keys)

  String currentClef = 'treble';

  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    widget.storage.readFile().then((value) {
      setState(() {
        for (dynamic fakeNote in value) {
          Note note = Note(fakeNote['note'], fakeNote['octave'],
              fakeNote['duration'], fakeNote['dotted'], fakeNote['accidental']);
          _addNote(note, saveOnAdd: false);
        }
      });
    });
  }

  void _addNote(Note currentNote, {bool saveOnAdd = true}) {
    setState(() {
      noteList.add(currentNote);
      notePosition.add(xPosition);
      xPosition += 40;
      _allNotes.add(currentNote);
      if (saveOnAdd) {
        save.writeFile(_allNotes);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Row(
        children: <Widget>[
          Column(children: <Widget>[
            ElevatedButton(
              onPressed: () {
                player.play(AssetSource('audio/c.wav'));
                _addNote(Note('c', octave, duration, dotted, accidental));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('C'),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     player.play(AssetSource('audio/cs.wav'));
            //     _addNote(Note('c', 4, 4, 0, 1));
            //   },
            //   style: ButtonStyle(
            //       backgroundColor: MaterialStateProperty.all(Colors.black)),
            //   child: const Text('C#/Db'),
            // ),
            ElevatedButton(
              onPressed: () {
                player.play(AssetSource('audio/d.wav'));
                _addNote(Note('d', octave, duration, dotted, accidental));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('D'),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     player.play(AssetSource('audio/ds.wav'));
            //     _addNote(Note('d', 4, 4, 0, 1));
            //   },
            //   style: ButtonStyle(
            //       backgroundColor: MaterialStateProperty.all(Colors.black)),
            //   child: const Text('D#/Eb'),
            // ),
            ElevatedButton(
              onPressed: () {
                player.play(AssetSource('audio/e.wav'));
                _addNote(Note('e', octave, duration, dotted, accidental));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('E'),
            ),
            ElevatedButton(
              onPressed: () {
                player.play(AssetSource('audio/f.wav'));
                _addNote(Note('f', octave, duration, dotted, accidental));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('F'),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     player.play(AssetSource('audio/fs.wav'));
            //     _addNote(Note('f', 4, 4, 0, 1));
            //   },
            //   style: ButtonStyle(
            //       backgroundColor: MaterialStateProperty.all(Colors.black)),
            //   child: const Text('F#/Gb'),
            // ),
            ElevatedButton(
              onPressed: () {
                player.play(AssetSource('audio/g.wav'));
                _addNote(Note('g', octave, duration, dotted, accidental));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('G'),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     player.play(AssetSource('audio/gs.wav'));
            //     _addNote(Note('g', 4, 4, 0, 1));
            //   },
            //   style: ButtonStyle(
            //       backgroundColor: MaterialStateProperty.all(Colors.black)),
            //   child: const Text('G#/Ab'),
            // ),
            ElevatedButton(
              onPressed: () {
                player.play(AssetSource('audio/a.wav'));
                _addNote(Note('a', octave, duration, dotted, accidental));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('A'),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     player.play(AssetSource('audio/as.wav'));
            //     _addNote(Note('a', 4, 4, 0, 1));
            //   },
            //   style: ButtonStyle(
            //       backgroundColor: MaterialStateProperty.all(Colors.black)),
            //   child: const Text('A#/Bb'),
            // ),
            ElevatedButton(
              onPressed: () {
                player.play(AssetSource('audio/b.wav'));
                _addNote(Note('b', octave, duration, dotted, accidental));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('B'),
            ),
          ]),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CustomPaint(
                  size: const Size(1000, 50),
                  // size: Size(context.size!.width, context.size!.height), // does not work; compile error
                  painter:
                      Graphics(xPosition, noteList, notePosition, 'treble'),
                ),
              ],
            ),
          ),
          Column(children: <Widget>[
            ElevatedButton(
              onPressed: () {
                duration = 32;
                // print(duration);
              },
              style: ButtonStyle(
                // backgroundColor: MaterialStateProperty.all(Colors.black)),
                // disabledForegroundColor: Colors.red,
                // backgroundColor: MaterialStateProperty.all(Colors.red),
                // overlayColor: MaterialStateProperty.resolveWith<Color?>(
                //   (Set<MaterialState> states) {
                //     if(states.contains(MaterialState.selected))
                //       return Colors.blue;
                //     return null;
                //   },
                // ),
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.green;
                  }
                  return Colors.blue;
                }),
                // disabledBackgroundColor: Colors.green,
              ),
              // style: ElevatedButton.styleFrom(
              //   // backgroundColor: Colors.black,
              //   disabledBackgroundColor: Colors.red,
              //   disabledForegroundColor: Colors.green,
              // ),
              child: const Text('Thirtysecond'),
            ),
            ElevatedButton(
              onPressed: () {
                duration = 16;
                // print(duration);
                setState(() {
                  if (duration == 16) {
                    ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    );
                  }
                  ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                // backgroundColor: MaterialStateProperty.all(Colors.green)),
                backgroundColor: Colors.red,
                // disabledForegroundColor: Colors.green,
              ),
              child: const Text('Sixteenth'),
            ),
            ElevatedButton(
              onPressed: () {
                duration = 8;
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('Eighth'),
            ),
            ElevatedButton(
              onPressed: () {
                duration = 4;
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('Quarter'),
            ),
            ElevatedButton(
              onPressed: () {
                duration = 2;
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('Half'),
            ),
            ElevatedButton(
              onPressed: () {
                duration = 1;
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('Whole'),
            ),
          ]),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
            side: BorderSide(color: Color.fromARGB(255, 124, 24, 157))),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => playingPage()),
          );
        },
        tooltip: 'Go to playing page',
        child: const Icon(Icons.arrow_forward),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}