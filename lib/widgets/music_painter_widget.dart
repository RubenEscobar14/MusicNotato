import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:music_notato/widgets/note_widget.dart';
import 'package:music_notato/widgets/staff_widget.dart';
import 'package:music_notato/models/score.dart';

typedef SelectNewNote = void Function(double x);

class MusicPainterWidget extends StatelessWidget {
  List<double> xPositions;
  double xPosition;
  int signatureTop;
  int signatureBottom;
  Score _score;
  int selectedNoteIndex;

  final SelectNewNote selectNewNotefunc;

  double tappedPositionX = -1;
  double tappedPositionY = -1;

  MusicPainterWidget(
      this.xPosition,
      this.xPositions,
      this.signatureTop,
      this.signatureBottom,
      this._score,
      this.selectedNoteIndex,
      void this.selectNewNotefunc(double x));

  // builds the widget that handles taps, and contians the painters for the staff and notes
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomPaint(
          size: Size(
              xPosition < MediaQuery.of(context).size.width
                  ? MediaQuery.of(context).size.width
                  : xPosition,
              50),
          painter: StaffWidget('treble', signatureTop, signatureBottom),
        ),
        GestureDetector(
          onTap: () => print('tapped!'),
          onTapDown: (TapDownDetails details) => _onTapDown(details),
          child: CustomPaint(
            size: Size(_score.length * 50, 50),
            painter: NoteWidget(_score.getAllNotes(), xPositions, 'treble',
                signatureTop, signatureBottom, selectedNoteIndex),
          ),
        ),
      ],
    );
  }

  //gets the x position from tap, and makes the home_page update its selected note
  _onTapDown(TapDownDetails details) {
    tappedPositionX = details.localPosition.dx;
    selectNewNotefunc(tappedPositionX);
  }
}
