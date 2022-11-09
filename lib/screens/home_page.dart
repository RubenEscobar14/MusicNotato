import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music_notato/graphics.dart';
import 'package:music_notato/main.dart';
import 'package:music_notato/models/note.dart';
import 'package:music_notato/models/score.dart';
import 'package:music_notato/screens/playing_page.dart';
import 'package:music_notato/screens/save_page.dart';
import 'package:music_notato/widgets/note_duration_button.dart';
import 'package:provider/provider.dart';

class HomePage extends State<MyHomePage> {
  Score _score = Score();

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
  int _tempo = 100;

  var items = ['4/4', '3/4', '2/4', '2/2'];

  int signature = 4;
  int signature_ = 4;

  final player = AudioPlayer();
  int currentFile = 1;

  Score getScore() {
    return _score;
  }

  int getTempo() {
    return _tempo;
  }

  int getSignature_() {
    return signature_;
  }

  /// Loads a save on startup
  @override
  void initState() {
    super.initState();
    loadSave();
  }

  /// Loads notes by reading the notato data file (if found) that corresponds to
  /// currentFile, and mapping each property to a "new" note, which is then
  /// added to the staff.
  void loadSave() {
    widget.storage.readFile(currentFile).then((value) {
      setState(() {
        for (dynamic fakeNote in value) {
          Note note = Note(
              NoteLetter.values.byName(fakeNote['note']),
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

  /// Removes every note from the staff and everything that's not a file.
  void clearNotes() {
    noteList = [];
    xPosition = 40;
    notePosition = [];
  }

  /// Switches the file and loads information from the new one. Intended to be
  /// called when loading a save from the save page.
  void onLoad(int currentSave) {
    currentFile = currentSave;
    clearNotes();
    loadSave();
  }

  /// Adds a note to the staff and list of notes. Will automatically re-save to
  /// the json file by default, but saveOnAdd can be set to false to not do this.
  void _addNote(Note currentNote, {bool saveOnAdd = true}) {
    setState(() {
      if (currentNote.complete <= signature / signature_) {
        noteList.add(currentNote);
        notePosition.add(xPosition);
        xPosition += 40;
        _score.getAllNotes().add(currentNote);
        if (saveOnAdd) {
          widget.storage.writeFile(_score.getAllNotes(), currentFile);
        }
      }
      if (currentNote.complete == signature / signature_) {
        xPosition += 20;
      }
      _printNoteInfo();
    });
  }

  // Deletes the last note in the list
  void _deleteNote() {
    noteList.remove(noteList[noteList.length - 1]);
    xPosition = notePosition[notePosition.length - 1];
    notePosition.remove(notePosition[notePosition.length - 1]);
    print("delete call finished");
  }

  // Returns the last note in the current notelist
  Note _getLastNote() {
    return noteList[noteList.length - 1];
  }

  //returns a note n steps higher than entered
  NoteLetter _increasePitch(int n, NoteLetter note) {
    return NoteLetter.values[(note.index + n) % 7];
  }

  Note nextNoteWithNewDuration(int duration) {
    Note lastNote = _getLastNote();
    Note newNote = new Note(lastNote.getNote(), lastNote.getOctave(), duration,
        lastNote.getDotted(), lastNote.getAccidental(), return_complete());
    return newNote;
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

  void _handleDurationChanged() {
    setState(() {
      // ignore: unnecessary_this
      this.duration = duration;
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
          Consumer<Shouter>(builder: (context, value, child) {
            onLoad(value.saveToShout);
            return;
          }),
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
            /////////////////// All the buttons ///////////////////
            ElevatedButton(
              onPressed: () {
                player.play(AssetSource('audio/Piano.ff.C$octave.aiff'),
                    position: const Duration(seconds: 1));
                _addNote(Note(NoteLetter.c, octave, duration, dotted,
                    accidental, return_complete()));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('C'),
            ),
            ElevatedButton(
              onPressed: () {
                player.play(AssetSource('audio/Piano.ff.D$octave.aiff'),
                    position: const Duration(seconds: 1));
                _addNote(Note(NoteLetter.d, octave, duration, dotted,
                    accidental, return_complete()));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('D'),
            ),
            ElevatedButton(
              onPressed: () {
                player.play(AssetSource('audio/Piano.ff.E$octave.aiff'),
                    position: const Duration(seconds: 1));
                _addNote(Note(NoteLetter.e, octave, duration, dotted,
                    accidental, return_complete()));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('E'),
            ),
            ElevatedButton(
              onPressed: () {
                player.play(AssetSource('audio/Piano.ff.F$octave.aiff'),
                    position: const Duration(seconds: 1));
                _addNote(Note(NoteLetter.f, octave, duration, dotted,
                    accidental, return_complete()));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('F'),
            ),
            ElevatedButton(
              onPressed: () {
                player.play(AssetSource('audio/Piano.ff.G$octave.aiff'),
                    position: const Duration(seconds: 1));
                _addNote(Note(NoteLetter.g, octave, duration, dotted,
                    accidental, return_complete()));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('G'),
            ),
            ElevatedButton(
              onPressed: () {
                player.play(AssetSource('audio/Piano.ff.A$octave.aiff'),
                    position: const Duration(seconds: 1));
                _addNote(Note(NoteLetter.a, octave, duration, dotted,
                    accidental, return_complete()));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('A'),
            ),
            ElevatedButton(
              onPressed: () {
                player.play(AssetSource('audio/Piano.ff.B$octave.aiff'),
                    position: const Duration(seconds: 1));
                _addNote(Note(NoteLetter.b, octave, duration, dotted,
                    accidental, return_complete()));
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
                NoteLetter newPitch = _increasePitch(1, previous.getNote());
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
                print("moving down");
                Note previous = _getLastNote();
                _deleteNote();
                // _increasePitch() uses mod, so increasing by  is the same as decreasing by 1
                NoteLetter newPitch = _increasePitch(6, previous.getNote());
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
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (octave + 1 <= 8) {
                      octave++;
                    }
                  });
                },
                child: const Text('Octave Up')),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (octave - 1 >= 0) {
                      octave--;
                    }
                  });
                },
                child: const Text('Octave Down')),
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
            // NoteDurationButton(duration: 32, buttonText: 'Thirtysecond', isSelected: false, onDurationChanged: _handleDurationChanged()),
            // NoteDurationButton(duration: 16, buttonText: 'Sixteenth', isSelected: false, onDurationChanged: _handleDurationChanged()),
            // NoteDurationButton(duration: 8, buttonText: 'Eigth', isSelected: false, onDurationChanged: _handleDurationChanged()),
            // NoteDurationButton(duration: 4, buttonText: 'Quarter', isSelected: false, onDurationChanged: _handleDurationChanged()),
            // NoteDurationButton(duration: 2, buttonText: 'Half', isSelected: false, onDurationChanged: _handleDurationChanged()),
            // NoteDurationButton(duration: 1, buttonText: 'Whole', isSelected: false, onDurationChanged: _handleDurationChanged()),
            ElevatedButton(
              onPressed: () {
                if (dotted == 1) {
                  duration = 48;
                  _addNote(nextNoteWithNewDuration(48));
                } else {
                  duration = 32;
                  _addNote(nextNoteWithNewDuration(32));
                }
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('Thirtysecond'),
            ),
            ElevatedButton(
              onPressed: () {
                if (dotted == 1) {
                  duration = 24;
                  _addNote(nextNoteWithNewDuration(24));
                } else {
                  duration = 16;
                  _addNote(nextNoteWithNewDuration(16));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              child: const Text('Sixteenth'),
            ),
            ElevatedButton(
              onPressed: () {
                if (dotted == 1) {
                  duration = 12;
                  _addNote(nextNoteWithNewDuration(12));
                } else {
                  duration = 8;
                  _addNote(nextNoteWithNewDuration(8));
                }
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('Eighth'),
            ),
            ElevatedButton(
              onPressed: () {
                if (dotted == 1) {
                  duration = 6;
                  _addNote(nextNoteWithNewDuration(6));
                } else {
                  duration = 4;
                  _addNote(nextNoteWithNewDuration(4));
                }
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('Quarter'),
            ),
            ElevatedButton(
              onPressed: () {
                if (dotted == 1) {
                  duration = 3;
                  _addNote(nextNoteWithNewDuration(3));
                } else {
                  duration = 2;
                  _addNote(nextNoteWithNewDuration(2));
                }
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('Half'),
            ),
            ElevatedButton(
              onPressed: () {
                if (dotted == 1) {
                  duration = 0;
                  _addNote(nextNoteWithNewDuration(0));
                } else {
                  duration = 1;
                  _addNote(nextNoteWithNewDuration(1));
                }
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('Whole'),
            ),
            ElevatedButton(
              onPressed: () {
                if (dotted == 0) {
                  // toggle between dotted and not-dotted
                  dotted = 1;
                  if (duration == 1) {
                    duration = 0;
                  } else {
                    duration = (duration * 1.5).round();
                  }
                } else {
                  dotted = 0;
                  if (duration == 0) {
                    duration = 1;
                  } else {
                    duration = (duration / 1.5).round();
                  }
                }
                print(duration);
                print(dotted);
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: const Text('.'),
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
            MaterialPageRoute(builder: (context) => SavePage()),
          );
        },
        tooltip: 'Go to playing page',
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
