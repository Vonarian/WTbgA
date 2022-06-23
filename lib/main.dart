import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wtbgassistant/providers.dart';
import 'package:wtbgassistant/screens/loading.dart';
import 'package:wtbgassistant/screens/widgets/top_widget.dart';

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
AudioPlayer audio = AudioPlayer();
MyProvider provider = MyProvider();
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

  runApp(
    ProviderScope(
      child: App(
        child: FluentApp(
          theme: ThemeData.dark(),
          debugShowCheckedModeBanner: false,
          title: 'WTbgA',
          home: const Loading(),
        ),
      ),
    ),
  );
}
