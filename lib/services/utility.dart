import 'dart:io';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:window_watcher/window_watcher.dart';

import '../main.dart';
import '../screens/widgets/loading_widget.dart';

final RegExp wtTitleRegex = RegExp(
  r'^War Thunder(?: \(DirectX 12, 64bit\))?(?: - (?:In battle|Waiting for game|Loading|Test Flight))?$',
  caseSensitive: false,
);

class AppUtil {
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
    Directory openRGBDir = await Directory(
      '$appDocsPath\\OpenRGB',
    ).create(recursive: true);
    String openRGBPath = openRGBDir.path;
    return openRGBPath;
  }

  static Future<String> getOpenRGBExecutablePath(
    BuildContext? context,
    bool check,
  ) async {
    String openRGBPath = await getOpenRGBFolderPath();
    File openRGBExecutable = File(
      '$openRGBPath\\OpenRGB Windows 64-bit\\OpenRGB.exe',
    );
    if (!(await openRGBExecutable.exists()) && check && context != null) {
      String docsPath = await AppUtil.getAppDocsPath();
      await showLoading(
        // ignore: use_build_context_synchronously
        context: context,
        future: dio.download(
          'https://openrgb.org/releases/release_0.9/OpenRGB_0.9_Windows_64_b5f46e3.zip',
          '$docsPath\\OpenRGB.zip',
        ),
        message: 'Downloading OpenRGB...',
      );
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
          Directory(
            '${p.dirname(filePath.path)}\\OpenRGB\\$filename',
          ).create(recursive: true);
        }
      }
    }
    String openRGBExecutablePath = openRGBExecutable.path;
    return openRGBExecutablePath;
  }

  static Stream<Window?> getWTWindow() async* {
    final stream = Stream.periodic(const Duration(milliseconds: 1500), (
      _,
    ) async {
      try {
        final list = await WindowWatcher.getWindows(getExe: true);
        final wtWindow = list.firstWhereOrNull((e) {
          return e.exePath!.contains('aces.exe');
        });
        return wtWindow;
      } catch (e) {
        return null;
      }
    });
    await for (var e in stream) {
      yield await e;
    }
  }
}
