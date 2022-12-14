# MusicNotato
## Contributors
Ruben Escobar, Olivia Laske, Nate Small, Ziyi Wang

## Product Description
Currently, beginner-friendly music notation software platforms are generally unavailable, and the user is expected to have a solid foundation of music notation. In order to address this problem, MusicNotato is an app designed to provide an easy-to-use and intuitive interface for music notation. With the app, users can write basic compositions in C major or A minor with the option to change the time signature.

## Languages and Platforms
* Flutter version 3.3.2
* Dart version 2.18.1
* Xcode version 13.4.1
* CocoaPods version 1.11.3
* iOS
* Android

The app uses Flutter in order to be compatible on multible devices. The app supports mobile (iOS, Android), web (Chrome, macOS), and desktop (macOS) versions.

## Setup and Installation
To install, clone this repository onto Desktop.

![Alt text](Xcode_running.png)

To run on iOS, connect the mobile device to the device with the repository. Navigate to the Runner.xcworkspace file (located in the ios folder of the project) and open it in Xcode. At the top of the file next to the Flutter icon is an option to change the device. Change this device to the mobile one connected to Desktop. To run, click the run button in the upper left hand corner. You may need to trust yourself as the developer, which you can do in Settings > General > Device Management on iOS devices.

To run on Android, run the following in a terminal window in your project directory:
```
flutter build apk
```
Then, move the newly built APK onto an Android phone and install it.

## Features
* Composing
    * Users choose a note with a certain rhythm and can then adjust the pitch or octave
* Playback
    * Users can use the playback button in order to hear their composition
* Dotted rhythms
    * Dotted rhythms for every type of note from whole to thirtysecond notes are availble
    * The software turns the button black if it is in use
* Rests
    * Rests for every type of note from whole to thirtysecond notes are available
    * The software turns the button black if it is in use
* Time signature
    * The number of beats in a measure can be any integer between 1 and 12, inclusive
    * The unit of beat can be 2 (half note), 4 (quarter note), 8 (eighth note), and 16 (sixteenth note)
    * The software lightens a rhythm button's color if it cannot be used due to overflowing of a measure

## Acknowledgements
* Special thanks to Bret Jackson for guiding us through this course
* Also thanks to Paul Cantrell for software consultation
* https://www.mpa.org/wp-content/uploads/2018/06/standard-practice-engraving.pdf was referenced for music notation rules
* http://faculty.washington.edu/garmar/notehead_specs.pdf was referenced for note head design
* https://theremin.music.uiowa.edu/MISpiano.html is where we got the piano audio files from
* https://cloudconvert.com/ was used to convert unsupported aiff files to flac
* https://github.com/anars/blank-audio is where we get the rest audio file from
