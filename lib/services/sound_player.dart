import 'dart:io';

import 'package:win32/win32.dart';

void playSound(String path) {
  final file = File(path).existsSync();

  if (!file) {
    print('WAV file missing.');
  } else {
    final sound = TEXT(path);
    final result = PlaySound(sound, NULL, SND_FILENAME | SND_SYNC);

    if (result != TRUE) {
      print('Sound playback failed.');
    }
    free(sound);
  }
}
