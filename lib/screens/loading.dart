import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wtbgassistant/data_receivers/indicator_receiver.dart';
import 'package:wtbgassistant/data_receivers/state_receiver.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  Future<void> setupToolData() async {
    ToolDataState stateData = await ToolDataState.getState();
    ToolDataIndicator indicatorData = await ToolDataIndicator.getIndicator();

    Navigator.pushReplacementNamed(context, '/home',
        arguments: {stateData, indicatorData});
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
  }

  Future<void> _launchURL() => launch(_url);
  final _url =
      'https://forum.warthunder.com/index.php?/topic/533554-war-thunder-background-assistant-wtbga';

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ImageFiltered(
          child: Image.asset('assets/event_korean_war.jpg'),
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
        body: const Center(
          child: SpinKitChasingDots(
            color: Colors.redAccent,
            size: 80.0,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            setupToolData();
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
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.refresh),
        ),
      ),
    ]);
  }
}
