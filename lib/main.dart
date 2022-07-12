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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_info2/system_info2.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wtbgassistant/providers.dart';
import 'package:wtbgassistant/screens/loading.dart';
import 'package:wtbgassistant/screens/widgets/top_widget.dart';
import 'package:wtbgassistant/services/utility.dart';

import 'data/firebase.dart';
import 'data/orgb_data_class.dart';

late final FirebaseApp? app;
late final SharedPreferences prefs;
final dio = Dio();
final audio = AudioPlayer();
final audio1 = AudioPlayer();
final audio2 = AudioPlayer();
final provider = MyProvider();
final deviceInfo = DeviceInfoPlugin();
late String appDocPath;
late final String appVersion;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await Window.initialize();
  await windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setResizable(true);
    await windowManager.setTitle('WTbgA');
    await windowManager.setIcon('assets/app_icon.ico');
    appDocPath = await AppUtil.getAppDocsPath();

    if (SysInfo.operatingSystemName.contains('Windows 11')) {
      await Window.setEffect(effect: WindowEffect.acrylic, color: const Color(0xCC222222), dark: true);
    } else {
      await Window.setEffect(effect: WindowEffect.aero, color: const Color(0xCC222222), dark: true);
    }
    await windowManager.show();
  });
  appVersion = await File(AppUtil.versionPath).readAsString();
  prefs = await SharedPreferences.getInstance();
  OpenRGBSettings settings = await OpenRGBSettings.loadFromDisc();
  if (settings.autoStart) {
    String exePath = await AppUtil.getOpenRGBExecutablePath(null, false);
    Process.run(exePath, ['--server', '--noautoconnect']);
  }
  await FirebaseDartFlutter.setup();
  app = await Firebase.initializeApp(options: FirebaseOptions.fromMap(firebaseConfig), name: 'wtbga-815e4');
  runApp(
    const ProviderScope(
      child: App(child: Loading()),
    ),
  );
}
