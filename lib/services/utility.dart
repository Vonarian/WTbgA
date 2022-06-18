import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AppUtil {
  static Future<String> createFolderInAppDocDir(String path) async {
    //Get this App Document Directory

    //App Document Directory + folder name
    final Directory _appDocDirFolder = Directory(path);

    try {
      if (await _appDocDirFolder.exists()) {
        //if folder already exists return path
        return _appDocDirFolder.path;
      } else {
        //if folder not exists create folder and then return its path
        final Directory _appDocDirNewFolder =
            await _appDocDirFolder.create(recursive: true);
        return _appDocDirNewFolder.path;
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
