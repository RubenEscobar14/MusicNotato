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

    // draws the time signature graphic
    var textPainter = TextPainter(
        text: TextSpan(
          text: '${timeSignatureTop}\n${timeSignatureBottom}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontFamily: 'BravuraText'
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