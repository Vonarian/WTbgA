import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../data_receivers/github.dart';
import 'widgets/custom_loading.dart';

class Downloader extends StatefulWidget {
  const Downloader({
    super.key,
  });

  @override
  DownloaderState createState() => DownloaderState();
}

class DownloaderState extends State<Downloader>
    with WindowListener, TrayListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    trayManager.addListener(this);
    downloadUpdate();
  }

  @override
  void dispose() {
    super.dispose();
    windowManager.removeListener(this);
    trayManager.removeListener(this);
  }

  Future<void> downloadUpdate() async {
    await LocalNotification(
      title: 'WTbgA Update',
      subtitle: 'Downloading update, please do not close the application',
    ).show();
    await windowManager.setMinimumSize(const Size(230, 300));
    await windowManager.setMaximumSize(const Size(600, 600));
    await windowManager.setSize(const Size(230, 300));
    await windowManager.center();
    try {
      GHData data = await GHData.getData();
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      Directory docWTbgA =
          await Directory('$tempPath\\WTbgA').create(recursive: true);
      final deleteFolder = Directory(p.joinAll([docWTbgA.path, 'out']));
      if (await deleteFolder.exists()) {
        await deleteFolder.delete(recursive: true);
      }
      Dio dio = Dio();
      await dio.download(
          data.assets.last.browserDownloadUrl, '${docWTbgA.path}\\update.zip',
          onReceiveProgress: (downloaded, full) async {
        progress = downloaded / full * 100;
        setState(() {});
      }, deleteOnError: true).whenComplete(() async {
        final File filePath = File('${docWTbgA.path}\\update.zip');
        final Uint8List bytes =
            await File('${docWTbgA.path}\\update.zip').readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        for (final file in archive) {
          final filename = file.name;
          if (file.isFile) {
            final data = file.content as List<int>;
            File('${p.dirname(filePath.path)}\\out\\$filename')
              ..createSync(recursive: true)
              ..writeAsBytesSync(data);
          } else {
            Directory('${p.dirname(filePath.path)}\\out\\$filename')
                .create(recursive: true);
          }
        }

        String installer = (p.joinAll([
          ...p.split(p.dirname(Platform.resolvedExecutable)),
          'data',
          'flutter_assets',
          'assets',
          'Version',
          'installer.bat'
        ]));

        await LocalNotification(
          title: 'WTbgA Update',
          body:
              'Do not close the application until the update process is finished',
        ).show();
        text = 'Installing';
        setState(() {});
        await Process.run(installer, [docWTbgA.path]);
      }).timeout(const Duration(minutes: 8));
    } catch (e) {
      if (!mounted) return;
      displayInfoBar(context,
          builder: (BuildContext context, void Function() close) {
        return InfoBar(
            title: const Text('Retry'),
            action: IconButton(
              icon: const Icon(FluentIcons.refresh),
              onPressed: () {
                Navigator.pushReplacement(context,
                    FluentPageRoute(builder: (context) => const Downloader()));
              },
            ));
      });
      windowManager.setSize(const Size(600, 600));
      error = true;
      text = 'ERROR!';
      setState(() {});
    }
  }

  String text = 'Downloading';
  bool error = false;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        windowManager.startDragging();
      },
      child: ScaffoldPage(
          content: Center(
        child: SizedBox(
          height: 200,
          width: 200,
          child: text == 'Downloading'
              ? CircularPercentIndicator(
                  center: !error
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              text,
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.white),
                            ),
                            Text(
                              '${progress.toStringAsFixed(1)} %',
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.white),
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
                )
              : Center(
                  child: Stack(
                    children: [
                      Center(
                        child: CustomLoadingAnimationWidget.inkDrop(
                            color:
                                Color.lerp(Colors.red, Colors.orange, 0.77) ??
                                    Colors.red,
                            size: 150,
                            strokeWidth: 10,
                            colors: [
                              Colors.red,
                              Colors.blue,
                              Colors.green,
                              Colors.orange
                            ]),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              text,
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.white),
                            ),
                            Text(
                              '${progress.toStringAsFixed(1)} %',
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      )),
    );
  }

  Future<void> _handleClickRestore() async {
    await windowManager.setIcon('assets/app_icon.ico');
    windowManager.restore();
    windowManager.show();
  }

  Future<void> _trayInit() async {
    await trayManager.setIcon(
      'assets/app_icon.ico',
    );
    Menu menu = Menu(items: [
      MenuItem(key: 'show-app', label: 'Show'),
      MenuItem.separator(),
      MenuItem(key: 'close-app', label: 'Exit'),
    ]);
    await trayManager.setContextMenu(menu);
  }

  @override
  void onWindowMinimize() {
    windowManager.hide();
    _trayInit();
  }

  void _trayUnInit() async {
    await trayManager.destroy();
  }

  @override
  void onTrayIconMouseDown() async {
    _handleClickRestore();
    _trayUnInit();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onWindowRestore() {
    setState(() {});
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'show-app':
        windowManager.show();
        break;
      case 'close-app':
        windowManager.close();
        break;
    }
  }
}
