enum NoteLetter { a, b, c, d, e, f, g, r }

class Note {
  // a, b, c, d, e, f, g, r (for rest)
  NoteLetter note;

  // Which octave should be played - Middle C is C4.
  int octave;

  // if duration is x, this note is a 1/2^x note.
  // The above comment isn't true; should we make it true?
  int duration;

  // 0 if not dotted, 1 if dotted
  int dotted;

  // -2 is double flat, -1 is flat, 0 is natural, 1 is sharp, 2 is double sharp
  int accidental;

  // Tracks how far this note is in its measure
  double complete;

  /// Creates a Note object with all properties specified
  Note(this.note, this.octave, this.duration, this.dotted, this.accidental,
      this.complete);

  /// Creates a rest, only requiring duration and complete to be specified
  Note.rest(this.duration, this.dotted, this.complete)
      : note = NoteLetter.r,
        accidental = 0,
        octave = 0;

  // increases the note value by n, raising octave if necissery
  void increasePitch(int n) {
    for (int i = n; i > 0; i--) {
      if (note == NoteLetter.a) {
        setNote(NoteLetter.b);
      } else if (note == NoteLetter.b) {
        setNote(NoteLetter.c);
      } else if (note == NoteLetter.c) {
        setNote(NoteLetter.d);
      } else if (note == NoteLetter.d) {
        setNote(NoteLetter.e);
      } else if (note == NoteLetter.e) {
        setNote(NoteLetter.f);
      } else if (note == NoteLetter.f) {
        setNote(NoteLetter.g);
      } else if (note == NoteLetter.g) {
        setNote(NoteLetter.a);
      } else {
        setNote(NoteLetter.r);
      }
    }
  }

  void setNote(NoteLetter letter) {
    note = letter;
  }

  void setDuration(int dur) {
    duration = dur;
  }

  void setDotted(int dot) {
    dotted = dot;
  }

  void setAccidental(int acc) {
    accidental = acc;
  }

  void setOctave(int oct) {
    if (oct > 8) {
      octave = 8;
    } else if (oct < 0) {
      octave = 0;
    }
    octave = oct;
  }

  NoteLetter getNote() {
    return note;
  }

  String getNoteName() {
    return note.toString().toUpperCase();
  }

  int getDotted() {
    return dotted;
  }

  int getOctave() {
    return octave;
  }

  int getDuration() {
    return duration;
  }

  int getAccidental() {
    return accidental;
  }

  /// I think I've used this method wrong. I can't really give it a helpful description
  /// until I figure out how to use it
  Note.fromJson(Map<String, dynamic> json)
      : note = json['note'],
        octave = json['octave'],
        duration = json['duration'],
        accidental = json['accidental'],
        dotted = json['dotted'],
        complete = json['complete'];

  /// Tells the json encoder how to store note properties in the save file.
  Map<String, dynamic> toJson() => {
        'note': note.name,
        'octave': octave,
        'duration': duration,
        'accidental': accidental,
        'dotted': dotted,
        'complete': complete,
      };

  @override
  String toString() {
    return "[note: " +
        note.toString() +
        ", dur: " +
        duration.toString() +
        ", oct: " +
        octave.toString() +
        ", dot: " +
        dotted.toString() +
        ", acc: " +
        accidental.toString() +
        "]";
  }
}
