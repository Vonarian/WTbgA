import 'dart:ffi';
import 'dart:io' show Platform;

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:libwinmedia/libwinmedia.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:win32/win32.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wtbgassistant/screens/loading.dart';
import 'package:wtbgassistant/services/theme.dart';

import 'screens/home.dart';

HotKeyManager hotKey = HotKeyManager.instance;
List<String> windows = [];

int enumWindowsProc(int hWnd, int lParam) {
  // Don't enumerate windows unless they are marked as WS_VISIBLE
  if (IsWindowVisible(hWnd) == FALSE) return TRUE;

  final length = GetWindowTextLength(hWnd);
  if (length == 0) {
    return TRUE;
  }

  final buffer = wsalloc(length + 1);
  GetWindowText(hWnd, buffer, length + 1);
  free(buffer);
  windows.add(buffer.toDartString());
  return TRUE;
}

List<String> enumerateWindows() {
  final wndProc = Pointer.fromFunction<EnumWindowsProc>(enumWindowsProc, 0);

  EnumWindows(wndProc, 0);
  print(windows);
  return windows;
}

late SharedPreferences prefs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  await windowManager.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setResizable(true);
    await windowManager.setTitle('WTNews');
    await windowManager.setIcon('assets/app_icon.ico');
    await Window.hideWindowControls();
    await Window.setEffect(
      effect: WindowEffect.aero,
      color: Colors.black.withOpacity(0.55),
    );
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
      child: MaterialApp(
        theme: lightThemeData,
        darkTheme: darkThemeData,
        debugShowCheckedModeBanner: false,
        title: 'WarThunderbgAssistant',
        initialRoute: '/',
        routes: {
          '/': (context) => Loading(
                window: enumerateWindows(),
              ),
          '/home': (context) => const Home(),
          // '/info': (context) => const InfoPage(),
        },
      ),
    ),
  );
}
