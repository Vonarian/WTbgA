import 'dart:developer';
import 'dart:io';

import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:win_toast/win_toast.dart';
import 'package:wtbgassistant/data_receivers/github.dart';
import 'package:wtbgassistant/screens/widgets/titlebar.dart';

import 'downloader.dart';
import 'home.dart';

class Loading extends StatefulWidget {
  final List<String> window;
  const Loading({Key? key, required this.window}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  Future<String> checkVersion() async {
    try {
      final File file = File(
          '${p.dirname(Platform.resolvedExecutable)}\\data\\flutter_assets\\assets\\Version\\version.txt');
      final String version = await file.readAsString();
      return version;
    } catch (e, st) {
      log(e.toString(), stackTrace: st);
      rethrow;
    }
  }

  Future<void> checkGitVersion(String version) async {
    try {
      Data data = await Data.getData();
      if (int.parse(data.tagName.replaceAll('.', '')) >
          int.parse(version.replaceAll('.', ''))) {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(
                'Version: $version. Status: Proceeding to update in 4 seconds!'),
            action: SnackBarAction(
                label: 'Cancel update',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (c, a1, a2) => const Home(),
                      transitionsBuilder: (c, anim, a2, child) =>
                          FadeTransition(opacity: anim, child: child),
                      transitionDuration: const Duration(milliseconds: 1000),
                    ),
                  );
                }),
          ));

        Future.delayed(const Duration(seconds: 4), () async {
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (context) {
            return const Downloader(
              isFfmpeg: false,
            );
          }));
        });
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(
              duration: const Duration(seconds: 10),
              content: Text('Version: $version ___ Status: Up-to-date!')));
        Future.delayed(const Duration(microseconds: 500), () async {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (c, a1, a2) => const Home(),
              transitionsBuilder: (c, anim, a2, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 1000),
            ),
          );
        });
      }
    } catch (e, st) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
            duration: const Duration(seconds: 10),
            content: Text(
                'Version: $version ___ Status: Error checking for update!')));
      log(e.toString(), stackTrace: st);
      Future.delayed(const Duration(seconds: 2), () async {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (c, a1, a2) => const Home(),
            transitionsBuilder: (c, anim, a2, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 1000),
          ),
        );
      });
    }
  }

  Future<void> checker() async {
    if (!widget.window.contains('War Thunder')) {
      WinToast.instance().showToast(
          type: ToastType.text04,
          title: 'Warning',
          subtitle: 'Please open War Thunder before using this app!');
    }
    if (widget.window.contains('War Thunder')) {
      WinToast.instance().showToast(
          type: ToastType.text04,
          title: 'Nice!',
          subtitle: 'War Thunder is open :)');
    }
  }

  String pathToChecker = (p.joinAll([
    ...p.split(p.dirname(Platform.resolvedExecutable)),
    'data',
    'flutter_assets',
    'assets',
    'checker.bat'
  ]));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await checkGitVersion(await checkVersion());
    });
    checker();
  }

  /// List the window handle and text for all top-level desktop windows
  /// in the current session.

  List<String> windows = [];
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Stack(children: const [
              Center(
                child: BlinkText(
                  '..: Loading :..',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  endColor: Colors.purple,
                ),
              ),
              Center(
                child: SizedBox(
                  height: 400,
                  width: 400,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
            ]),
          )),
      const WindowTitleBar(settings: false)
    ]);
  }
}
