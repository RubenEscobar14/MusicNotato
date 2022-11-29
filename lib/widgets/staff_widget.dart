import 'dart:ui';
import 'package:flutter/material.dart';

/// Class that draws the staff and semi-permanent elements (e.g. clef, time signature) to the canvas
class StaffWidget extends CustomPainter {
  String currentClef;

  int timeSignatureTop; // number of beats per measure
  int timeSignatureBottom; // unit of beat

  /// Constructor
  StaffWidget(this.currentClef, this.timeSignatureTop, this.timeSignatureBottom);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;
    double x = size.height / 4; // distance between two staff lines

    // draws the staff
    canvas.drawLine(Offset(0, -2 * x), Offset(size.width, -2 * x), paint);
    canvas.drawLine(Offset(0, -x), Offset(size.width, -x), paint);
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(0, x), Offset(size.width, x), paint);
    canvas.drawLine(Offset(0, 2 * x), Offset(size.width, 2 * x), paint);

    // time signature graphic frame
    var points = [
      // upper line
      Offset(10, -2 * x - 5),
      Offset(15, -2 * x - 5),
      Offset(20, -2 * x - 5),
      Offset(25, -2 * x - 5),
      Offset(30, -2 * x - 5),
      // left line
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
      // bottom line
      Offset(10, 2 * x + 5),
      Offset(15, 2 * x + 5),
      Offset(20, 2 * x + 5),
      Offset(25, 2 * x + 5),
      Offset(30, 2 * x + 5),
      // right line
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

    // draws the time signature graphic frame
    paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPoints(PointMode.points, points, paint);

    // draws the time signature graphic
    var textPainter = TextPainter(
        text: TextSpan(
          text: '${timeSignatureTop}\n${timeSignatureBottom}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center);
    textPainter.layout();
    textPainter.paint(canvas, Offset(20 - (textPainter.width / 2), 0 - (textPainter.height / 2)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}