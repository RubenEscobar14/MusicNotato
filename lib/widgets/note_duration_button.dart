import 'package:flutter/material.dart';

typedef DurationChangeCallback = Function(int duration);

class NoteDurationButton extends StatefulWidget {
  final int duration;
  final String buttonText;
  final bool isSelected;
  final DurationChangedCallback onDurationChanged;

  NoteDurationButton({
    required this.duration,
    required this.buttonText,
    required this.isSelected, 
    // required void onDurationChanged, 
    required this.onDurationChanged,
  }) :super(key: ObjectKey(duration));

  @override
  State<NoteDurationButton> createState() => _NoteDurationButtonState();
}

class DurationChangedCallback {
  callBack() {
    
  }
}

class _NoteDurationButtonState extends State<NoteDurationButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // widget.onDurationChanged;
      },
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(widget.isSelected ? Colors.green : Colors.blue)),
      child: Text(widget.buttonText),
    );
  }
}