import 'dart:ffi';
import 'dart:io';

import 'package:desktoasts/desktoasts.dart';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:libwinmedia/libwinmedia.dart';
import 'package:path/path.dart' as p;
import 'package:response/response.dart';
import 'package:wtbgassistant/Info.dart';

import 'Home.dart';

ToastService? service;
final response = ResponseUI.instance;

void main() async {
  // Must add this line.
  WidgetsFlutterBinding.ensureInitialized();
  // For hot reload, `unregisterAll()` needs to be called.
  HotKeyManager.instance.unregisterAll();
  var beepPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'warning_female.mp3'
  ]);
  print(beepPath);
  var path = 'C:/src/wtbgassistant/build/windows/runner/Debug/libwinmedia.dll';
  LWM.initialize(DynamicLibrary.open(path));
  var player = Player(id: 0);
  player.open([Media(uri: beepPath)]);
  service = new ToastService(
    appName: 'WarThunder Background Assistant',
    companyName: 'VonarianTheGreat',
    productName: 'WarThunder Background Assistant',
  );
  runApp(
    Response(
      originalScreenHeight: 1920,
      originalScreenWidth: 1080,
      child: MaterialApp(
        title: "WarThunderbgAssistant",
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => Loading(),
          '/home': (context) => Home(),
          '/info': (context) => InfoPage()
        },
      ),
    ),
  );
}
