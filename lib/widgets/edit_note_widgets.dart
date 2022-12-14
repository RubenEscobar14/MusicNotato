import 'package:flutter/material.dart';
import 'package:music_notato/models/note.dart';

typedef AddNoteAt = void Function(Note note, int index);
typedef DeleteNoteAt = Note Function(int index);

/// Class that builds a button that can change the pitch of a note
class EditNoteButton extends StatelessWidget {
  int noteChange; // desired change in pitch (e.g. 1 means to increase the pitch by 1, such as from A to B)
  int octaveChange; // desired change in octave (e.g. 1 means to increase the octave by one, such as from 3 to 4)
  IconData buttonIcon;
  int selectedNoteIndex;

  final AddNoteAt addNoteAt;
  final DeleteNoteAt deleteNoteAt;

  /// Constructor
  EditNoteButton(
      this.noteChange,
      this.octaveChange,
      this.buttonIcon,
      this.selectedNoteIndex,
      void this.addNoteAt(Note note, int index),
      Note this.deleteNoteAt(int index), {super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Note previous = deleteNoteAt(selectedNoteIndex);
        changeNoteBy(noteChange, previous);
        changeOctaveBy(octaveChange, previous);
        addNoteAt(previous, selectedNoteIndex);
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.grey[400]),
      ),
      child: Icon(buttonIcon),
    );
  }

  /// Changes the pitch of a note by the specified value
  void changeNoteBy(int change, Note changing) {
    if(change < 0 && changing.octave == 0 && changing.note != NoteLetter.b) { // limits the lowest note to A0
      print('Too low.');
    }
    else if(change > 0 && changing.octave == 8 && changing.note != NoteLetter.b) { // limits the highest note to C8
      print('Too high.');
    }
    else {
      int octChange = changing.increasePitch(change);
      changing.setOctave(changing.octave + octChange);
    }
  }

  /// Changes the octave of a note by the specified value
  void changeOctaveBy(int change, Note changing) {
    if(changing.octave + change == 0 && changing.note != NoteLetter.a && changing.note != NoteLetter.b) {
      print('Too low.');
    }
    else if(change > 0 && changing.octave + change == 8 && changing.note != NoteLetter.c) {
      print('Too high.');
    }
    else {
      changing.setOctave(changing.octave + change);
    }
  }
}