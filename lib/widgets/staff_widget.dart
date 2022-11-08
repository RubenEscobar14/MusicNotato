import 'dart:ui';
import 'package:flutter/material.dart';

class StaffWidget extends CustomPainter {
  String currentClef;

  int signature;
  int signature_;

  StaffWidget(this.currentClef, this.signature, this.signature_);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;
    double x = size.height / 4; // Distance between two staff lines

    // Draws the staff
    canvas.drawLine(Offset(0, -2 * x), Offset(size.width, -2 * x), paint);
    canvas.drawLine(Offset(0, -x), Offset(size.width, -x), paint);
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(0, x), Offset(size.width, x), paint);
    canvas.drawLine(Offset(0, 2 * x), Offset(size.width, 2 * x), paint);

    //节拍选择框
    var points = [
      //上面横线
      Offset(10, -2 * x - 5),
      Offset(15, -2 * x - 5),
      Offset(20, -2 * x - 5),
      Offset(25, -2 * x - 5),
      Offset(30, -2 * x - 5),
      //左边竖线
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
      //下面横线
      Offset(10, 2 * x + 5),
      Offset(15, 2 * x + 5),
      Offset(20, 2 * x + 5),
      Offset(25, 2 * x + 5),
      Offset(30, 2 * x + 5),
      //右边竖线
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
    //画节拍选择框
    paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPoints(PointMode.points, points, paint);

    //画节拍分子分母
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
    textPainter.paint(canvas, Offset(20 - (textPainter.width / 2), 0 - (textPainter.height / 2)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}