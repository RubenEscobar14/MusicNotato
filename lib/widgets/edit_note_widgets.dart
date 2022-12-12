import 'package:flutter/material.dart';
import 'package:music_notato/models/note.dart';

typedef AddNoteAt = void Function(Note note, int index);
typedef DeleteNoteAt = Note Function(int index);

class EditNoteButton extends StatelessWidget {
  int noteChange;
  int octaveChange;
  IconData buttonIcon;
  int selectedNoteIndex;

  final AddNoteAt addNoteAt;
  final DeleteNoteAt deleteNoteAt;

  EditNoteButton(
      this.noteChange,
      this.octaveChange,
      this.buttonIcon,
      this.selectedNoteIndex,
      void this.addNoteAt(Note note, int index),
      Note this.deleteNoteAt(int index));

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

  void changeNoteBy(int change, Note changing) {
    int octChange = changing.increasePitch(change);
    changing.setOctave(changing.octave + octChange);
  }

  void changeOctaveBy(int change, Note changing) {
    changing.setOctave(changing.octave + change);
  }
}
