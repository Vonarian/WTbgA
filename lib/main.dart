import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libwinmedia/libwinmedia.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wtbgassistant/screens/loading.dart';
import 'package:wtbgassistant/screens/widgets/top_widget.dart';

late SharedPreferences prefs;
final dio = Dio();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  await windowManager.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setResizable(true);
    await windowManager.setTitle('WTbgA');
    await windowManager.setIcon('assets/app_icon.ico');
    await windowManager.show();
  });

  String warningPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'sounds/warning_female.mp3'
  ]);
  String overGPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'sounds/OverG.mp3'
  ]);
  String gearUpPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'sounds/GearUp.wav'
  ]);
  String pullUpPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'sounds/PullUp.mp3'
  ]);
  LWM.initialize();
  Player player = Player(id: 0);
  Player overGPlayer = Player(id: 1);
  Player gearUpPlayer = Player(id: 2);
  Player pullUpPlayer = Player(id: 3);

  player.open([Media(uri: warningPath)]);
  overGPlayer.open([Media(uri: overGPath)]);
  gearUpPlayer.open([Media(uri: gearUpPath)]);
  pullUpPlayer.open([Media(uri: pullUpPath)]);

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
