import 'package:flutter/cupertino.dart';
import 'package:music_notato/widgets/note_widget.dart';
import 'package:music_notato/widgets/staff_widget.dart';
import 'package:music_notato/models/score.dart';

typedef SelectNewNote = void Function(double x);

/// Class that builds the graphics containing both the staff and notes
class MusicPainterWidget extends StatelessWidget {
  List<double> xPositions;
  double xPosition;
  int signatureTop;
  int signatureBottom;
  Score _score;
  int selectedNoteIndex;

  final SelectNewNote selectNewNotefunc;

  double tappedPositionX = -1; // x position of where the screen has been tapped
  double tappedPositionY = -1; // y position of where the screen has been tapped

  /// Constructor
  MusicPainterWidget(
      this.xPosition,
      this.xPositions,
      this.signatureTop,
      this.signatureBottom,
      this._score,
      this.selectedNoteIndex,
      void this.selectNewNotefunc(double x));

  /// Builds the widget that handles taps. Contians the painters for the staff and notes
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomPaint( // creates the staff
          size: Size(
              xPosition < MediaQuery.of(context).size.width
                  ? MediaQuery.of(context).size.width
                  : xPosition,
              50),
          painter: StaffWidget('treble', signatureTop, signatureBottom),
        ),
        GestureDetector( // creates the ability to select notes
          onTap: () => print('tapped!'),
          onTapDown: (TapDownDetails details) => _onTapDown(details),
          child: CustomPaint(
            size: Size(_score.length * 50, 50),
            painter: NoteWidget(_score.allNotes, xPositions, 'treble', // creates the notes
                signatureTop, signatureBottom, selectedNoteIndex),
          ),
        ),
      ],
    );
  }

  /// Gets the x position from tap and makes the home_page update its selected note
  _onTapDown(TapDownDetails details) {
    tappedPositionX = details.localPosition.dx;
    selectNewNotefunc(tappedPositionX);
  }
}