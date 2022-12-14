import 'package:flutter/material.dart';

/// Class that determines which note is selected based on where the user taps
/// Adapted from StackOverflow at https://stackoverflow.com/questions/44534757/how-do-detect-where-a-user-tapped-on-my-screen-with-flutter
class SelectNoteWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print('tapped!'),
      onTapDown: (TapDownDetails details) => _onTapDown(details),
      // onTapUp: (TapUpDetails details) => _onTapUp(details),
    );
  }

  /// Records the location of the tap
  _onTapDown(TapDownDetails details) {
    double x = details.globalPosition.dx;
    double y = details.globalPosition.dy;
    // or user the local position method to get the offset
    print(details.localPosition);
    print("tap down $x, $y");
  }

  // _onTapUp(TapUpDetails details) {
  //   var x = details.globalPosition.dx;
  //   var y = details.globalPosition.dy;
  //   // or user the local position method to get the offset
  //   print(details.localPosition);
  //   print("tap up " + x.toString() + ", " + y.toString());
  // }
}

class tapPostionNotifier extends ChangeNotifier {}