import 'package:music_notato/models/note.dart';

/// Represents the current score
class Score {
  // ignore: prefer_final_fields
  List<Note> _allNotes = List.empty(growable: true);

  bool get isEmpty => _allNotes.isEmpty;
  int get length => _allNotes.length;
  List<Note> get allNotes => _allNotes;
  Note get lastNote {
    if (isEmpty) {
      return Note(NoteLetter.a, 4, 4, 0, 0, 0);
    }
    return _allNotes[_allNotes.length - 1];
  }

  Score() : _allNotes = List.empty(growable: true);
  Score.fromList(this._allNotes);

  Note getNote(int index) {
    if(index < 0 || isEmpty) {
      return Note(NoteLetter.a, 4, 4, 0, 0, 0);
    }
    return _allNotes[index];
  }

  void addNote(Note note) {
    _allNotes.add(note);
  }

  void clearScore() {
    _allNotes = List.empty(growable: true);
  }

  void removeLastNote() {
    _allNotes.removeLast();
  }

  void removeNoteAt(int index) {
    _allNotes.removeAt(index);
  }
}
