import 'dart:developer';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wtbgassistant/screens/widgets/drawer.dart';
import 'package:wtbgassistant/services/providers.dart';

import '../downloader.dart';

class TopBar extends ConsumerStatefulWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  _TopBarState createState() => _TopBarState();
}

Future<SharedPreferences> prefs = SharedPreferences.getInstance();

class _TopBarState extends ConsumerState<TopBar> with TickerProviderStateMixin {
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
                    pageBuilder: (c, a1, a2) =>
                        const Downloader(isFfmpeg: true),
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
    var screenSize = MediaQuery.of(context).size;
    return PreferredSize(
      preferredSize: Size(screenSize.width, 1000),
      child: Container(
        color: Colors.blueGrey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 20, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                padding: const EdgeInsets.only(top: 3),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return TopDrawer(
                          prefs: prefs,
                        );
                      });
                },
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
              ),
              Text(
                (ref.watch(vehicleNameProvider) ?? 'ERROR')
                    .toUpperCase()
                    .replaceAll('_', ' '),
                style: TextStyle(
                  color: Colors.blueGrey[100],
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 3,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: screenSize.width / 8),
                    SizedBox(width: screenSize.width / 20),
                  ],
                ),
              ),
              SizedBox(
                width: screenSize.width / 50,
              ),
              ref.watch(phoneConnectedProvider)
                  ? RotationTransition(
                      turns: _controller,
                      child: IconButton(
                        onPressed: () async {
                          !streamRunning
                              ? displayCapture()
                              : await Process.run(terminatePath, []);
                        },
                        icon: const Icon(
                          Icons.wifi_rounded,
                          color: Colors.green,
                        ),
                        tooltip:
                            'Phone Connected = ${ref.watch(phoneConnectedProvider)}',
                      ),
                    )
                  : IconButton(
                      onPressed: () async {
                        !streamRunning
                            ? displayCapture()
                            : await Process.run(terminatePath, []);
                      },
                      icon: const Icon(
                        Icons.wifi_rounded,
                        color: Colors.red,
                      ),
                      tooltip: 'Toggle Stream Mode',
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
