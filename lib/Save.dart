import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'note.dart';
import 'playing_page.dart';

class Save {
  List<Note> _allNotes = List.empty(growable: true);
  final JsonEncoder encoder = JsonEncoder();
  final JsonDecoder decoder = JsonDecoder();

  Future<String?> get _localPath async {
    //TODO: Change this to be the commented out version. I can't access that
    //to look at the file for testing, which is why it's commented out, but it
    //straight up won't work on iOS. Also remove the question marks
    //final directory = await getApplicationDocumentsDirectory();
    final directory = await getExternalStorageDirectory();
    return directory?.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    print('PATH: $path');
    return File('$path/notato_dotata.json');
  }

  Future<List<dynamic>> readFile() async {
    try {
      final file = await _localFile;
      final String notesFromFile = await file.readAsString();
      final toReturn = jsonDecode(notesFromFile);
      return toReturn;
    } catch (e) {
      return List.empty(growable: true);
    }
  }

  Future<File> writeFile(List<Note> notesToSave) async {
    _allNotes = notesToSave;
    final file = await _localFile;
    return file.writeAsString(encoder.convert(_allNotes));
  }

  List<Note> strToNoteList(String fileText) {
    List<Note> toReturn = List.empty(growable: false);
    //TODO: Regex? This should just grab bits of text before a semicolon
    var unparsedRead = fileText.split('');
    String chunk = '';
    for (String char in unparsedRead) {
      if (char != ';') {
        chunk = '$chunk$char';
      } else {
        var noteParts = chunk.split('');
        chunk = '';
        //TODO: Make it so this won't break if the number of characters isn't constant
        toReturn.add(Note(
            noteParts[0],
            int.parse(noteParts[1]),
            int.parse(noteParts[2]),
            int.parse(noteParts[3]),
            int.parse(noteParts[4]),
            double.parse(noteParts[5])));
      }
    }
    return toReturn;
  }

  String noteListToStr(List<Note> noteList) {
    String toReturn = '';
    for (Note note in noteList) {
      toReturn =
          '$toReturn.${note.note}.${note.octave}.${note.duration}.${note.accidental};';
    }
    return toReturn;
  }

  List<Note> getAllNotes() {
    return _allNotes;
  }
}