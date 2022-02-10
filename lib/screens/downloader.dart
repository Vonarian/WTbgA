import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:desktoasts/desktoasts.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wtbgassistant/main.dart';
import 'package:wtbgassistant/services/utility.dart';

import '../data_receivers/github.dart';
import 'home.dart';

class Downloader extends StatefulWidget {
  final bool isFfmpeg;
  const Downloader({Key? key, required this.isFfmpeg}) : super(key: key);

  @override
  _DownloaderState createState() => _DownloaderState();
}

class _DownloaderState extends State<Downloader>
    with WindowListener, TrayListener {
  @override
  void initState() {
    super.initState();
    if (!widget.isFfmpeg) {
      downloadUpdate();
      windowManager.setAsFrameless();
    } else {
      downloadFfmpeg();
    }
    windowManager.addListener(this);
    trayManager.addListener(this);
  }

  @override
  void dispose() {
    super.dispose();
    windowManager.removeListener(this);
    trayManager.removeListener(this);
  }

  String errorLogPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/logs/errors'
  ]);

  Toast toast = Toast(
      type: ToastType.text02,
      title: 'Downloading WTbgA update',
      subtitle: 'Please do not close the application!');
  Toast toastFfmpeg = Toast(
      type: ToastType.text02,
      title: 'Downloading FFMPEG',
      subtitle: 'Please do not close the application!');
  Future<void> downloadFfmpeg() async {
    service!.show(toastFfmpeg);
    toast.dispose();
    try {
      Dio dio = Dio();
      await dio.download(
          'https://github.com/Vonarian/WTbgA/releases/download/2.4.0.0/ffmpeg.zip',
          '${p.dirname(Platform.resolvedExecutable)}/data/flutter_assets/assets/ffmpeg.zip',
          onReceiveProgress: (downloaded, full) {
        progress = downloaded / full * 100;
        setState(() {});
      }).whenComplete(() {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (c, a1, a2) => const Home(),
            transitionsBuilder: (c, anim, a2, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 2000),
          ),
        );
      });
    } catch (e, st) {
      String path = await AppUtil.createFolderInAppDocDir(errorLogPath);
      final File fileWrite = File('$path/downloader-ffmpeg.txt');
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
            duration: const Duration(seconds: 10),
            content: Text(e.toString())));
      final String finalString = 'Logging:'
          '\nError:\n'
          '$e'
          '\nStackTrace: '
          '\n$st';
      await fileWrite.writeAsString(finalString);
      if (progress != 100) {
        await Directory(
                '${p.dirname(Platform.resolvedExecutable)}/data/flutter_assets/assets/ffmpeg.zip')
            .delete();
      }
      error = true;
      setState(() {});
      Toast errorToast = Toast(
          type: ToastType.text02,
          title: 'Ffmpeg download failed',
          subtitle: 'Please make sure your internet connection is stable');
      service!.show(errorToast);
      errorToast.dispose();
    }
  }

  Future<void> downloadUpdate() async {
    await windowManager.setMinimumSize(const Size(230, 300));
    await windowManager.setMaximumSize(const Size(600, 600));
    await windowManager.setSize(const Size(230, 300));
    service!.show(toast);
    toast.dispose();
    try {
      Data data = await Data.getData();

      Dio dio = Dio();
      await dio.download(data.assets.last.browserDownloadUrl,
          '${p.dirname(Platform.resolvedExecutable)}/data/update.zip',
          onReceiveProgress: (downloaded, full) {
        progress = downloaded / full * 100;
        setState(() {});
      }).whenComplete(() async {
        final File filePath =
            File('${p.dirname(Platform.resolvedExecutable)}/data/update.zip');
        final Uint8List bytes = await File(
                '${p.dirname(Platform.resolvedExecutable)}/data/update.zip')
            .readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        for (final file in archive) {
          final filename = file.name;
          if (file.isFile) {
            final data = file.content as List<int>;
            File(p.dirname(filePath.path) + '/out/$filename')
              ..createSync(recursive: true)
              ..writeAsBytesSync(data);
          } else {
            Directory(p.dirname(filePath.path) + '/out/$filename')
                .create(recursive: true);
          }
        }

        String msiXPath = (p.joinAll([
          ...p.split(p.dirname(filePath.path)),
          'out',
          'WTbgA.msix',
        ]));
        await Process.run(
                'powershell.exe', ['Add-AppPackage', '-path', msiXPath],
                runInShell: true)
            .whenComplete(
                () => Future.delayed(const Duration(seconds: 2), () async {
                      exit(0);
                    }));
      }).timeout(const Duration(minutes: 8));
    } catch (e, st) {
      String path = await AppUtil.createFolderInAppDocDir(errorLogPath);
      final File fileWrite = File('$path/downloader-update.txt');
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
            duration: const Duration(seconds: 10),
            content: Text(e.toString())));
      final String finalString = 'Logging:'
          '\nError:\n'
          '$e'
          '\nStackTrace: '
          '\n$st';
      await fileWrite.writeAsString(finalString);

      error = true;
      setState(() {});
      rethrow;
    }
  }

  bool error = false;
  double progress = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget.isFfmpeg
            ? AppBar(
                title: const Text('Downloading FFMPEG'),
                centerTitle: true,
                leading: IconButton(
                    onPressed: () {
                      if (progress != 100) {
                        Directory(
                                '${p.dirname(Platform.resolvedExecutable)}/data/flutter_assets/assets/ffmpeg.zip')
                            .delete();
                      }
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (c, a1, a2) => const Home(),
                          transitionsBuilder: (c, anim, a2, child) =>
                              FadeTransition(opacity: anim, child: child),
                          transitionDuration:
                              const Duration(milliseconds: 2000),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_back)),
              )
            : null,
        backgroundColor: Colors.blueGrey,
        body: Center(
          child: SizedBox(
              height: 200,
              width: 200,
              child: CircularPercentIndicator(
                center: !error
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Downloading',
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            '${progress.toStringAsFixed(1)} %',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      )
                    : const Center(
                        child: Text(
                          'ERROR',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                backgroundColor: Colors.blue,
                percent: double.parse(progress.toStringAsFixed(0)) / 100,
                radius: 100,
              )),
        ));
  }

  final bool _showWindowBelowTrayIcon = false;
  Future<void> _handleClickRestore() async {
    windowManager.restore();
    windowManager.show();
  }

  @override
  void onTrayIconMouseDown() async {
    if (_showWindowBelowTrayIcon) {
      Size windowSize = await windowManager.getSize();
      Rect trayIconBounds = await TrayManager.instance.getBounds();
      Size trayIconSize = trayIconBounds.size;
      Offset trayIconNewPosition = trayIconBounds.topLeft;

      Offset newPosition = Offset(
        trayIconNewPosition.dx - ((windowSize.width - trayIconSize.width) / 2),
        trayIconNewPosition.dy,
      );

      windowManager.setPosition(newPosition);
      await Future.delayed(const Duration(milliseconds: 100));
    }
    _handleClickRestore();
  }
}
