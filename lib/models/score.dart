import 'package:music_notato/models/note.dart';

/// Represents the current score
class Score {
  // ignore: prefer_final_fields
  List<Note> _allNotes = List.empty(growable: true);

  bool get isEmpty => _allNotes.isEmpty;
  int get length => _allNotes.length;

  Score() : _allNotes = List.empty(growable: true);
  Score.fromList(this._allNotes);

  List<Note> getAllNotes() {
    return _allNotes;
  }

  Note getNote(int index) {
    return _allNotes[index];
  }

  Note getLastNote() {
    return _allNotes[_allNotes.length - 1];
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
}
