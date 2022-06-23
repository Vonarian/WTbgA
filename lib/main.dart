import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:firebase_dart_flutter/firebase_dart_flutter.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wtbgassistant/providers.dart';
import 'package:wtbgassistant/screens/loading.dart';
import 'package:wtbgassistant/screens/widgets/top_widget.dart';

import 'data/firebase.dart';

late final FirebaseApp? app;
late SharedPreferences prefs;
final dio = Dio();
String beepPath = p.joinAll([
  p.dirname(Platform.resolvedExecutable),
  'data/flutter_assets/assets',
  'sounds/beep.wav'
]);
String deviceIPPath = p.joinAll([
  p.dirname(Platform.resolvedExecutable),
  'data/flutter_assets/assets',
  'scripts/deviceIP.ps1'
]);
String pathToChecker = (p.joinAll([
  ...p.split(p.dirname(Platform.resolvedExecutable)),
  'data',
  'flutter_assets',
  'assets',
  'checker.bat'
]));
String versionPath =
    '${p.dirname(Platform.resolvedExecutable)}\\data\\flutter_assets\\assets\\Version\\version.txt';
AudioPlayer audio = AudioPlayer();
MyProvider provider = MyProvider();
DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setResizable(true);
    await windowManager.setTitle('WTbgA');
    await windowManager.setIcon('assets/app_icon.ico');
    prefs = await SharedPreferences.getInstance();

    await windowManager.show();
  });
  await FirebaseDartFlutter.setup();
  app = await Firebase.initializeApp(
      options: FirebaseOptions.fromMap(firebaseConfig), name: 'wtbga-815e4');
  runApp(
    const ProviderScope(
      child: App(child: Loading()),
    ),
  );
}
