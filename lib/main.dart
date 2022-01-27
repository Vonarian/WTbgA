import 'dart:io' show Platform;

import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:desktoasts/desktoasts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firedart/auth/firebase_auth.dart';
import 'package:firedart/firestore/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:libwinmedia/libwinmedia.dart';
import 'package:path/path.dart' as p;
import 'package:wtbgassistant/screens/loading.dart';
import 'package:wtbgassistant/screens/vars.dart';
import 'package:wtbgassistant/services/theme.dart';
import 'package:wtbgassistant/services/utility.dart';

import 'screens/home.dart';

ToastService? service;

// typedef hello_world_func = ffi.Void Function();
// typedef HelloWorld = void Function();
// var libPath = p.joinAll([
//   p.dirname(Platform.resolvedExecutable),
//   'data/flutter_assets/assets',
//   'screencapture.cpp'
// ]);
// late final dylib = ffi.DynamicLibrary.open(libPath);
// final HelloWorld hello = dylib
//     .lookup<ffi.NativeFunction<hello_world_func>>('hello_world')
//     .asFunction();
DiscordRPC rpc = DiscordRPC(
  applicationId: '901456389786968125',
);
HotKeyManager hotKey = HotKeyManager.instance;

void main() async {
  DiscordRPC.initialize();
  rpc.start(autoRegister: true);

  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();

  await windowManager.ensureInitialized();
  await windowManager.setTitle('WTbgA');
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
  FirebaseOptions firebaseOptions = FirebaseOptions(
    appId: fireBaseConfig['appId'] ?? '',
    apiKey: fireBaseConfig['apiKey'] ?? '',
    projectId: fireBaseConfig['projectId'] ?? '',
    messagingSenderId: fireBaseConfig['messagingSenderId'] ?? '',
    authDomain: fireBaseConfig['authDomain'],
  );

  await Firebase.initializeApp(options: firebaseOptions);
  // await FirebaseAuth.initialize(
  //     fireBaseConfig['apiKey'] ?? '', await PreferencesStore.create());
  var firebaseAuth = FirebaseAuth.initialize(
      fireBaseConfig['apiKey'] ?? '', await PreferencesStore.create());
  var fireStore =
      Firestore(fireBaseConfig['projectId'] ?? '', auth: firebaseAuth);
  

  LWM.initialize();
  var player = Player(id: 0);
  var overGPlayer = Player(id: 1);
  var gearUpPlayer = Player(id: 2);
  var pullUpPlayer = Player(id: 3);

  player.open([Media(uri: warningPath)]);
  overGPlayer.open([Media(uri: overGPath)]);
  gearUpPlayer.open([Media(uri: gearUpPath)]);
  pullUpPlayer.open([Media(uri: pullUpPath)]);
  pullUpPlayer.open([Media(uri: pullUpPath)]);

  service = ToastService(
    appName: 'WarThunder Background Assistant',
    companyName: 'VonarianTheGreat',
    productName: 'WarThunder Background Assistant',
  );
  runApp(
    MaterialApp(
      theme: lightThemeData,
      darkTheme: darkThemeData,
      debugShowCheckedModeBanner: false,
      title: 'WarThunderbgAssistant',
      initialRoute: '/',
      routes: {
        '/': (context) => const Loading(),
        '/home': (context) => const Home(),
        // '/info': (context) => const InfoPage(),
      },
    ),
  );
}
