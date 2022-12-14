import 'dart:convert';
import 'dart:io';
import 'package:music_notato/models/note.dart';
import 'package:path_provider/path_provider.dart';

/// Class that handles the transfer of information between the program and
/// save files.
class Save {
  final JsonEncoder encoder = JsonEncoder();
  final JsonDecoder decoder = JsonDecoder();

  /// Decides which directory the save file(s) should be in and returns it.
  Future<String?> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    // final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  /// Decides, based on the already chosen directory, which file should be used
  /// for saving and returns it. Which is the file number.
  Future<File> _localFile(int which) async {
    final path = await _localPath;
    return File('$path/notato_dotata$which.json');
  }

  /// Reads the save file and returns a list of Maps containing the properties
  /// of a Note object. The Map's keys are represented as Strings. Which is the
  /// file number.
  Future<List<dynamic>> readFile(int which) async {
    try {
      final file = await _localFile(which);
      final String notesFromFile = await file.readAsString();
      final toReturn = jsonDecode(notesFromFile);
      return toReturn;
    } catch (e) {
      return List.empty(growable: true);
    }
  }

  /// Saves notesToSave to the the save file. Which is the file number.
  Future<File> writeFile(List<Note> notesToSave, int which) async {
    final file = await _localFile(which);
    return file.writeAsString(jsonEncode(notesToSave));
  }
}