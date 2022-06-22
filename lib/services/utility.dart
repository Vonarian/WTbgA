import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
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

  static Future<OpenRGB> checkOpenRGb() async {
    Directory docDir = await getApplicationDocumentsDirectory();
    String docPath = docDir.path;
    File openRGBFile =
        File('$docPath\\WTbgA\\out\\OpenRGB Windows 64-bit\\OpenRGB.exe');
    OpenRGB openRGB =
        OpenRGB(exists: await openRGBFile.exists(), path: openRGBFile.path);
    return openRGB;
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
}

class OpenRGB {
  final String path;
  final bool exists;

  const OpenRGB({
    required this.path,
    required this.exists,
  });

  @override
  String toString() {
    return 'OpenRGB ==> (path: $path, exists: $exists)';
  }
}
