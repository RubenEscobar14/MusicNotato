import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:music_notato/main.dart';
import 'package:music_notato/models/note.dart';
import 'package:music_notato/models/score.dart';
import 'package:music_notato/screens/playing_page.dart';
import 'package:music_notato/screens/save_page.dart';
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
    0: 0,
  };

  var timeSignatures = [
    '4/4',
    '3/4',
    '2/4',
    '2/2'
  ]; // list of available time signatures

  int timeSignatureTop = 4; // default number of beats in a measure
  int timeSignatureBottom = 4; // default beat unit

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
      if (currentNote.measureProgress <= timeSignatureTop / timeSignatureBottom) {
        xPositions.add(xPosition);
        xPosition += 40;
        _score.getAllNotes().add(currentNote);
        note = currentNote.getNoteName()[11];
        if (saveOnAdd) {
          widget.storage.writeFile(_score.getAllNotes(), currentFile);
        }
      }
      if (currentNote.measureProgress == timeSignatureTop / timeSignatureBottom) {
        xPosition += 10;
      }
    });
  }

  //like the addnote() function, but adds the note at a specified index instead of the end of the list
  void _addNoteAt(Note currentNote, int position, {bool saveOnAdd = true}) {
    setState(() {
      if (currentNote.measureProgress <= timeSignatureTop / timeSignatureBottom) {
        xPositions.add(xPosition);
        xPosition += 40;
        _score.getAllNotes().insert(position, currentNote);
        if (saveOnAdd) {
          widget.storage.writeFile(_score.getAllNotes(), currentFile);
        }
      }
      if (currentNote.measureProgress == timeSignatureTop / timeSignatureBottom) {
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
    double noteLength;
    try {
      noteLength = durationRatios[duration]!.toDouble(); // percentage of
    }
    catch (e) {
      noteLength = 4;
    }
    double measureProgress = 0;
    if (_score.isEmpty) {
      measureProgress = noteLength;
    } else {
      if (_score.getLastNote().measureProgress == timeSignatureTop / timeSignatureBottom) {
        measureProgress = noteLength;
      } else {
        measureProgress = noteLength + _score.getLastNote().measureProgress;
      }
    }
    return measureProgress;
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
                      backgroundColor:
                          MaterialStateProperty.all(Colors.red[800])),
                  onPressed: () {
                    _deleteNote();
                    if (!_score.isEmpty) {
                      _addNote(_deleteNote());
                    }
                    selectedNoteIndex = _score.length - 1;
                  },
                  child: const Icon(Icons.delete),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                ),
                ElevatedButton(
                  // note up button
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.amber[400]),
                      foregroundColor:
                          MaterialStateProperty.all(Colors.indigo[400])),
                  onPressed: () {
                    Note previous = _deleteNoteAt(selectedNoteIndex);
                    previous.increasePitch(1);
                    if (previous.getNote() == NoteLetter.c) {
                      previous.setOctave(previous.getOctave() + 1);
                    }
                    _addNoteAt(previous, selectedNoteIndex);
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
                          MaterialStateProperty.all(Colors.amber[400]),
                      foregroundColor:
                          MaterialStateProperty.all(Colors.indigo[400])),
                  onPressed: () {
                    Note previous = _deleteNoteAt(selectedNoteIndex);
                    previous.increasePitch(6);
                    if (previous.getNote() == NoteLetter.b) {
                      previous.setOctave(previous.getOctave() - 1);
                    }
                    _addNoteAt(previous, selectedNoteIndex);
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
                      Note previous = _deleteNoteAt(selectedNoteIndex);
                      previous.setOctave(previous.getOctave() + 1);
                      _addNoteAt(previous, selectedNoteIndex);
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
                      Note previous = _deleteNoteAt(selectedNoteIndex);
                      previous.setOctave(previous.getOctave() - 1);
                      _addNoteAt(previous, selectedNoteIndex);
                    },
                    child: const Icon(Icons.arrow_drop_down)),
              ]),
            ),
            Expanded(
                child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(top: 200.h, bottom: 165.h),
              child: _paint(),
            )),
            SizedBox(
              width: 70.w,
              child: Column(children: <Widget>[
                // NoteDurationButton(duration: 32, buttonText: 'Thirtysecond', isSelected: false, onDurationChanged: _handleDurationChanged()),
                // NoteDurationButton(duration: 16, buttonText: 'Sixteenth', isSelected: false, onDurationChanged: _handleDurationChanged()),
                // NoteDurationButton(duration: 8, buttonText: 'Eigth', isSelected: false, onDurationChanged: _handleDurationChanged()),
                // NoteDurationButton(duration: 4, buttonText: 'Quarter', isSelected: false, onDurationChanged: _handleDurationChanged()),
                // NoteDurationButton(duration: 2, buttonText: 'Half', isSelected: false, onDurationChanged: _handleDurationChanged()),
                // NoteDurationButton(duration: 1, buttonText: 'Whole', isSelected: false, onDurationChanged: _handleDurationChanged()),
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
                      backgroundColor:
                          MaterialStateProperty.all(Colors.indigo[100])),
                  child: const Text('1/32'),
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
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[200]),
                  child: const Text('1/16'),
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
                      backgroundColor:
                          MaterialStateProperty.all(Colors.indigo[300])),
                  child: const Text('1/8'),
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
                      backgroundColor:
                          MaterialStateProperty.all(Colors.indigo[400])),
                  child: const Text('1/4'),
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
                      backgroundColor:
                          MaterialStateProperty.all(Colors.indigo[500])),
                  child: const Text('1/2'),
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
                      backgroundColor:
                          MaterialStateProperty.all(Colors.indigo[600])),
                  child: const Text('1'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
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
                    selectedNoteIndex = _score.length - 1;
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.grey)),
                  child: const Text('.'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                ),
                ElevatedButton(
                  onPressed: () {
                    isRest = !isRest; // toggle between notes and rests
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.grey)),
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

  /// Initializes the staff and note widgets
  Widget _paint() {
    return Stack(
      children: <Widget>[
        CustomPaint(
          size: Size(
              xPosition < MediaQuery.of(context).size.width
                  ? MediaQuery.of(context).size.width
                  : xPosition,
              50),
          painter: StaffWidget('treble', timeSignatureTop, timeSignatureBottom),
        ),
        GestureDetector(
          onTap: () => print('tapped!'),
          onTapDown: (TapDownDetails details) => _onTapDown(details),
          child: CustomPaint(
            size: Size(_score.length * 50, 50),
            painter: NoteWidget(_score.getAllNotes(), xPositions, 'treble',
                timeSignatureTop, timeSignatureBottom, selectedNoteIndex),
          ),
        ),
        // GestureDetector(
        //   onTap: () => print('tapped!'),
        //   onTapDown: (TapDownDetails details) => _onTapDown(details),
        // ),
        // GestureDetector(
        //   onTap: () => print('tapped!'),
        //   onTapDown: (TapDownDetails details) => _onTapDown(details),
        //   child: CustomPaint(
        //     size: Size(_score.length * 50, 50),
        //     painter: NoteWidget(_score.getAllNotes(), xPositions, 'treble',
        //         signature, signature_, selectedNote),
        //   ),
        // ),
      ],
    );
  }

  _onTapDown(TapDownDetails details) {
    tappedPositionX = details.localPosition.dx;
    tappedPositionY = details.localPosition.dy;
    selectNewNote(tappedPositionX, tappedPositionY);
  }

  void selectNewNote(double x, double y) {
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

  double distance(double x, double y) {
    double dist = x - y;
    if (dist < 0) {
      return dist * -1;
    } else {
      return dist;
    }
  }

  /// Plays back the music written on the staff
  void playBack() {}
}
