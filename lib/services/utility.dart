import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:archive/archive.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:win32/win32.dart';
import 'package:wtbgassistant/main.dart';
import 'package:wtbgassistant/screens/widgets/loading_widget.dart';

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
      if (kDebugMode) {
        print('WAV file missing.');
      }
    } else {
      final sound = TEXT(path);
      final result = PlaySound(sound, NULL, SND_FILENAME | SND_SYNC);

      if (result != TRUE) {
        if (kDebugMode) {
          print('Sound playback failed.');
        }
      }
      free(sound);
    }
  }

  static Future<String> runPowerShellScript(
      String scriptPath, List<String> argumentsToScript) async {
    var process = await Process.start(
        'Powershell.exe', [...argumentsToScript, '-File', scriptPath]);
    String finalString = '';

    await for (var line in process.stdout.transform(utf8.decoder)) {
      finalString += line;
    }
    return finalString;
  }

  static Future<String> getAppDocsPath() async {
    Directory docDir = await getApplicationDocumentsDirectory();
    String docPath = docDir.path;
    Directory docWTbgA =
        await Directory('$docPath\\WTbgA').create(recursive: true);
    String docWTbgAPath = docWTbgA.path;
    return docWTbgAPath;
  }

  static Future<String> getOpenRGBFolderPath() async {
    String appDocsPath = await AppUtil.getAppDocsPath();
    Directory openRGBDir =
        await Directory('$appDocsPath\\OpenRGB').create(recursive: true);
    String openRGBPath = openRGBDir.path;
    return openRGBPath;
  }

  static Future<String> getOpenRGBExecutablePath(BuildContext context) async {
    String openRGBPath = await AppUtil.getOpenRGBFolderPath();
    File openRGBExecutable =
        File('$openRGBPath\\OpenRGB Windows 64-bit\\OpenRGB.exe');
    String docsPath = await AppUtil.getAppDocsPath();
    if (!await openRGBExecutable.exists()) {
      await showLoading(
          context: context,
          future: dio.download(
              'https://github.com/Vonarian/WTbgA/releases/download/2.6.2.0/OpenRGB.zip',
              '$docsPath\\OpenRGB.zip'),
          message: 'Downloading OpenRGB...');
      final File filePath = File('$docsPath\\OpenRGB.zip');
      final Uint8List bytes = await filePath.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          File('${p.dirname(filePath.path)}\\OpenRGB\\$filename')
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory('${p.dirname(filePath.path)}\\OpenRGB\\$filename')
              .create(recursive: true);
        }
      }
    }
    String openRGBExecutablePath = openRGBExecutable.path;
    return openRGBExecutablePath;
  }
}
