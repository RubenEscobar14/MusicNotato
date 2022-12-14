import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:music_notato/helper.dart';
import 'package:music_notato/main.dart';
import 'package:music_notato/models/note.dart';
import 'package:music_notato/models/score.dart';
import 'package:music_notato/screens/playing_page.dart';
import 'package:music_notato/screens/save_page.dart';
import 'package:music_notato/widgets/add_note_button_widget.dart';
import 'package:music_notato/widgets/edit_note_widgets.dart';
import 'package:music_notato/widgets/music_painter_widget.dart';

/// The main page of the app
class HomePage extends State<MyHomePage> {
  Map<String, Uint8List> audioFiles = <String, Uint8List>{};
  Score _score = Score(); // current score

  double xPosition = 60; // starting x-coordinate for notes
  List<double> xPositions = []; // list of x-coordinates for the notes
  int selectedNoteIndex = -1; // currently selected note
  double tappedPositionX = -1;
  double tappedPositionY = -1;

  final List<String> noteNames = ['a', 'b', 'c', 'd', 'e', 'f', 'g'];

  String note = 'A'; // default note name
  int duration = 4; // default length of a note
  int octave = 4; // default octave of a note
  int dotted = 0; // default set to not dotted
  int accidental =
      0; // not implemented yet (when it is implemented, will also have to implement keys)

  String currentClef = 'treble'; // default clef
  int _tempo = 100; // default tempo

  // map of duration values to fraction of a measure using whole note = 1
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

  var numBeats = [ // choices for the number of beats in a measure
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12'
  ];

  var beatUnits = ['2', '4', '8', '16']; // choices for the units of beat

  String numBeatsString = '4';
  String beatUnitString = '4';
  int timeSignatureTop = 4; // default number of beats in a measure
  int timeSignatureBottom = 4; // default beat unit
  double noteLength = 0; // fraction a note take up in a measure

  bool isRest = false;

  final player = AudioPlayer();
  int currentFile = 1; // default save

  ScrollController controller = ScrollController(); // https://api.flutter.dev/flutter/widgets/ScrollController-class.html

  // Getters
  Score get score => _score;
  int get tempo => _tempo;
  int get signatureBottom => timeSignatureBottom;
  Map<String, Uint8List> get audio => audioFiles;
  Note get lastNote {
    return _score.lastNote;
  }

  /// Loads a save on startup
  @override
  void initState() {
    super.initState();
    loadSave();
    loadNotes();
  }

  /// Loads audio files
  void loadNotes() async {
    audioFiles = await Helper.loadAudioFiles();
  }

  /// Loads notes by reading the notato data file (if found) that corresponds to
  /// currentFile, and mapping each property to a "new" note, which is then
  /// added to the staff.
  void loadSave() {
    widget.storage.readFile(currentFile).then((value) {
      setState(() {
        if (value.length <= 1) return;
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
    setState(() {
      _score.clearScore();
      xPosition = 60;
      xPositions = [];
    });
  }

  /// Switches the file and loads information from the new one. Intended to be
  /// called when loading a save from the save page.
  void onLoad(int currentSave) {
    currentFile = currentSave;
    clearNotes();
    loadSave();
  }

  /// Selects the last note in the composition
  void selectLastNote() {
    selectedNoteIndex = _score.length - 1;
  }

  /// Adds a note to the staff at the end of the list of notes. Will automatically re-save to
  /// the json file by default, but saveOnAdd can be set to false to not do this.
  void _addNote(Note currentNote, {bool saveOnAdd = true}) {
    _addNoteAt(currentNote, _score.length);
  }

  /// Like the addnote() function, but adds the note at a specified index instead of the end of the list
  void _addNoteAt(Note currentNote, int position, {bool saveOnAdd = true}) {
    // updates the duration to the duration of the note being added
    duration = currentNote.duration;
    // recalculates the measure progress for the note based on the score it's about to be added to
    currentNote.measureProgress = returnMeasureProgress();
    setState(() {
      if (currentNote.measureProgress <=
          timeSignatureTop / timeSignatureBottom) {
        xPositions.add(xPosition);
        xPosition += 40;
        _score.allNotes.insert(position, currentNote);
        if (saveOnAdd) {
          widget.storage.writeFile(_score.allNotes, currentFile);
        }
      }
      if (currentNote.measureProgress ==
          timeSignatureTop / timeSignatureBottom) {
        xPosition += 20;
      }
    });
  }

  /// Deletes every note and adds the passed list to the staff
  void renderList(List<Note> newNoteList) {
    clearNotes();
    for (Note note in newNoteList) {
      _addNote(note, saveOnAdd: false);
    }
    widget.storage.writeFile(_score.allNotes, currentFile);
  }

  /// Deletes the last note in the score
  Note _deleteNote() {
    return _deleteNoteAt(_score.length - 1);
  }

  /// Deletes the note at the specified positon from the score
  Note _deleteNoteAt(int index, {bool rerender = false}) {
    if (!_score.isEmpty) {
      Note toRemove = _score.getNote(index);
      _score.removeNoteAt(index);
      if (rerender) {
        renderList(_score.allNotes);
      }
      return toRemove;
    }
    return Note(NoteLetter.a, 4, 4, 0, 0, 0);
  }

  /// Prints the current noteList and xPositions, debugging use only
  void _printNoteInfo() {
    print(_score.allNotes);
    print(xPositions);
  }

  /// Returns the fraction of the measure that has been completed
  double returnMeasureProgress() {
    try {
      noteLength = durationRatios[duration]!.toDouble(); // fraction of a measure the current duration takes up
    } catch (e) {
      noteLength = 4;
    }
    double measureProgress = 0;
    if (_score.isEmpty) {
      measureProgress = noteLength;
    } else {
      if (_score.lastNote.measureProgress ==
          timeSignatureTop / timeSignatureBottom) {
        measureProgress = noteLength;
      } else {
        measureProgress = noteLength + _score.lastNote.measureProgress;
      }
    }
    return measureProgress;
  }

  /// Updates the currently selected note to the nearest note to the input coordinates
  void selectNewNote(double x) {
    double min = 1000;
    int minIndex = -1;
    for (int i = 0; i < xPositions.length; i++) {
      if (distance(xPositions[i], x) < min) {
        minIndex = i;
        min = distance(xPositions[i], x);
      }
    }
    setState(() {
      selectedNoteIndex = minIndex;
    });
  }

  /// Returns the distance between two points in 1 dimension
  double distance(double x, double y) {
    double dist = x - y;
    if (dist < 0) {
      return dist * -1;
    } else {
      return dist;
    }
  }

  /// Changes the duration to a new number
  void setDuration(int newDur) {
    duration = newDur;
  }

  /// Determines where the staff is automatically scrolled to
  double determineScrollPosition() {
    if(score.isEmpty) {
      return 0;
    }
    else if(xPositions[xPositions.length - 1] < 500) {
      return 0;
    }
    else {
      return xPositions[xPositions.length - 1] - 420;
    }
  }

  /// Main graphics for the home page
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
                /////////////////// left hand side buttons ///////////////////
                ElevatedButton(
                  // delete button
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red)),
                  onPressed: () {
                    setState(() {
                      _deleteNoteAt(selectedNoteIndex, rerender: true);
                      selectedNoteIndex = selectedNoteIndex - 1;
                      if (selectedNoteIndex < 0) {
                        selectedNoteIndex = 0;
                      }
                    });
                    controller.animateTo(determineScrollPosition(), duration: const Duration(milliseconds: 100), curve: Curves.linear);
                  },
                  child: const Icon(Icons.delete),
                ),
                if(!_score.isEmpty) // keeps the spacing of the buttons the same if the drop down values are removed
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                ),
                if(_score.isEmpty) // prevents the user from changing the time signature once they have begun their composition
                Row( // drop downs for changing time signature
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    DropdownButton(
                      // initial value
                      value: numBeatsString,
                      // down arrow icon
                      icon: const Icon(Icons.keyboard_arrow_down),
                      // array list of items
                      items: numBeats.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items),
                        );
                      }).toList(),
                      // after selecting the desired option, it will
                      // change the button value to the selected value
                      onChanged: (String? newValue) {
                        setState(() {
                          if(_score.isEmpty) {
                            numBeatsString = newValue!;
                            setState(() {
                              timeSignatureTop = int.parse(numBeatsString);
                            });
                          }
                        });
                      },
                      isDense: true,
                    ),
                    const Text('/'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 2),
                    ),
                    DropdownButton(
                      // initial Value
                      value: beatUnitString,
                      // down Arrow Icon
                      icon: const Icon(Icons.keyboard_arrow_down),
                      // array list of items
                      items: beatUnits.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items),
                        );
                      }).toList(),
                      // after selecting the desired option, it will
                      // change the button value to the selected value
                      onChanged: (String? newValue) {
                        setState(() {
                          if(_score.isEmpty) {
                            beatUnitString = newValue!;
                            setState(() {
                              timeSignatureBottom = int.parse(beatUnitString);
                            });
                          }
                        });
                      },
                      isDense: true,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                ),
                // note up button
                EditNoteButton(1, 0, Icons.arrow_drop_up, selectedNoteIndex,
                    _addNoteAt, _deleteNoteAt),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 0),
                ),
                Text('Note: ${_score.getNote(selectedNoteIndex).getNoteName()}'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 0),
                ),
                // note down button
                EditNoteButton(-1, 0, Icons.arrow_drop_down, selectedNoteIndex,
                    _addNoteAt, _deleteNoteAt),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                ),
                // octave up button
                EditNoteButton(0, 1, Icons.arrow_drop_up, selectedNoteIndex,
                    _addNoteAt, _deleteNoteAt),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 0),
                ),
                Text('Octave: ${_score.getNote(selectedNoteIndex).octave}'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 0),
                ),
                // octave down button
                EditNoteButton(0, -1, Icons.arrow_drop_down, selectedNoteIndex,
                    _addNoteAt, _deleteNoteAt),
              ]),
            ),
            Column(children: [
              SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(top: 140.h, bottom: 100.h),
                  controller: controller,
                  child: MusicPainterWidget( // staff and note-drawing graphics
                      xPosition,
                      xPositions,
                      timeSignatureTop,
                      timeSignatureBottom,
                      _score,
                      selectedNoteIndex,
                      selectNewNote),
                ),
              ),
              Row(
                children: [
                  ElevatedButton( // takes the user to the playing page
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PlayingPage(this)),
                      );
                    },
                    child: const Icon(Icons.play_arrow),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 3),
                  ),
                  ElevatedButton( // takes the user to the different saves
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SavePage(this)));
                      },
                      child: const Text("Switch Save")),
                ],
              ),
            ]),
            SizedBox(
              width: 70.w,
              child: Column(children: <Widget>[
                for(int i = 32; i > 0.5; i = i ~/ 2)
                Column(children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                  ),
                  AddNoteButtonWidget( // rhythm buttons
                    dotted,
                    isRest,
                    i,
                    timeSignatureTop,
                    timeSignatureBottom,
                    selectedNoteIndex,
                    lastNote,
                    controller,
                    determineScrollPosition(),
                    _addNote,
                    selectLastNote,
                    setDuration),
                ]),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                ),
                ElevatedButton( // dotted button
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
                ElevatedButton( // rest button
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
              ]),
            )
          ],
        ),
      ),
    );
  }

  /// Plays back the music written on the staff
  void playBack() {
    PlayingPage musicRender = PlayingPage(this);
    musicRender.playBack();
  }
}