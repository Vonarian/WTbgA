import 'dart:async';
import 'dart:ui';

import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  Future<void> setupToolData() async {
    bool launch = await canLaunch('http://localhost:8111');
    if (launch) {
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/home');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
            "If you didn't go to the next screen, click on More Info"),
        action: SnackBarAction(
          label: 'More Info',
          onPressed: () async {
            _launchURL();
          },
        ),
        duration: const Duration(seconds: 5),
      ));
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
    setupToolData();
    super.initState();
    Timer.periodic(Duration(milliseconds: 1300), (timer) {
      if (mounted) setupToolData();
    });
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
