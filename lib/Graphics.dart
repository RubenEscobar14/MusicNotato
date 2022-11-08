// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:music_notato/models/note.dart';

class Graphics extends CustomPainter {
  // String noteName;
  double x; // Current x-direction offset; determines positioning of note in the x-direction
  List<Note> noteList;
  List<double> notePosition;

  String currentClef;
  List<double> trebleBasePositions = [-3, -2.5, -2, -1.5, -1, -0.5, 0];
  List<double> altoBasePositions = [0, 0.5, 1, 1.5, 2, 2.5, 3];
  List<double> bassBasePositions = [3, 3.5, 4, 4.5, 5, 5.5, 6];

  int signature;
  int signature_;

  Graphics(this.x, this.noteList, this.notePosition, this.currentClef,
      this.signature, this.signature_);

  double calculateBasePosition(String noteName, String currentClef) {
    if (noteName == 'c') {
      if (currentClef == 'treble') {
        return trebleBasePositions[0];
      } else if (currentClef == 'alto') {
        return altoBasePositions[0];
      } else {
        return bassBasePositions[0];
      }
    } else if (noteName == 'd') {
      if (currentClef == 'treble') {
        return trebleBasePositions[1];
      } else if (currentClef == 'alto') {
        return altoBasePositions[1];
      } else {
        return bassBasePositions[1];
      }
    } else if (noteName == 'e') {
      if (currentClef == 'treble') {
        return trebleBasePositions[2];
      } else if (currentClef == 'alto') {
        return altoBasePositions[2];
      } else {
        return bassBasePositions[2];
      }
    } else if (noteName == 'f') {
      if (currentClef == 'treble') {
        return trebleBasePositions[3];
      } else if (currentClef == 'alto') {
        return altoBasePositions[3];
      } else {
        return bassBasePositions[3];
      }
    } else if (noteName == 'g') {
      if (currentClef == 'treble') {
        return trebleBasePositions[4];
      } else if (currentClef == 'alto') {
        return altoBasePositions[4];
      } else {
        return bassBasePositions[4];
      }
    } else if (noteName == 'a') {
      if (currentClef == 'treble') {
        return trebleBasePositions[5];
      } else if (currentClef == 'alto') {
        return altoBasePositions[5];
      } else {
        return bassBasePositions[5];
      }
    } else {
      if (currentClef == 'treble') {
        return trebleBasePositions[6];
      } else if (currentClef == 'alto') {
        return altoBasePositions[6];
      } else {
        return bassBasePositions[6];
      }
    }
  }

  double calculatePosition(
      NoteLetter noteName, int octave, String currentClef) {
    double basePosition = calculateBasePosition(noteName.name, currentClef);
    return basePosition + 3.5 * (octave - 4);
  }

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;
    double x = size.height / 4;

    // Draws the staff
    canvas.drawLine(Offset(0, -2 * x), Offset(size.width, -2 * x), paint);
    canvas.drawLine(Offset(0, -x), Offset(size.width, -x), paint);
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(0, x), Offset(size.width, x), paint);
    canvas.drawLine(Offset(0, 2 * x), Offset(size.width, 2 * x), paint);

    //beat choosing frame
    var points = [
      //upper line
      Offset(10, -2 * x - 5),
      Offset(15, -2 * x - 5),
      Offset(20, -2 * x - 5),
      Offset(25, -2 * x - 5),
      Offset(30, -2 * x - 5),
      //left line
      Offset(5, -2 * x - 5),
      Offset(5, -2 * x),
      Offset(5, -2 * x + 5),
      Offset(5, -2 * x + 10),
      Offset(5, -2 * x + 15),
      Offset(5, -2 * x + 20),
      Offset(5, 2 * x - 20),
      Offset(5, 2 * x - 15),
      Offset(5, 2 * x - 5),
      Offset(5, 2 * x),
      Offset(5, 2 * x + 5),
      //bottom line
      Offset(10, 2 * x + 5),
      Offset(15, 2 * x + 5),
      Offset(20, 2 * x + 5),
      Offset(25, 2 * x + 5),
      Offset(30, 2 * x + 5),
      //right line
      Offset(35, -2 * x - 5),
      Offset(35, -2 * x),
      Offset(35, -2 * x + 5),
      Offset(35, -2 * x + 10),
      Offset(35, -2 * x + 15),
      Offset(35, -2 * x + 20),
      Offset(35, 2 * x - 20),
      Offset(35, 2 * x - 15),
      Offset(35, 2 * x - 5),
      Offset(35, 2 * x),
      Offset(35, 2 * x + 5),
    ];
    //draw the beat choosing frame
    paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPoints(PointMode.points, points, paint);

    //draw signature
    var textPainter = TextPainter(
        text: TextSpan(
          text: '${signature}\n${signature_}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center);
    textPainter.layout();
    textPainter.paint(canvas,
        Offset(20 - (textPainter.width / 2), 0 - (textPainter.height / 2)));

    for (int i = 0; i < noteList.length; i++) {
      Note currentNote = noteList[i];
      double xPosition =
          notePosition[i]; // x-coordinate of the note to be drawn
      double position = calculatePosition(currentNote.note, noteList[i].octave,
          currentClef); // position of the current note on the staff
      double y = -position * x; // y-coordinate of the note to be drawn

      if (currentNote.duration == 1 || currentNote.duration == 2 || currentNote.duration == 0 || currentNote.duration == 3) {
        // draws an unfilled notehead (notehead for whole and half notes)
       paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.save();
        canvas.translate(xPosition, y);
        canvas.rotate(-pi/9);
        canvas.translate(0, -y);
        Rect noteHead = Offset(-(748/1024)*x*cos(pi/9), y-(748/512)*x*sin(pi/9)) & Size((748 / 512) * x, x);
        canvas.drawOval(noteHead, paint);
        canvas.restore();
      } 
      else {
        // draws a filled notehead (notehead for all other notes)
        paint = Paint()
          ..style = PaintingStyle.fill
          ..strokeWidth = 2.0;
        canvas.save();
        canvas.translate(xPosition, y);
        canvas.rotate(-pi/9);
        canvas.translate(0, -y);
        Rect noteHead = Offset(-(748/1024)*x*cos(pi/9), y-(748/512)*x*sin(pi/9)) & Size((748 / 512) * x, x);
        canvas.drawOval(noteHead, paint);
        canvas.restore();
      }
      if (currentNote.duration != 1 && currentNote.duration != 0) {
        double stemEndX;
        double stemEndY;
        if (position > 0) { // draws a stem going down
          stemEndX = xPosition-(748/1024)*x*cos(pi/9)+paint.strokeWidth/2;
          if(position > 3) {
            stemEndY = 0;
          }
          else {
            stemEndY = y+3.5*x;
          }
          canvas.drawLine(Offset(xPosition-(748/1024)*x*cos(pi/9)+paint.strokeWidth/2,y+(748/1024)*x*sin(pi/9)),Offset(xPosition-(748/1024)*x*cos(pi/9)+paint.strokeWidth/2,stemEndY),paint);
        }
        else { // draws a stem going up
          stemEndX = xPosition+(748/1024)*x*cos(pi/9);
          if(position < -3) {
            stemEndY = 0;
          }
          else {
            stemEndY = y-3.5*x;
          }
          canvas.drawLine(Offset(stemEndX,y-(748/1024)*x*sin(pi/9)),Offset(xPosition+(748/1024)*x*cos(pi/9),stemEndY),paint);
        }
        if (currentNote.duration != 4 && currentNote.duration != 2 && currentNote.duration != 6 && currentNote.duration != 3) {
          if (position > 0) {
            canvas.drawLine(Offset(stemEndX, stemEndY), Offset(stemEndX + x, stemEndY - 1.5 * x), paint);
          } 
          else {
            canvas.drawLine(Offset(stemEndX, stemEndY), Offset(stemEndX + x, stemEndY + 1.5 * x), paint);
          }
          if (currentNote.duration != 8 && currentNote.duration != 12) {
            if (position > 0) {
              canvas.drawLine(Offset(stemEndX, stemEndY - 0.5 * x), Offset(stemEndX + x, stemEndY - 2 * x), paint);
            } 
            else {
              canvas.drawLine(Offset(stemEndX, stemEndY + 0.5 * x), Offset(stemEndX + x, stemEndY + 2 * x), paint);
            }
            if (currentNote.duration != 16 && currentNote.duration != 24) {
              if (position > 0) {
                canvas.drawLine(Offset(stemEndX, stemEndY - x), Offset(stemEndX + x, stemEndY - 2.5 * x), paint);
              } 
              else {
                canvas.drawLine(Offset(stemEndX, stemEndY + x), Offset(stemEndX + x, stemEndY + 2.5 * x), paint);
              }
            }
          }
        }
      }
      if (currentNote.dotted == 1) {
        canvas.drawCircle(Offset(xPosition+(748/512)*x*cos(pi/9), y), 0.15 * x, paint);
      }
      if (position > 2.5) {
        int counter = position.floor();
        while (counter > 2.5) {
          double ledgerLineY = -counter * x;
          canvas.drawLine(Offset(xPosition-0.75*(748/512)*x*cos(pi/9), ledgerLineY),
              Offset(xPosition+0.75*(748/512)*x*cos(pi/9), ledgerLineY), paint);
          counter--;
        }
      }
      if (position < -2.5) {
        double positivePosition = -position;
        int counter = positivePosition.floor();
        while (counter > 2.5) {
          double ledgerLineY = counter * x;
          canvas.drawLine(Offset(xPosition-0.75*(748/512)*x*cos(pi/9), ledgerLineY),
              Offset(xPosition+0.75*(748/512)*x*cos(pi/9), ledgerLineY), paint);
          counter--;
        }
      }
      if (currentNote.complete == signature / signature_) {
        canvas.drawLine(Offset(xPosition+20, -2 * x),
            Offset(xPosition+20, 2 * x), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}