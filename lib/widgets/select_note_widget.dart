import 'package:flutter/material.dart';

//adapted from stackoverflow at
//https://stackoverflow.com/questions/44534757/how-do-detect-where-a-user-tapped-on-my-screen-with-flutter

class SelectNoteWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () => print('tapped!'),
      onTapDown: (TapDownDetails details) => _onTapDown(details),
      //onTapUp: (TapUpDetails details) => _onTapUp(details),
    );
  }

  _onTapDown(TapDownDetails details) {
    double x = details.globalPosition.dx;
    double y = details.globalPosition.dy;
    // or user the local position method to get the offset
    print(details.localPosition);
    print("tap down " + x.toString() + ", " + y.toString());
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
