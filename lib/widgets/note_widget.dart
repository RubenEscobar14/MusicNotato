import 'dart:math';
import 'package:flutter/material.dart';
import 'package:music_notato/models/note.dart';

/// Class that draws the notes to the canvas
/// https://www.mpa.org/wp-content/uploads/2018/06/standard-practice-engraving.pdf for music notation rules
/// http://faculty.washington.edu/garmar/notehead_specs.pdf for note head design
class NoteWidget extends CustomPainter {
  List<Note> noteList; // list of all notes
  List<double> xPositions; // list of x-positions for the notes
  int toHighlight; // index of highlighted note, defaults to first note

  String currentClef;

  // positions for C4-B4 depending on the clef
  // position is defined so that in descending order, the y-coordinate of the staff lines are 2x, x, 0, -x, and -2x
  List<double> trebleBasePositions = [-3, -2.5, -2, -1.5, -1, -0.5, 0];
  List<double> altoBasePositions = [0, 0.5, 1, 1.5, 2, 2.5, 3];
  List<double> bassBasePositions = [3, 3.5, 4, 4.5, 5, 5.5, 6];

  int timeSignatureTop; // number of beats per measure
  int timeSignatureBottom; // unit of beat

  final double ellipseWidth = 748 /
      512; // scaling factor for the length of the major axis of the notehead
  final double halfEllipseWidth = 748 /
      1024; // scaling factor for the length of the semimajor axis of the notehead
  final double noteWidth =
      (748 / 512) * cos(pi / 9); // scaling factor for the width of the note
  final double halfNoteWidth = (748 / 1024) *
      cos(pi / 9); // scaling factor for half the width of the note
  final double noteHeight =
      (748 / 512) * sin(pi / 9); // scaling factor for the height of the note
  final double halfNoteHeight = (748 / 1024) *
      sin(pi / 9); // scaling factor for half the height of the note
  final double rotationAngle =
      pi / 9; // number of radians the notehead is rotated counterclockwise

  /// Constructor
  NoteWidget(this.noteList, this.xPositions, this.currentClef,
      this.timeSignatureTop, this.timeSignatureBottom, this.toHighlight);

  // map of base positions for each note depending on the clef
  Map<String, Map<String, double>> noteToClefBasePositions =
      <String, Map<String, double>>{
    'c': {'treble': -3, 'alto': 0, 'bass': 3},
    'd': {'treble': -2.5, 'alto': 0.5, 'bass': 3.5},
    'e': {'treble': -2, 'alto': 1, 'bass': 4},
    'f': {'treble': -1.5, 'alto': 1.5, 'bass': 4.5},
    'g': {'treble': -1, 'alto': 2, 'bass': 5},
    'a': {'treble': -0.5, 'alto': 2.5, 'bass': 5.5},
    'b': {'treble': 0, 'alto': 3, 'bass': 6},
  };

  /// Calculates the base position for a given note and clef
  double calculateBasePosition(String noteName, String currentClef) {
    return noteToClefBasePositions.entries
        .firstWhere((element) => element.key == noteName)
        .value
        .entries
        .firstWhere((element) => element.key == currentClef)
        .value;
  }

  /// Calculates the position of a specific note
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
    var normalPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;
    var highlightPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0;
    double x = size.height / 4; // Distance between two lines of the staff
    for (int i = 0; i < noteList.length; i++) {
      Note currentNote = noteList[i];
      double xPosition = xPositions[i]; // x-coordinate of the note to be drawn
      if (i == toHighlight) {
        paint = highlightPaint;
      } else {
        paint = normalPaint;
      }
      if (currentNote.note == NoteLetter.r) {
        drawRest(currentNote, xPosition, canvas, paint, x);
      } else {
        drawNote(currentNote, xPosition, canvas, paint, x);
      }
    }
  }

  /// Draws a singular (i.e. not barred to other notes) note to the staff
  void drawNote(Note currentNote, double xPosition, Canvas canvas, Paint paint,
      double x) {
    double position = calculatePosition(currentNote.note, currentNote.octave,
        currentClef); // position of the current note on the staff
    double y = -position * x; // y-coordinate of the note to be drawn

    if (currentNote.duration == 1 ||
        currentNote.duration == 2 ||
        currentNote.duration == 0 ||
        currentNote.duration == 3) {
      paint.style = PaintingStyle.stroke;
      // draws an unfilled notehead (notehead for whole and half notes)
      drawNotehead(canvas, paint, 0.92 * x, xPosition, y);
    } else {
      // draws a filled notehead (notehead for all other notes)
      paint.style = PaintingStyle.fill;
      drawNotehead(canvas, paint, x, xPosition, y);
    }
    if (currentNote.duration != 1 && currentNote.duration != 0) {
      double stemEndX;
      double stemEndY;
      if (position >= 0) {
        // draws a stem going down
        stemEndX = xPosition - halfNoteWidth * x + 0.6 * paint.strokeWidth;
        if (position > 3) {
          stemEndY = 0;
        } else {
          stemEndY = y + 3.5 * x;
        }
        canvas.drawLine(Offset(stemEndX, y + halfNoteHeight * x),
            Offset(stemEndX, stemEndY), paint);
      } else {
        // draws a stem going up
        stemEndX = xPosition + halfNoteWidth * x;
        if (position < -3) {
          stemEndY = 0;
        } else {
          stemEndY = y - 3.5 * x;
        }
        canvas.drawLine(Offset(stemEndX, y - halfNoteHeight * x),
            Offset(stemEndX, stemEndY), paint);
      }
      // draws the first flag on shorter notes
      if (currentNote.duration != 4 &&
          currentNote.duration != 2 &&
          currentNote.duration != 6 &&
          currentNote.duration != 3) {
        if (position >= 0) {
          // draws the flag pointing down
          canvas.drawLine(Offset(stemEndX, stemEndY),
              Offset(stemEndX + x, stemEndY - 1.5 * x), paint);
        } else {
          // draws the flag pointing up
          canvas.drawLine(Offset(stemEndX, stemEndY),
              Offset(stemEndX + x, stemEndY + 1.5 * x), paint);
        }
        // draws the second flag on shorter notes
        if (currentNote.duration != 8 && currentNote.duration != 12) {
          if (position >= 0) {
            // draws the flag pointing up
            canvas.drawLine(Offset(stemEndX, stemEndY - 0.5 * x),
                Offset(stemEndX + x, stemEndY - 2 * x), paint);
          } else {
            // draws the flag pointing down
            canvas.drawLine(Offset(stemEndX, stemEndY + 0.5 * x),
                Offset(stemEndX + x, stemEndY + 2 * x), paint);
          }
          // draws the third flag on shorter notes
          if (currentNote.duration != 16 && currentNote.duration != 24) {
            if (position >= 0) {
              // draws the flag point up
              canvas.drawLine(Offset(stemEndX, stemEndY - x),
                  Offset(stemEndX + x, stemEndY - 2.5 * x), paint);
            } else {
              // draws the flag pointing down
              canvas.drawLine(Offset(stemEndX, stemEndY + x),
                  Offset(stemEndX + x, stemEndY + 2.5 * x), paint);
            }
          }
        }
      }
    }
    if (currentNote.dotted == 1) {
      paint.style = PaintingStyle.fill;
      // draws the dot for dotted notes
      canvas.drawCircle(Offset(xPosition + noteWidth * x, y), 0.15 * x, paint);
    }
    if (position > 2.5 || position < -2.5) {
      int counter = position.abs().floor();
      while (counter > 2.5) {
        double ledgerLineY;
        if (position > 2.5) {
          ledgerLineY = -counter *
              x; // draws ledger lines for notes above the middle staff line
        } else {
          ledgerLineY = counter *
              x; // draws ledger lines for notes below the middle staff line
        }
        canvas.drawLine(Offset(xPosition - 0.75 * noteWidth * x, ledgerLineY),
            Offset(xPosition + 0.75 * noteWidth * x, ledgerLineY), paint);
        counter--;
      }
    }
    paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;
    if (currentNote.measureProgress == timeSignatureTop / timeSignatureBottom) {
      // draws the measure lines
      canvas.drawLine(
          Offset(xPosition + 20, -2 * x), Offset(xPosition + 20, 2 * x), paint);
    }
  }

  /// Draws a notehead
  void drawNotehead(
      Canvas canvas, Paint paint, double x, double xPosition, double y) {
    canvas.save();
    canvas.translate(xPosition, y);
    canvas.rotate(-rotationAngle);
    canvas.translate(0, -y);
    Rect noteHead = Offset(-halfNoteWidth * x, y - noteHeight * x) &
        Size(ellipseWidth * x, x);
    canvas.drawOval(noteHead, paint);
    canvas.restore();
  }

  /// Draws a rest based on the duration of the current note
  void drawRest(Note currentNote, double xPosition, Canvas canvas, Paint paint,
      double x) {
    if (currentNote.duration == 1 || currentNote.duration == 0) {
      // draws a whole rest
      drawRectRest(canvas, paint, x, xPosition, 0);
    } else if (currentNote.duration == 2 || currentNote.duration == 3) {
      // draws a half rest
      drawRectRest(canvas, paint, x, xPosition, -0.5 * x);
    } else if (currentNote.duration == 4 || currentNote.duration == 6) {
      // draws a quarter rest
      var center = Offset(xPosition, -(3 / 4) * x);
      // draws the top line of rest
      canvas.drawLine(
          Offset(center.dx, center.dy),
          Offset(center.dx - ((0.75 * x) / sqrt(2)),
              center.dy - ((0.75 * x) / sqrt(2)) * sqrt(3)),
          paint);

      // draws the middle line of rest
      canvas.drawLine(Offset(center.dx, center.dy),
          Offset(center.dx - 0.5 * x, center.dy + 0.5 * x), paint);

      var lastX = center.dx -
          0.5 * x +
          ((0.75 * x) / sqrt(2)); // end x position of bottom line
      var lastY = center.dy + 0.5 * x + ((0.75 * x) / sqrt(2)) * sqrt(3);

      // draws the bottom line of rest
      canvas.drawLine(Offset(center.dx - 0.5 * x, center.dy + 0.5 * x),
          Offset(lastX, lastY), paint);

      paint.style =
          PaintingStyle.stroke; // to keep arc section of rest unfilled
      canvas.save();
      canvas.translate(xPosition, 0);
      canvas.rotate(pi / 3);
      canvas.translate(0, 0);
      // arc section of rest
      Rect arc = Offset(0.22 * x, 0.33 * x) & Size(x, 0.75 * x);
      canvas.drawArc(arc, 0.4 * pi / 3, 1.3 * pi, false, paint);
      canvas.restore();
    } else {
      // draws an eighth rest
      drawEighthRest(canvas, xPosition, x, paint, 0, 0);
      // draws a sixteenth rest
      if (currentNote.duration == 16 || currentNote.duration == 24) {
        drawEighthRest(canvas, xPosition, x, paint, x, -1.1 * x * cos(pi / 3));
      }
      // draws a thirtysecond rest
      if (currentNote.duration == 32 || currentNote.duration == 48) {
        drawEighthRest(canvas, xPosition, x, paint, x, -1.1 * x * cos(pi / 3));
        drawEighthRest(canvas, xPosition, x, paint, -x, 1.1 * x * cos(pi / 3));
      }
    }
    if (currentNote.dotted == 1) {
      // draws the dot for dotted rests
      paint.style = PaintingStyle.fill;
      if (currentNote.duration == 0) {
        canvas.drawCircle(
            Offset(xPosition + noteWidth * x, 0.35 * x), 0.15 * x, paint);
      } else if (currentNote.duration == 6) {
        canvas.drawCircle(
            Offset(xPosition + noteWidth * x - 0.75 * x, -0.35 * x),
            0.15 * x,
            paint);
      } else {
        canvas.drawCircle(
            Offset(xPosition + noteWidth * x, -0.35 * x), 0.15 * x, paint);
      }
    }
    if (currentNote.measureProgress == timeSignatureTop / timeSignatureBottom) {
      // draws the measure lines
      canvas.drawLine(
          Offset(xPosition + 20, -2 * x), Offset(xPosition + 20, 2 * x), paint);
    }
  }

  /// Draws a rest rectangular in shape (i.e. whole or half rests)
  void drawRectRest(
      Canvas canvas, Paint paint, double x, double xPosition, double y) {
    Rect rectRest = Offset(xPosition - 0.5 * x, y) &
        Size(noteWidth * x, 0.5 * x); // rest has the same width as notes
    paint.style = PaintingStyle.fill;
    canvas.drawRect(rectRest, paint);
  }

  /// Draws an eighth rest
  void drawEighthRest(Canvas canvas, double xPosition, double x, Paint paint,
      double y, double xOffset) {
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(xPosition + xOffset, -0.5 * x + y), 0.3 * x, paint);
    paint.style = PaintingStyle.stroke;
    Rect arc = Offset(-0.3 * x + xPosition + xOffset, -1.42 * x + y) &
        Size(1.2 * x, 1.2 * x);
    canvas.drawArc(arc, pi / 6, pi / 2, false, paint);
    canvas.drawLine(Offset(xPosition + 0.8 * x + xOffset, -0.5 * x + y),
        Offset(xPosition + xOffset, x + y), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}