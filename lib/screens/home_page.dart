import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:music_notato/main.dart';
import 'package:music_notato/models/note.dart';
import 'package:music_notato/models/score.dart';
import 'package:music_notato/screens/playing_page.dart';
import 'package:music_notato/screens/save_page.dart';
import 'package:music_notato/widgets/music_painter_widget.dart';
// import 'package:music_notato/widgets/note_duration_button.dart';
import 'package:music_notato/widgets/note_widget.dart';
import 'package:music_notato/widgets/staff_widget.dart';
import 'package:music_notato/widgets/select_note_widget.dart';

/// The main page of the app
class HomePage extends State<MyHomePage> {
  Score _score = Score(); // current score

  double xPosition = 60; // starting x-coordinate for notes
  List<double> xPositions = []; // list of x-coordinates for the notes
  int selectedNoteIndex = -1; // currently selected note
  double tappedPositionX = -1;
  double tappedPositionY = -1;

  final List<String> noteNames = ['a', 'b', 'c', 'd', 'e', 'f', 'g'];

  String note = 'A';
  int duration = 4; // default length of a note
  int octave = 4; // default octave of a note
  int dotted = 0; // default set to not dotted
  int accidental =
      0; // not implemented yet (when it is implemented, will also have to implement keys)

  String currentClef = 'treble'; // default clef
  String dropdownvalue = '4/4'; // default time signature
  int _tempo = 100; // default tempo

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

  var timeSignatures = [
    '4/4',
    '3/4',
    '2/4',
    '2/2'
  ]; // list of available time signatures

  int timeSignatureTop = 4; // default number of beats in a measure
  int timeSignatureBottom = 4; // default beat unit
  double noteLength = 0;

  bool isRest = false;

  final player = AudioPlayer();
  int currentFile = 1;

  Score getScore() {
    return _score;
  }

  int getTempo() {
    return _tempo;
  }

  int getSignature_() {
    return timeSignatureBottom;
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
    _score.clearScore();
    xPosition = 40;
    xPositions = [];
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
      if (currentNote.measureProgress <=
          timeSignatureTop / timeSignatureBottom) {
        xPositions.add(xPosition);
        xPosition += 40;
        _score.getAllNotes().add(currentNote);
        note = currentNote.getNoteName()[11];
        if (saveOnAdd) {
          widget.storage.writeFile(_score.getAllNotes(), currentFile);
        }
      }
      if (currentNote.measureProgress ==
          timeSignatureTop / timeSignatureBottom) {
        xPosition += 10;
      }
    });
  }

  // Like the addnote() function, but adds the note at a specified index instead of the end of the list
  void _addNoteAt(Note currentNote, int position, {bool saveOnAdd = true}) {
    setState(() {
      if (currentNote.measureProgress <=
          timeSignatureTop / timeSignatureBottom) {
        xPositions.add(xPosition);
        xPosition += 40;
        _score.getAllNotes().insert(position, currentNote);
        if (saveOnAdd) {
          widget.storage.writeFile(_score.getAllNotes(), currentFile);
        }
      }
      if (currentNote.measureProgress ==
          timeSignatureTop / timeSignatureBottom) {
        xPosition += 20;
      }
    });
  }

  /// Deletes the last note in the score
  Note _deleteNote() {
    if (!_score.isEmpty) {
      Note toRemove = _score.getLastNote();
      _score.removeLastNote();
      xPosition = xPositions[xPositions.length - 1];
      xPositions.remove(xPositions[xPositions.length - 1]);
      return toRemove;
    }
    return Note(NoteLetter.a, 4, 4, 0, 0, 0);
  }

  //deletes the note at the specified positon from the score
  Note _deleteNoteAt(int index) {
    Note toRemove = _score.getNote(index);
    _score.removeNoteAt(index);
    xPosition = xPositions[xPositions.length - 1];
    xPositions.remove(xPositions[xPositions.length - 1]);
    return toRemove;
  }

  /// Returns the last note in the current notelist
  Note _getLastNote() {
    if (_score.getAllNotes().isEmpty) {
      return Note(NoteLetter.a, 4, 4, 0, 0, returnMeasureProgress());
    }
    return _score.getLastNote();
  }

  /// Returns a note with the same characteristics as the previous note but with the given duration
  Note nextNoteWithNewDuration(int duration) {
    Note lastNote = _getLastNote();
    if (isRest) {
      return Note.rest(duration, dotted, returnMeasureProgress());
    }
    return Note(
        lastNote.getNote() == NoteLetter.r ? NoteLetter.a : lastNote.getNote(),
        lastNote.getOctave(),
        duration,
        dotted,
        lastNote.getAccidental(),
        returnMeasureProgress());
  }

  /// Prints the current noteList and xPositions, debugging use only
  void _printNoteInfo() {
    print(_score.getAllNotes());
    print(xPositions);
  }

  /// Returns the fraction of the measure that has been completed
  double returnMeasureProgress() {
    try {
      noteLength = durationRatios[duration]!.toDouble(); // percentage of
      if (duration == 0) {
        noteLength = 3 / 2;
      }
    } catch (e) {
      noteLength = 4;
    }
    double measureProgress = 0;
    if (_score.isEmpty) {
      measureProgress = noteLength;
    } else {
      if (_score.getLastNote().measureProgress ==
          timeSignatureTop / timeSignatureBottom) {
        measureProgress = noteLength;
      } else {
        measureProgress = noteLength + _score.getLastNote().measureProgress;
      }
    }
    return measureProgress;
  }

  //updates the currently selected note to the nearest note to the input coordinates
  void selectNewNote(double x) {
    double min = 1000;
    int minIndex = -1;
    for (int i = 0; i < xPositions.length; i++) {
      if (distance(xPositions[i], x) < min) {
        minIndex = i;
        min = distance(xPositions[i], x);
      }
    }
    print("Nearest Note Index is: $minIndex");
    setState(() {
      selectedNoteIndex = minIndex;
    });
  }

  //returns the distance between two points in 1 dimension
  double distance(double x, double y) {
    double dist = x - y;
    if (dist < 0) {
      return dist * -1;
    } else {
      return dist;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 70.w,
              child: Column(children: <Widget>[
                /////////////////// All the buttons ///////////////////
                ElevatedButton(
                  // delete button
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red)),
                  onPressed: () {
                    setState(() {
                      _deleteNote();
                      if (!_score.isEmpty) {
                        _addNote(_deleteNote());
                      }
                      selectedNoteIndex = _score.length - 1;
                    });
                  },
                  child: const Icon(Icons.delete),
                ),
                DropdownButton(
                  // Initial Value
                  value: dropdownvalue,
                  // Down Arrow Icon
                  icon: Icon(Icons.keyboard_arrow_down),
                  // Array list of items
                  items: timeSignatures.map((String items) {
                    return DropdownMenuItem(
                      value: items,
                      child: Text(items),
                    );
                  }).toList(),
                  // After selecting the desired option,it will
                  // change button value to selected value
                  onChanged: (String? newValue) {
                    if (noteLength == 0) {
                      setState(() {
                        dropdownvalue = newValue!;
                        var str_li = dropdownvalue.split('/');
                        print(str_li);
                        setState(() {
                          timeSignatureTop = int.parse(str_li[0]);
                          timeSignatureBottom = int.parse(str_li[1]);
                        });
                      });
                    }
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                ),
                ElevatedButton(
                  // note up button
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.grey[400]),
                  ),
                  onPressed: () {
                    if (!isRest && !_score.isEmpty) {
                      Note previous = _deleteNoteAt(selectedNoteIndex);
                      previous.increasePitch(1);
                      if (previous.getNote() == NoteLetter.c) {
                        previous.setOctave(previous.getOctave() + 1);
                      }
                      _addNoteAt(previous, selectedNoteIndex);
                      note = previous.getNoteName()[11];
                    }
                  },
                  child: const Icon(Icons.arrow_drop_up),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 0),
                ),
                Text('Note: $note'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 0),
                ),
                ElevatedButton(
                  // note down button
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.grey[400]),
                  ),
                  onPressed: () {
                    if (!isRest && !_score.isEmpty) {
                      Note previous = _deleteNoteAt(selectedNoteIndex);
                      previous.increasePitch(6);
                      if (previous.getNote() == NoteLetter.b) {
                        previous.setOctave(previous.getOctave() - 1);
                      }
                      _addNoteAt(previous, selectedNoteIndex);
                      note = previous.getNoteName()[11];
                    }
                  },
                  child: const Icon(Icons.arrow_drop_down),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                ),
                ElevatedButton(
                    // octave up button
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blueGrey)),
                    onPressed: () {
                      if (!isRest && !_score.isEmpty) {
                        Note previous = _deleteNoteAt(selectedNoteIndex);
                        previous.setOctave(previous.getOctave() + 1);
                        _addNoteAt(previous, selectedNoteIndex);
                      }
                    },
                    child: const Icon(Icons.arrow_drop_up)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 0),
                ),
                Text('Octave: ${_score.getLastNote().octave}'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 0),
                ),
                ElevatedButton(
                    // octave down button
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blueGrey)),
                    onPressed: () {
                      if (!isRest && !_score.isEmpty) {
                        Note previous = _deleteNoteAt(selectedNoteIndex);
                        previous.setOctave(previous.getOctave() - 1);
                        _addNoteAt(previous, selectedNoteIndex);
                      }
                    },
                    child: const Icon(Icons.arrow_drop_down)),
              ]),
            ),
            Expanded(
                child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(top: 200.h, bottom: 165.h),
              child: MusicPainterWidget(
                  xPosition,
                  xPositions,
                  timeSignatureTop,
                  timeSignatureBottom,
                  _score,
                  selectedNoteIndex,
                  selectNewNote),
            )),
            SizedBox(
              width: 70.w,
              child: Column(children: <Widget>[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (dotted == 1) {
                      duration = 48;
                      _addNote(nextNoteWithNewDuration(48));
                    } else {
                      duration = 32;
                      _addNote(nextNoteWithNewDuration(32));
                    }
                    selectedNoteIndex = _score.length - 1;
                  },
                  style: ButtonStyle(
                      backgroundColor: dotted == 1
                          ? (_score.getLastNote().measureProgress + (3 / 64)) <=
                                  timeSignatureTop / timeSignatureBottom
                              ? MaterialStateProperty.all(Colors.indigo[400])
                              : MaterialStateProperty.all(Colors.indigo[200])
                          : (_score.getLastNote().measureProgress + (1 / 32)) <=
                                  timeSignatureTop / timeSignatureBottom
                              ? MaterialStateProperty.all(Colors.indigo[400])
                              : MaterialStateProperty.all(Colors.indigo[200])),
                  child: Image.asset('assets/images/32.png', width: 20, height: 20),
                  // child: Image.asset('images/32.png'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
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
                    selectedNoteIndex = _score.length - 1;
                  },
                  style: ButtonStyle(
                      backgroundColor: dotted == 1
                          ? (_score.getLastNote().measureProgress + (3 / 32)) <=
                                  timeSignatureTop / timeSignatureBottom
                              ? MaterialStateProperty.all(Colors.indigo[400])
                              : MaterialStateProperty.all(Colors.indigo[200])
                          : (_score.getLastNote().measureProgress + (1 / 16)) <=
                                  timeSignatureTop / timeSignatureBottom
                              ? MaterialStateProperty.all(Colors.indigo[400])
                              : MaterialStateProperty.all(Colors.indigo[200])),
                  child: Image.asset('assets/images/16.png', width: 20, height: 20),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
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
                    selectedNoteIndex = _score.length - 1;
                  },
                  style: ButtonStyle(
                      backgroundColor: dotted == 1
                          ? (_score.getLastNote().measureProgress + (3 / 16)) <=
                                  timeSignatureTop / timeSignatureBottom
                              ? MaterialStateProperty.all(Colors.indigo[400])
                              : MaterialStateProperty.all(Colors.indigo[200])
                          : (_score.getLastNote().measureProgress + (1 / 8)) <=
                                  timeSignatureTop / timeSignatureBottom
                              ? MaterialStateProperty.all(Colors.indigo[400])
                              : MaterialStateProperty.all(Colors.indigo[200])),
                  child: Image.asset('assets/images/8.png', width: 20, height: 20),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
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
                    selectedNoteIndex = _score.length - 1;
                  },
                  style: ButtonStyle(
                      backgroundColor: dotted == 1
                          ? (_score.getLastNote().measureProgress + (3 / 8)) <=
                                  timeSignatureTop / timeSignatureBottom
                              ? MaterialStateProperty.all(Colors.indigo[400])
                              : MaterialStateProperty.all(Colors.indigo[200])
                          : (_score.getLastNote().measureProgress + (1 / 4)) <=
                                  timeSignatureTop / timeSignatureBottom
                              ? MaterialStateProperty.all(Colors.indigo[400])
                              : MaterialStateProperty.all(Colors.indigo[200])),
                  child: Image.asset('assets/images/4.png', width: 20, height: 20),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
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
                    selectedNoteIndex = _score.length - 1;
                  },
                  style: ButtonStyle(
                      backgroundColor: dotted == 1
                          ? (_score.getLastNote().measureProgress + (3 / 4)) <=
                                  timeSignatureTop / timeSignatureBottom
                              ? MaterialStateProperty.all(Colors.indigo[400])
                              : MaterialStateProperty.all(Colors.indigo[200])
                          : (_score.getLastNote().measureProgress + (1 / 2)) <=
                                  timeSignatureTop / timeSignatureBottom
                              ? MaterialStateProperty.all(Colors.indigo[400])
                              : MaterialStateProperty.all(Colors.indigo[200])),
                  child: Image.asset('assets/images/2.png', width: 20, height: 20),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
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
                    selectedNoteIndex = _score.length - 1;
                  },
                  style: ButtonStyle(
                      backgroundColor: dotted == 1
                          ? (_score.getLastNote().measureProgress + (3 / 2)) <=
                                  timeSignatureTop / timeSignatureBottom
                              ? MaterialStateProperty.all(Colors.indigo[400])
                              : MaterialStateProperty.all(Colors.indigo[200])
                          : (_score.getLastNote().measureProgress + 1) <=
                                  timeSignatureTop / timeSignatureBottom
                              ? MaterialStateProperty.all(Colors.indigo[400])
                              : MaterialStateProperty.all(Colors.indigo[200])),
                  child: Image.asset('assets/images/1.png', width: 20, height: 20),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
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
                      selectedNoteIndex = _score.length - 1;
                    });
                  },
                  style: ButtonStyle(
                      backgroundColor: dotted == 0
                          ? MaterialStateProperty.all(Colors.grey)
                          : MaterialStateProperty.all(Colors.black)),
                  child: const Text('.'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isRest = !isRest; // toggle between notes and rests
                    });
                  },
                  style: ButtonStyle(
                      backgroundColor: !isRest
                          ? MaterialStateProperty.all(Colors.grey)
                          : MaterialStateProperty.all(Colors.black)),
                  child: const Text('Rest'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                ),
                IconButton(
                  onPressed: () {
                    playBack(); // plays back the music written on the staff
                  },
                  icon: const Icon(Icons.play_arrow),
                ),
              ]),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
            side: BorderSide(color: Color.fromARGB(255, 124, 24, 157))),
        onPressed: () {
          Navigator.push(
            context,
            //MaterialPageRoute(builder: (context) => SavePage(this)),
            MaterialPageRoute(builder: (context) => PlayingPage()),
          );
        },
        tooltip: 'Go to playing page',
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }

  /// Plays back the music written on the staff
  void playBack() {}
}
