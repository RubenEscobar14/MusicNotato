import 'dart:convert';
import 'dart:io';
import 'package:music_notato/models/note.dart';
import 'package:path_provider/path_provider.dart';

/// This class handles the transfer of information between the program and
/// save files.
class Save {
  List<Note> _allNotes = List.empty(growable: true);
  final JsonEncoder encoder = JsonEncoder();
  final JsonDecoder decoder = JsonDecoder();

  // Decides which directory the save file(s) should be in and returns it.
  Future<String?> get _localPath async {
    // TODO: Change this to be the commented out version. I can't access that
    // to look at the file for testing, which is why it's commented out, but it
    // straight up won't work on iOS. Also remove the question marks
    // final directory = await getApplicationDocumentsDirectory();
    final directory = await getExternalStorageDirectory();
    return directory?.path;
  }

  // Decides, based on the already chosen directory, which file should be used
  // for saving and returns it
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/notato_dotata.json');
  }

  /// Reads the save file and returns a list of Maps containing the properties
  /// of a Note object. The Map's keys are represented as Strings.
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

  /// Saves notesToSave to the the save file
  Future<File> writeFile(List<Note> notesToSave) async {
    _allNotes = notesToSave;
    final file = await _localFile;
    return file.writeAsString(jsonEncode(_allNotes));
  }

  List<Note> getAllNotes() {
    return _allNotes;
  }
}