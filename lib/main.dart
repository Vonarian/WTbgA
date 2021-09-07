import 'dart:ffi';
import 'dart:io';

import 'package:desktoasts/desktoasts.dart';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:libwinmedia/libwinmedia.dart';
import 'package:path/path.dart' as p;
import 'package:wtbgassistant/Info.dart';

import 'Home.dart';

ToastService? service;
// final response = ResponseUI.instance;

void main() async {
  // Must add this line.
  WidgetsFlutterBinding.ensureInitialized();
  // For hot reload, `unregisterAll()` needs to be called.
  HotKeyManager.instance.unregisterAll();
  var warningPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'warning_female.mp3'
  ]);
  var overGPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'OverG.mp3'
  ]);
  var gearUpPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'GearUp.wav'
  ]);
  var pullUpPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'PullUp.mp3'
  ]);
  print(warningPath);
  var path = 'C:/src/wtbgassistant/build/windows/runner/Debug/libwinmedia.dll';
  LWM.initialize(DynamicLibrary.open(path));
  var player = Player(id: 0);
  var overGPlayer = Player(id: 1);
  var gearUpPlayer = Player(id: 2);
  var pullUpPlayer = Player(id: 3);
  player.open([Media(uri: warningPath)]);
  overGPlayer.open([Media(uri: overGPath)]);
  gearUpPlayer.open([Media(uri: gearUpPath)]);
  pullUpPlayer.open([Media(uri: pullUpPath)]);
  service = new ToastService(
    appName: 'WarThunder Background Assistant',
    companyName: 'VonarianTheGreat',
    productName: 'WarThunder Background Assistant',
  );
  runApp(
    MaterialApp(
      title: "WarThunderbgAssistant",
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Loading(),
        '/home': (context) => Home(),
        '/info': (context) => InfoPage()
      },
    ),
  );
}
