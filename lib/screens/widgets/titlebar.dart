import 'dart:developer';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:tray_manager/tray_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import '../downloader.dart';

class _MoveWindow extends StatelessWidget {
  const _MoveWindow({Key? key, required this.child}) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: (details) {
            windowManager.startDragging();
          },
          onDoubleTap: () async {
            if (!await windowManager.isMaximized()) {
              await windowManager.maximize();
            } else {
              await windowManager.unmaximize();
            }
          },
          child: child),
    );
  }
}

class WindowTitleBar extends ConsumerStatefulWidget {
  final bool settings;
  const WindowTitleBar({Key? key, required this.settings}) : super(key: key);

  @override
  WindowTitleBarState createState() => WindowTitleBarState();
}

class WindowTitleBarState extends ConsumerState<WindowTitleBar>
    with TrayListener, WindowListener, SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  void displayCapture() async {
    if (await File(ffmpegPath).exists() || await File(ffmpegExePath).exists()) {
      try {
        if (await File(ffmpegExePath).exists()) {
          await Process.run(delPath, [], runInShell: true);
          return;
        }
        if (!(await File(ffmpegExePath).exists()) &&
            await File(ffmpegPath).exists()) {
          File(ffmpegPath).readAsBytes().then((value) async {
            final archive = ZipDecoder().decodeBytes(value);

            for (final file in archive) {
              final filename = file.name;
              if (file.isFile) {
                final data = file.content as List<int>;
                File(p.dirname(ffmpegPath) + '\\$filename')
                  ..createSync(recursive: true)
                  ..writeAsBytesSync(data);
              } else {
                Directory(p.dirname(ffmpegPath) + '\\$filename')
                    .create(recursive: true);
              }
            }
          });
        } else {
          await Process.run(delPath, [], runInShell: true);
        }
      } catch (e, st) {
        log('ERROR: $e', stackTrace: st);
      }
    } else {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: const Text(
            'FFMPEG not found, for the stream to work, you will need it, download?',
          ),
          action: SnackBarAction(
              label: 'Download',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (c, a1, a2) => const Downloader(isRGB: true),
                    transitionsBuilder: (c, anim, a2, child) =>
                        FadeTransition(opacity: anim, child: child),
                    transitionDuration: const Duration(milliseconds: 2000),
                  ),
                );
              }),
        ));
    }
  }

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: false, period: const Duration(seconds: 1));
  String delPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'del.bat'
  ]);
  String ffmpegPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data\\flutter_assets\\assets',
    'ffmpeg.zip'
  ]);
  String ffmpegExePath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data\\flutter_assets\\assets',
    'ffmpeg.exe'
  ]);

  bool streamRunning = false;
  String terminatePath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'terminate.bat'
  ]);
  @override
  Widget build(BuildContext context) {
    return _MoveWindow(
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 27.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    child: Image.asset(
                      'assets/app_icon.ico',
                    ),
                    onTap: () {
                      launchUrl(Uri.parse(
                          'https://forum.warthunder.com/index.php?/topic/533554-war-thunder-background-assistant-wtbga/'));
                    },
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                windowManager.minimize();
              },
              hoverColor: Colors.blue.withOpacity(0.1),
              child: Container(
                width: 15,
                height: 15,
                margin: const EdgeInsets.fromLTRB(12, 0, 10, 25.5),
                child: const Icon(Icons.minimize_outlined, color: Colors.blue),
              ),
            ),
            InkWell(
                onTap: () {
                  windowManager.close();
                  exit(0);
                },
                hoverColor: Colors.red.withOpacity(0.1),
                child: Container(
                  alignment: Alignment.center,
                  width: 15,
                  height: 15,
                  margin: const EdgeInsets.fromLTRB(12, 0, 18, 12),
                  child: const Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 25,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  final bool _showWindowBelowTrayIcon = false;
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

  void _trayUnInit() async {
    await trayManager.destroy();
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

  @override
  void onWindowMinimize() {
    windowManager.hide();
    _trayInit();
  }
}
