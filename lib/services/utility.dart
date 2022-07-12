import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:win32/win32.dart';
import 'package:wtbgassistant/main.dart';
import 'package:wtbgassistant/screens/widgets/loading_widget.dart';

class AppUtil {
  static final versionPath =
      '${p.dirname(Platform.resolvedExecutable)}\\data\\flutter_assets\\assets\\Version\\version.txt';
  static final defaultBeepPath =
      p.joinAll([p.dirname(Platform.resolvedExecutable), 'data\\flutter_assets\\assets', 'sounds\\beep.wav']);
  static final String deviceIPPath =
      p.joinAll([p.dirname(Platform.resolvedExecutable), 'data\\flutter_assets\\assets', 'scripts\\deviceIP.ps1']);
  static final String windowPath =
      p.joinAll([p.dirname(Platform.resolvedExecutable), 'data\\flutter_assets\\assets', 'scripts\\getWindow.ps1']);

  static Future<String> createFolderInAppDocDir(String path) async {
    final Directory appDocDirFolder = Directory(path);

    try {
      if (await appDocDirFolder.exists()) {
        return appDocDirFolder.path;
      } else {
        final Directory appDocDirNewFolder = await appDocDirFolder.create(recursive: true);
        return appDocDirNewFolder.path;
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  static Future<void> playSound(String path) async {
    final file = await File(path).exists();

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

  static Future<String> runPowerShellScript(String scriptPath, List<String> argumentsToScript) async {
    var process = await Process.start('Powershell.exe', [...argumentsToScript, '-File', scriptPath]);
    String finalString = '';

    await for (var line in process.stdout.transform(utf8.decoder)) {
      finalString += line;
    }
    return finalString;
  }

  static Future<String> getAppDocsPath() async {
    Directory docDir = await getApplicationDocumentsDirectory();
    String docPath = docDir.path;
    Directory directory = Directory('$docPath\\WTbgA');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    String docWTbgAPath = directory.path;
    return docWTbgAPath;
  }

  static Future<String> getOpenRGBFolderPath() async {
    String appDocsPath = await AppUtil.getAppDocsPath();
    Directory openRGBDir = await Directory('$appDocsPath\\OpenRGB').create(recursive: true);
    String openRGBPath = openRGBDir.path;
    return openRGBPath;
  }

  static Future<String> getOpenRGBExecutablePath(BuildContext? context, bool check) async {
    String openRGBPath = await AppUtil.getOpenRGBFolderPath();
    File openRGBExecutable = File('$openRGBPath\\OpenRGB Windows 64-bit\\OpenRGB.exe');
    if (!await openRGBExecutable.exists() && check) {
      String docsPath = await AppUtil.getAppDocsPath();
      await showLoading(
          context: context!,
          future: dio.download(
              'https://github.com/Vonarian/WTbgA/releases/download/2.6.2.0/OpenRGB.zip', '$docsPath\\OpenRGB.zip'),
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
          Directory('${p.dirname(filePath.path)}\\OpenRGB\\$filename').create(recursive: true);
        }
      }
    }
    String openRGBExecutablePath = openRGBExecutable.path;
    return openRGBExecutablePath;
  }

  static Stream<String?> getWindow() async* {
    final stream = Stream.periodic(const Duration(milliseconds: 350), (_) async {
      String windowName = await AppUtil.runPowerShellScript(windowPath, ['-ExecutionPolicy', 'Bypass']);
      return windowName;
    });
    await for (var name in stream) {
      yield (await name).trim().replaceAll('\n', '');
    }
  }
}
