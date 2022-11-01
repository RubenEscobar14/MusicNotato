import 'package:flutter/material.dart';

typedef DurationChangeCallback = Function(int duration);

class NoteButton extends StatefulWidget {
  final String noteName;
  final int octave;
  final String buttonText;
  final NoteChangedCallback onNoteChanged;

  NoteButton({
    required this.noteName,
    required this.octave,
    required this.buttonText,
    required this.onNoteChanged,
  }) :super(key: ObjectKey(noteName));

  @override
  State<NoteButton> createState() => _NoteButtonState();
}

class NoteChangedCallback {
  
}

class _NoteButtonState extends State<NoteButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        widget.onNoteChanged;
      },
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black)),
      child: Text(widget.buttonText),
    );
  }
}