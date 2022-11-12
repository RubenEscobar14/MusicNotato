import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:music_notato/main.dart';
import 'package:music_notato/models/note.dart';
import 'package:music_notato/models/score.dart';
import 'package:music_notato/screens/playing_page.dart';
// import 'package:music_notato/widgets/note_duration_button.dart';
import 'package:music_notato/widgets/note_widget.dart';
import 'package:music_notato/widgets/staff_widget.dart';

/// The main page of the app
class HomePage extends State<MyHomePage> {
  Score _score = Score(); // current score

  double xPosition = 40; // starting x-coordinate for notes
  List<Note> noteList = []; // list of all notes
  List<double> xPositions = []; // list of x-coordinates for the notes
  int selectedNote = -1; // currently selected note

  final List<String> noteNames = ['a', 'b', 'c', 'd', 'e', 'f', 'g'];

  int duration = 4; // default length of a note
  int octave = 4; // default octave of a note
  int dotted = 0; // default set to not dotted
  int accidental = 0; // not implemented yet (when it is implemented, will also have to implement keys)

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

  // var timeSignatures = [
  //   '4/4',
  //   '3/4',
  //   '2/4',
  //   '2/2'
  // ]; // list of available time signatures

  int signature = 4; // default number of beats in a measure
  int signature_ = 4; // default beat unit

  bool isRest = false;

  final player = AudioPlayer();

  Score getScore() {
    return _score;
  }

  int getTempo() {
    return _tempo;
  }

  int getSignature_() {
    return signature_;
  }

  /// Loads notes by reading the notato data file (if found) and mapping each
  /// property to a "new" note, which is then added to the staff.
  @override
  void initState() {
    super.initState();
    widget.storage.readFile().then((value) {
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

  /// Adds a note to the staff and list of notes. Will automatically re-save to
  /// the json file by default, but saveOnAdd can be set to false to not do this.
  void _addNote(Note currentNote, {bool saveOnAdd = true}) {
    setState(() {
      if (currentNote.complete <= signature / signature_) {
        noteList.add(currentNote);
        xPositions.add(xPosition);
        xPosition += 40;
        _score.getAllNotes().add(currentNote);
        if (saveOnAdd) {
          widget.storage.writeFile(_score.getAllNotes());
        }
      }
      if (currentNote.complete == signature / signature_) {
        xPosition += 20;
      }
    });
  }

  /// Deletes the last note in the list
  Note _deleteNote() {
    Note toRemove = noteList[noteList.length - 1];
    noteList.remove(toRemove);
    xPosition = xPositions[xPositions.length - 1];
    xPositions.remove(xPositions[xPositions.length - 1]);
    return toRemove;
  }

  /// Returns the last note in the current notelist
  Note _getLastNote() {
    if (noteList.isEmpty) {
      return new Note(NoteLetter.a, 4, 4, 0, 0, returnComplete());
    }
    return noteList[noteList.length - 1];
  }

  /// Returns a note with the same characteristics as the previous note but with the given duration
  Note nextNoteWithNewDuration(int duration) {
    Note lastNote = _getLastNote();
    if (isRest) {
      return Note.rest(duration, dotted, returnComplete());
    }
    return Note(lastNote.getNote(), lastNote.getOctave(), duration, dotted,
        lastNote.getAccidental(), returnComplete());
  }

  /// Prints the current noteList and xPositions, debugging use only
  void _printNoteInfo() {
    print(noteList);
    print(xPositions);
  }

  /// Returns the fraction of the measure that has been completed
  double returnComplete() {
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
      body: SingleChildScrollView(
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 70.w,
              child: Column(children: <Widget>[
                /////////////////// All the buttons ///////////////////
                ElevatedButton(
                  onPressed: () {
                    _deleteNote();
                    _addNote(_deleteNote());
                    selectedNote = noteList.length - 1;
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black)),
                  child: const Text('Delete'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Note previous = _deleteNote();
                    previous.increasePitch(1);
                    if (previous.getNote() == NoteLetter.c) {
                      previous.setOctave(previous.getOctave() + 1);
                    }
                    _addNote(previous);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black)),
                  child: const Text('Up'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Note previous = _deleteNote();
                    previous.increasePitch(6);
                    if (previous.getNote() == NoteLetter.b) {
                      previous.setOctave(previous.getOctave() - 1);
                    }
                    _addNote(previous);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black)),
                  child: const Text('Down'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Note previous = _deleteNote();
                    previous.setOctave(previous.getOctave() + 1);
                    _addNote(previous);
                  },
                  child: const Text('Octave Up')),
                ElevatedButton(
                  onPressed: () {
                    Note previous = _deleteNote();
                    previous.setOctave(previous.getOctave() - 1);
                    _addNote(previous);
                  },
                  child: const Text('Octave Down')), 
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(top: 60.h),
                child: _paint(),
              )
            ),
            SizedBox(
              width: 70.w,
              child: Column(children: <Widget>[
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
                    selectedNote = noteList.length - 1;
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
                    selectedNote = noteList.length - 1;
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
                    selectedNote = noteList.length - 1;
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
                    selectedNote = noteList.length - 1;
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
                    selectedNote = noteList.length - 1;
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
                    selectedNote = noteList.length - 1;
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
                    selectedNote = noteList.length - 1;
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black)),
                  child: const Text('.'),
                ),
                ElevatedButton(
                  onPressed: () {
                    isRest = !isRest; // toggle between notes and rests
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black)),
                  child: const Text('Rest'),
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
          size: Size(MediaQuery.of(context).size.width - 250, 50),
          painter: StaffWidget('treble', signature, signature_),
        ),
        CustomPaint(
          size: Size(noteList.length * 50, 50),
          painter: NoteWidget(noteList, xPositions, 'treble',
              signature, signature_, selectedNote),
        ),
      ],
    );
  }

  /// Plays back the music written on the staff
  void playBack() {}
}