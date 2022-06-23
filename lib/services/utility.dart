import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:win32/win32.dart';

class AppUtil {
  static Future<String> createFolderInAppDocDir(String path) async {
    final Directory appDocDirFolder = Directory(path);

    try {
      if (await appDocDirFolder.exists()) {
        return appDocDirFolder.path;
      } else {
        final Directory appDocDirNewFolder =
            await appDocDirFolder.create(recursive: true);
        return appDocDirNewFolder.path;
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  static void playSound(String path) {
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

  static Future<String> runPowerShellScript(
      String scriptPath, List<String> argumentsToScript) async {
    var process = await Process.start(
        'Powershell.exe', ['-File', scriptPath, ...argumentsToScript]);
    String finalString = '';

    await for (var line in process.stdout.transform(utf8.decoder)) {
      finalString += line;
    }
    process.kill();
    return finalString;
  }
}
