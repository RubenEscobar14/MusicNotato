import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_notato/models/note.dart';
import 'package:music_notato/models/score.dart';

typedef AddNote = void Function(Note note);
typedef SelectLastNote = void Function();
typedef SetDuration = void Function(int duration);

class addNoteButtonWidget extends StatelessWidget {
  int dotted;
  int duration;
  int timeSignatureTop;
  int timeSignatureBottom;
  int selectedNoteIndex;
  Note previous;

  final AddNote addNote;
  final SelectLastNote selectLastNote;
  final SetDuration setDuration;

  addNoteButtonWidget(
      this.dotted,
      this.duration,
      this.timeSignatureTop,
      this.timeSignatureBottom,
      this.selectedNoteIndex,
      this.previous,
      void this.addNote(Note note),
      void this.selectLastNote(),
      void this.setDuration(int duration));

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (dotted == 1) {
          addNote(nextNoteWithNewDuration((duration * 1.5).round()));
        } else {
          addNote(nextNoteWithNewDuration(duration));
        }
        selectLastNote();
      },
      style: ButtonStyle(
          backgroundColor: dotted == 1
              ? (previous.measureProgress + (3 / (duration * 1.5).round())) <=
                      timeSignatureTop / timeSignatureBottom
                  ? MaterialStateProperty.all(Colors.indigo[400])
                  : MaterialStateProperty.all(Colors.indigo[200])
              : (previous.measureProgress + (1 / duration)) <=
                      timeSignatureTop / timeSignatureBottom
                  ? MaterialStateProperty.all(Colors.indigo[400])
                  : MaterialStateProperty.all(Colors.indigo[200])),
      child: Text(returnDurationText()),
    );
  }

  String returnDurationText() {
    if (duration == 1) {
      return "1";
    }
    return "1/$duration";
  }

  /// Returns a note with the same characteristics as the previous note but with the given duration
  Note nextNoteWithNewDuration(int duration) {
    if (previous.getNote() == NoteLetter.r) {
      return Note.rest(duration, dotted, previous.measureProgress + duration);
    }
    return Note(
        previous.getNote() == NoteLetter.r ? NoteLetter.a : previous.getNote(),
        previous.getOctave(),
        duration,
        dotted,
        previous.getAccidental(),
        -1);
  }
}
