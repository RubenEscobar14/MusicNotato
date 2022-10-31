import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'note.dart';
import 'playing_page.dart';

/// This class handles the transfer of information between the program and
/// save files.
class Save {
  List<Note> _allNotes = List.empty(growable: true);

<<<<<<< Updated upstream
  /// Decides which directory the save file(s) should be in and returns it.
  Future<String?> get _localPath async {
    //TODO: Change this to be the commented out version. I can't access that
    //to look at the file for testing, which is why it's commented out, but it
    //straight up won't work on iOS. Also remove the question marks
    //final directory = await getApplicationDocumentsDirectory();
    final directory = await getExternalStorageDirectory();
    return directory?.path;
=======
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
>>>>>>> Stashed changes
  }

  /// Decides, based on the already chosen directory, which file should be used
  /// for saving and returns it
  Future<File> get _localFile async {
    final path = await _localPath;
<<<<<<< Updated upstream
    return File('$path/notato_dotata.json');
  }

  /// Reads the save file and returns a list of Maps containing the properties
  /// of a Note object. The Map's keys are represented as Strings.
  Future<List<dynamic>> readFile() async {
=======
    return File('$path/notato.txt');
  }

  Future<List<Note>> readFile() async {
>>>>>>> Stashed changes
    try {
      final file = await _localFile;
      final String notesFromFile = await file.readAsString();
      return strToNoteList(notesFromFile);
    } catch (e) {
      return List.empty(growable: true);
    }
  }

<<<<<<< Updated upstream
  /// Saves notesToSave to the the save file
  Future<File> writeFile(List<Note> notesToSave) async {
    _allNotes = notesToSave;
    final file = await _localFile;
    return file.writeAsString(jsonEncode(_allNotes));
=======
  Future<File> writeFile() async {
    final file = await _localFile;
    return file.writeAsString(noteListToStr(_allNotes));
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
          double.parse(noteParts[5]),
        ));
      }
    }
    return toReturn;
  }

  String noteListToStr(List<Note> noteList) {
    String toReturn = '';
    for (Note note in noteList) {
      toReturn =
          '$toReturn${note.note}${note.octave}${note.duration}${note.accidental};';
    }
    return toReturn;
>>>>>>> Stashed changes
  }

  List<Note> getAllNotes() {
    return _allNotes;
  }
}
