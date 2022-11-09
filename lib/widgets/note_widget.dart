import 'dart:math';
import 'package:flutter/material.dart';
import 'package:music_notato/models/note.dart';

// Class that draws the notes to the canvas
class NoteWidget extends CustomPainter {
  List<Note> noteList; // list of all notes
  List<double> xPositions; // list of x-positions for the notes

  String currentClef;

  // Positions for C4-B4 depending on the clef
  // Position is defined so that in descending order, the y-coordinate of the staff lines are 2x, x, 0, -x, and -2x
  List<double> trebleBasePositions = [-3, -2.5, -2, -1.5, -1, -0.5, 0];
  List<double> altoBasePositions = [0, 0.5, 1, 1.5, 2, 2.5, 3];
  List<double> bassBasePositions = [3, 3.5, 4, 4.5, 5, 5.5, 6];

  int signature; // number of beats per measure
  int signature_; // unit of beat

  // Constructor
  NoteWidget(this.noteList, this.xPositions, this.currentClef,
      this.signature, this.signature_);

  // Map of base positions for each note depending on the clef
  Map<String, Map<String, double>> noteToClefBasePositions = <String, Map<String, double>>{
    'c': {
      'treble': -3,
      'alto': 0.5,
      'bass': 3
    },
    'd': {
      'treble': -2.5,
      'alto': 0.5,
      'bass': 3.5
    },
    'e': {
      'treble': -2,
      'alto': 1,
      'bass': 4
    },
    'f': {
      'treble': -1.5,
      'alto': 1.5,
      'bass': 4.5
    },
    'g': {
      'treble': -1,
      'alto': 2,
      'bass': 5
    },
    'a': {
      'treble': -0.5,
      'alto': 2.5,
      'bass': 5.5
    },
    'b': {
      'treble': 0,
      'alto': 3,
      'bass': 6
    },
  };

  // Calculates the base position for a given note and clef
  double calculateBasePosition(String noteName, String currentClef) {
    return noteToClefBasePositions.entries.firstWhere((element) => element.key == noteName).value.entries.firstWhere((element) => element.key == currentClef).value;
  }

  // Calculates the position of a specific note
  double calculatePosition(
      NoteLetter noteName, int octave, String currentClef) {
    double basePosition = calculateBasePosition(noteName.name, currentClef);
    return basePosition + 3.5 * (octave - 4);
  }

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;
    double x = size.height / 4; // Distance between two lines of the staff

    for (int i = 0; i < noteList.length; i++) {
      Note currentNote = noteList[i];
      double xPosition =
          xPositions[i]; // x-coordinate of the note to be drawn
      double position = calculatePosition(currentNote.note, noteList[i].octave,
          currentClef); // position of the current note on the staff
      double y = -position * x; // y-coordinate of the note to be drawn

      if (currentNote.duration == 1 || currentNote.duration == 2 || currentNote.duration == 0 || currentNote.duration == 3) {
        // draws an unfilled notehead (notehead for whole and half notes)
        drawNotehead(canvas, paint, PaintingStyle.stroke, x, xPosition, y);
      } 
      else {
        // draws a filled notehead (notehead for all other notes)
        drawNotehead(canvas, paint, PaintingStyle.fill, x, xPosition, y);
      }
      if (currentNote.duration != 1 && currentNote.duration != 0) {
        double stemEndX;
        double stemEndY;
        if (position >= 0) { // draws a stem going down
          stemEndX = xPosition-(748/1024)*x*cos(pi/9)+(paint.strokeWidth/2);
          if(position > 3) {
            stemEndY = 0;
          }
          else {
            stemEndY = y+3.5*x;
          }
          canvas.drawLine(Offset(stemEndX,y+(748/1024)*x*sin(pi/9)),Offset(stemEndX,stemEndY),paint);
        }
        else { // draws a stem going up
          stemEndX = xPosition+(748/1024)*x*cos(pi/9)+(paint.strokeWidth/2);
          if(position < -3) {
            stemEndY = 0;
          }
          else {
            stemEndY = y-3.5*x;
          }
          canvas.drawLine(Offset(stemEndX,y-(748/1024)*x*sin(pi/9)),Offset(stemEndX,stemEndY),paint);
        }
        // Draws the first flag on shorter notes
        if (currentNote.duration != 4 && currentNote.duration != 2 && currentNote.duration != 6 && currentNote.duration != 3) {
          if (position > 0) { // draws the flag pointing down
            canvas.drawLine(Offset(stemEndX, stemEndY), Offset(stemEndX + x, stemEndY - 1.5 * x), paint);
          } 
          else { // draws the flag pointing up
            canvas.drawLine(Offset(stemEndX, stemEndY), Offset(stemEndX + x, stemEndY + 1.5 * x), paint);
          }
          // Draws the second flag on shorter notes
          if (currentNote.duration != 8 && currentNote.duration != 12) {
            if (position > 0) { // draws the flag pointing up
              canvas.drawLine(Offset(stemEndX, stemEndY - 0.5 * x), Offset(stemEndX + x, stemEndY - 2 * x), paint);
            } 
            else { // draws the flag pointing down
              canvas.drawLine(Offset(stemEndX, stemEndY + 0.5 * x), Offset(stemEndX + x, stemEndY + 2 * x), paint);
            }
            // Draws the third flag on shorter notes
            if (currentNote.duration != 16 && currentNote.duration != 24) {
              if (position > 0) { // draws the flag point up
                canvas.drawLine(Offset(stemEndX, stemEndY - x), Offset(stemEndX + x, stemEndY - 2.5 * x), paint);
              } 
              else { // draws the flag pointing down
                canvas.drawLine(Offset(stemEndX, stemEndY + x), Offset(stemEndX + x, stemEndY + 2.5 * x), paint);
              }
            }
          }
        }
      }
      if (currentNote.dotted == 1) { // draws the dot for dotted notes
        canvas.drawCircle(Offset(xPosition+(748/512)*x*cos(pi/9), y), 0.15 * x, paint);
      }
      if (position > 2.5) { // draws ledger lines for notes above the middle staff line
        int counter = position.floor();
        while (counter > 2.5) {
          double ledgerLineY = -counter * x;
          canvas.drawLine(Offset(xPosition-0.75*(748/512)*x*cos(pi/9), ledgerLineY),
              Offset(xPosition+0.75*(748/512)*x*cos(pi/9), ledgerLineY), paint);
          counter--;
        }
      }
      if (position < -2.5) { // draws ledger lines for notes below the middle staff line
        double positivePosition = -position;
        int counter = positivePosition.floor();
        while (counter > 2.5) {
          double ledgerLineY = counter * x;
          canvas.drawLine(Offset(xPosition-0.75*(748/512)*x*cos(pi/9), ledgerLineY),
              Offset(xPosition+0.75*(748/512)*x*cos(pi/9), ledgerLineY), paint);
          counter--;
        }
      }
      if (currentNote.complete == signature / signature_) { // draws the measure line
        canvas.drawLine(Offset(xPosition+20, -2 * x),
            Offset(xPosition+20, 2 * x), paint);
      }
    }
  }

  // Draws a notehead
  void drawNotehead(Canvas canvas, Paint paint, PaintingStyle paintingStyle, double x, double xPosition, double y) {
    paint = Paint()
          ..style = paintingStyle
          ..strokeWidth = 2.0;
    canvas.save();
    canvas.translate(xPosition, y);
    canvas.rotate(-pi/9);
    canvas.translate(0, -y);
    Rect noteHead = Offset(-(748/1024)*x*cos(pi/9), y-(748/512)*x*sin(pi/9)) & Size((748 / 512) * x, x);
    canvas.drawOval(noteHead, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}