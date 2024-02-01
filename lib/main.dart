import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:firebase_dart_flutter/firebase_dart_flutter.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_info2/system_info2.dart';
import 'package:window_manager/window_manager.dart';

import 'models/secret_data.dart';
import 'providers.dart';
import 'screens/loading.dart';
import 'screens/widgets/top_widget.dart';
import 'services/utility.dart';

late final SecretData secrets;
FirebaseApp? app;
late final SharedPreferences prefs;
final dio = Dio();
final audio = AudioPlayer();
final audio1 = AudioPlayer();
final audio2 = AudioPlayer();
final provider = MyProvider();
final deviceInfo = DeviceInfoPlugin();
late String appDocPath;
late final String appVersion;

Future<void> main(List<String> arguments) async {
  secrets = SecretData.load();
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await Window.initialize();
  await windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setResizable(true);
    await windowManager.setTitle('WTbgA');
    await windowManager.setIcon('assets/app_icon.ico');
    appDocPath = await AppUtil.getAppDocsPath();

    if (SysInfo.operatingSystemName.contains('Windows 11')) {
      await Window.setEffect(
          effect: WindowEffect.acrylic,
          color: const Color(0xCC222222),
          dark: true);
    } else {
      await Window.setEffect(
          effect: WindowEffect.aero,
          color: const Color(0xCC222222),
          dark: true);
    }
    await hotKeyManager.unregisterAll();
    await windowManager.show();
  });
  appVersion = await File(AppUtil.versionPath).readAsString();
  prefs = await SharedPreferences.getInstance();
  bool? autoStart = prefs.get('autoStart') as bool?;
  if (autoStart ?? false) {
    String exePath = await AppUtil.getOpenRGBExecutablePath(null, false);
    Process.run(exePath, ['--server', '--noautoconnect']);
  }
  await FirebaseDartFlutter.setup();
  if (secrets.firebaseData != null) {
    app = await Firebase.initializeApp(
        options: secrets.firebaseData!, name: 'wtbga-815e4');
  }
  runApp(
    ProviderScope(
      child: App(
          child: Loading(
        startup: arguments.contains('startup'),
        minimize: arguments.contains('minimize'),
      )),
    ),
  );
}
