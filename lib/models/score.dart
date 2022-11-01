import 'dart:collection';

import 'package:music_notato/models/note.dart';

class Score {
  // ignore: prefer_final_fields
  List<Note> _allNotes = List.empty(growable: true);

  bool get isEmpty => _allNotes.isEmpty;
  int get length => _allNotes.length;

  Score(): _allNotes = List.empty(growable: true);
  Score.fromList(this._allNotes);

  List<Note> getAllNotes() {
    return UnmodifiableListView(_allNotes);
  }

  Note getNote(int index) {
    return _allNotes[index];
  }

  void addNote(Note note) {
    _allNotes.add(note);
  }

  void removeNote(int index) {
    _allNotes.remove(_allNotes[index]);
  }
}