import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:blinking_text/blinking_text.dart';
import 'package:desktoasts/desktoasts.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:wtbgassistant/data_receivers/github.dart';

import '../main.dart';
import 'downloader.dart';
import 'home.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  Future<void> checkVersion() async {
    final File file = File(
        '${p.dirname(Platform.resolvedExecutable)}/data/flutter_assets/assets/Version/version.txt');
    final String version = await file.readAsString();

    try {
      Data data = await Data.getData();

      if (int.parse(data.tagName.replaceAll('.', '')) >
          int.parse(version.replaceAll('.', ''))) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(
              content: Text(
                  'Version: $version. Status: Proceeding to update in 3 seconds!')));

        Future.delayed(const Duration(seconds: 3), () async {
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (context) {
            return const Downloader();
          }));
        });
      } else {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(
              duration: const Duration(seconds: 10),
              content: Text('Version: $version ___ Status: Up-to-date!')));
        Future.delayed(const Duration(seconds: 4), () async {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (c, a1, a2) => const Home(),
              transitionsBuilder: (c, anim, a2, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 2000),
            ),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
            duration: const Duration(seconds: 10),
            content: Text(
                'Version: $version ___ Status: Error checking for update!')));
      Future.delayed(const Duration(seconds: 4), () async {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (c, a1, a2) => const Home(),
            transitionsBuilder: (c, anim, a2, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 2000),
          ),
        );
      });
    }
  }

  Future<void> checker() async {
    Process process = await Process.start(pathToChecker, []);
    process.stdout.transform(utf8.decoder).forEach((event) {
      if (event.contains('omg')) {
        service!.show(toast);
        toast.dispose();
      }
      if (event.contains('aces.exe')) {
        service!.show(toastDetect);
        toast.dispose();
      }
    });
  }

  Toast toast = Toast(
      type: ToastType.text02,
      title: 'War Thunder is not running!',
      subtitle: "For the application's features to work, WT must be open.");
  Toast toastDetect = Toast(
      type: ToastType.text02,
      title: 'War Thunder detected!',
      subtitle: 'Awesome! War Thunder is running.');
  String pathToChecker = (p.joinAll([
    ...p.split(p.dirname(Platform.resolvedExecutable)),
    'data',
    'flutter_assets',
    'assets',
    'checker.bat'
  ]));

  // hostChecker() async {
  //   if (!await canLaunch('http://localhost:8111/state')) {
  //     ScaffoldMessenger.of(context)
  //       ..removeCurrentSnackBar()
  //       ..showSnackBar(SnackBar(
  //         content: BlinkText(
  //           'Unable to connect to game server.',
  //           endColor: Colors.red,
  //         ),
  //         duration: Duration(seconds: 10),
  //       ));
  //   }
  // }

  @override
  void initState() {
    super.initState();
    checkVersion();
    checker();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ImageFiltered(
          child: Image.asset(
            'assets/bg.jpg',
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          imageFilter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0)),
      Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            title: const Text(
              'Loading WTbgA',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.cyanAccent),
            ),
          ),
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
    ]);
  }
}
