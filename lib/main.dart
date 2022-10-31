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
  double xPosition = 40;
  List<Note> noteList = [];
  List<double> notePosition = [];

  final List<String> noteNames = ['a', 'b', 'c', 'd', 'e', 'f', 'g'];

  int duration = 4;
  int octave = 4;
  int dotted = 0;
  int accidental =
      0; // not implemented yet (when it is implemented, will also have to implement keys)

  String currentClef = 'treble';
  String dropdownvalue = '4/4';
  double tempo = 100;

  var items = ['4/4', '3/4', '2/4', '2/2'];

  double signature = 4;
  double signature_ = 4;

  final player = AudioPlayer();

  /// Loads notes by reading the notato data file (if found) and mapping each
  /// property to a "new" note, which is then added to the staff.
  @override
  void initState() {
    super.initState();
    widget.storage.readFile().then((value) {
      setState(() {
        for (dynamic fakeNote in value) {
          Note note = Note(
              fakeNote['note'],
              fakeNote['octave'],
              fakeNote['duration'],
              fakeNote['dotted'],
              fakeNote['accidental'],
              fakeNote['complete']);
          _addNote(note, saveOnAdd: false);
        }
      });
    });
  }

  void _addNote(Note currentNote, {bool saveOnAdd = true}) {
    setState(() {
      // if(currentNote.complete <= signature / signature_) {
      noteList.add(currentNote);
      notePosition.add(xPosition);
      xPosition += 40;
      _allNotes.add(currentNote);
      if (saveOnAdd) {
        save.writeFile(_allNotes);
      }
      // }
      if (currentNote.complete == signature / signature_) {
        xPosition += 20;
      }
    });
  }

  // Deletes the last note in the list
  void _deleteNote() {
    _printNoteInfo();
    noteList.remove(noteList[noteList.length - 1]);
    xPosition = notePosition[notePosition.length - 1];
    notePosition.remove(notePosition[notePosition.length - 1]);
    _printNoteInfo();
    print("delete call finished");
  }

  // Returns the last note in the current notelist
  Note _getLastNote() {
    return noteList[noteList.length - 1];
  }

  //returns a note n steps higher than
  String _increasePitch(int n, String note) {
    int prev = noteNames.indexOf(note);
    return noteNames[(prev + n) % 7];
  }

  //prints current noteList and notePosition, debugging use only
  void _printNoteInfo() {
    print(noteList);
    print(notePosition);
  }

  double return_complete() {
    double duration_ = 1 / duration;
    double complete = 0;
    if (noteList.isEmpty) {
      complete = duration_;
    } else {
      if (noteList[noteList.length - 1].complete == signature / signature_) {
        complete = duration_;
      } else {
        complete = duration_ + noteList[noteList.length - 1].complete;
      }
    }
    return complete;
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
            // Listener(
            //   child: CustomPaint(
            //     size: const Size(1000, 50),
            //     // size: Size(context.size!.width, context.size!.height), // does not work; compile error
            //     painter: Graphics(xPosition, noteList, notePosition, 'treble',
            //         signature, signature_),
            //   ),
            //   onPointerDown: (event) => {
            //     // when raised button is pressed
            //     // we display showModalBottomSheet
            //     showModalBottomSheet<void>(
            //       // context and builder are
            //       // required properties in this widget
            //       context: context,
            //       builder: (BuildContext context) {
            //         return StatefulBuilder(builder: (context1, state) {
            //           //这里的state就是setState

            //           // Returning SizedBox
            //           return SizedBox(
            //             height: 200,
            //             child: Center(
            //               child: Column(
            //                 mainAxisAlignment: MainAxisAlignment.center,
            //                 children: <Widget>[
            //                   DropdownButton(
            //                     // Initial Value
            //                     value: dropdownvalue,

            //                     // Down Arrow Icon
            //                     icon: Icon(Icons.keyboard_arrow_down),

            //                     // Array list of items
            //                     items: items.map((String items) {
            //                       return DropdownMenuItem(
            //                         value: items,
            //                         child: Text(items),
            //                       );
            //                     }).toList(),
            //                     // After selecting the desired option,it will
            //                     // change button value to selected value
            //                     onChanged: (String? newValue) {
            //                       if (noteList.isEmpty) {
            //                         state(() {
            //                           dropdownvalue = newValue!;
            //                           var str_li = dropdownvalue.split('/');
            //                           print(str_li);
            //                           setState(() {
            //                             signature = double.parse(str_li[0]);
            //                             signature_ = double.parse(str_li[1]);
            //                           });
            //                         });
            //                       }
            //                     },
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           );
            //         });
            //       },
            //     )
            //   },
            // ),
            ElevatedButton(
              onPressed: () {
                player.play(AssetSource('audio/c.wav'));
                _addNote(Note('c', octave, duration, dotted, accidental,
                    return_complete()));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('C'),
            ),
            ElevatedButton(
              onPressed: () {
                player.play(AssetSource('audio/d.wav'));
                _addNote(Note('d', octave, duration, dotted, accidental,
                    return_complete()));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('D'),
            ),
            ElevatedButton(
              onPressed: () {
                player.play(AssetSource('audio/e.wav'));
                _addNote(Note('e', octave, duration, dotted, accidental,
                    return_complete()));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('E'),
            ),
            ElevatedButton(
              onPressed: () {
                player.play(AssetSource('audio/f.wav'));
                _addNote(Note('f', octave, duration, dotted, accidental,
                    return_complete()));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('F'),
            ),
            ElevatedButton(
              onPressed: () {
                player.play(AssetSource('audio/g.wav'));
                _addNote(Note('g', octave, duration, dotted, accidental,
                    return_complete()));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('G'),
            ),
            ElevatedButton(
              onPressed: () {
                player.play(AssetSource('audio/a.wav'));
                _addNote(Note('a', octave, duration, dotted, accidental,
                    return_complete()));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('A'),
            ),
            ElevatedButton(
              onPressed: () {
                player.play(AssetSource('audio/b.wav'));
                _addNote(Note('b', octave, duration, dotted, accidental,
                    return_complete()));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('B'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteNote();
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('Delete'),
            ),
            ElevatedButton(
              onPressed: () {
                Note previous = _getLastNote();
                _deleteNote();
                String newPitch = _increasePitch(1, previous.getNote());
                _addNote(Note(
                    newPitch,
                    previous.getOctave(),
                    previous.getDuration(),
                    previous.getDotted(),
                    previous.getAccidental(),
                    return_complete()));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('Up'),
            ),
            ElevatedButton(
              onPressed: () {
                Note previous = _getLastNote();
                _deleteNote();
                // _increasePitch() uses mod, so increasing by 7 is the same as decreasing by 1
                String newPitch = _increasePitch(6, previous.getNote());
                _addNote(Note(
                    newPitch,
                    previous.getOctave(),
                    previous.getDuration(),
                    previous.getDotted(),
                    previous.getAccidental(),
                    return_complete()));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('Down'),
            ),
          ]),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CustomPaint(
                  size: const Size(1000, 50),
                  // size: Size(context.size!.width, context.size!.height), // does not work; compile error
                  painter: Graphics(xPosition, noteList, notePosition, 'treble',
                      signature, signature_),
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
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.green;
                  }
                  return Colors.blue;
                }),
              ),
              child: const Text('Thirtysecond'),
            ),
            ElevatedButton(
              onPressed: () {
                duration = 16;
                setState(() {
                  if (duration == 16) {
                    ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    );
                  }
                  ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
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
