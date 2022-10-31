class Note {
  // a, b, c, d, e, f, g, r (for rest)
  String note;

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
  Note.rest(this.duration, this.complete)
      : note = 'r',
        accidental = 0,
        octave = 0,
        dotted = 0;

  String getNote() {
    return note;
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

  /// Doesn't seem to work? If you're seeing this comment, I forgot to try
  /// deleting it before pushing. Please remind me (Ruben)!
  Note.fromJson(Map<String, dynamic> json)
      : note = json['note'],
        octave = json['octave'],
        duration = json['duration'],
        accidental = json['accidental'],
        dotted = json['dotted'],
        complete = json['complete'];

  /// Tells the json encoder how to store note properties in the save file.
  Map<String, dynamic> toJson() => {
        'note': note,
        'octave': octave,
        'duration': duration,
        'accidental': accidental,
        'dotted': dotted,
        'complete': complete,
      };
}
