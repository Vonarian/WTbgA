import 'dart:io';
import 'dart:ui';

import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:wtbgassistant/data_receivers/github.dart';

import 'downloader.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  Future<void> checkVersion() async {
    Data data = await Data.getData();
    final File file = File(
        '${p.dirname(Platform.resolvedExecutable)}/data/flutter_assets/assets/Version/version.txt');
    final String version = await file.readAsString();
    if (int.parse(data.tagName.replaceAll('.', '')) >
        int.parse(version.replaceAll('.', ''))) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text(
                'Version: $version. Status: Proceeding to update in 4 seconds!')));

      Future.delayed(Duration(seconds: 3), () async {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return Downloader();
        }));
      });
    } else {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
            duration: Duration(seconds: 10),
            content: Text('Version: $version ___ Status: Up-to-date!')));
      Future.delayed(Duration(seconds: 4), () async {
        Navigator.of(context).pushReplacementNamed('/home');
      });
    }
  }

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
    checkVersion();
    super.initState();
  }

  Future<void> _launchURL() => launch(_url);
  final _url =
      'https://forum.warthunder.com/index.php?/topic/533554-war-thunder-background-assistant-wtbga';

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ImageFiltered(
          child: Image.asset(
            'assets/event_korean_war.jpg',
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
              'Loading WTbgI',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.cyanAccent),
            ),
          ),
          body: Center(
            child: Stack(children: [
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
                child: Container(
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
