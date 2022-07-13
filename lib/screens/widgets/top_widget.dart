import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:fluent_ui/fluent_ui.dart' hide MenuItem;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openrgb/openrgb.dart';
import 'package:system_theme/system_theme.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:win_toast/win_toast.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wtbgassistant/screens/downloader.dart';
import 'package:wtbgassistant/services/presence.dart';

import '../../data/orgb_data_class.dart';
import '../../main.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key, required this.child});

  final Widget child;

  @override
  AppState createState() => AppState();
}

class AppState extends ConsumerState<App> with TrayListener, WindowListener {
  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
    windowManager.addListener(this);
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!focused) return;
      Color? systemColor = await DynamicColorPlugin.getAccentColor();
      Brightness brightness = SystemTheme.isDarkMode ? Brightness.dark : Brightness.light;
      if (ref.read(provider.systemColorProvider.notifier).state != systemColor && systemColor != null) {
        ref.read(provider.systemColorProvider.notifier).state = systemColor;
      }
      if (brightness != ref.read(provider.systemThemeProvider.notifier).state) {
        ref.read(provider.systemThemeProvider.notifier).state = brightness;
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(provider.needPremiumProvider.notifier).state = prefs.getBool('needPremium') ?? false;
      final fromDisk = await OpenRGBSettings.loadFromDisc();
      if (!mounted) return;
      await Future.delayed(const Duration(seconds: 2));
      ref.read(provider.rgbSettingProvider.notifier).state = fromDisk ?? const OpenRGBSettings();
      if (ref.read(provider.rgbSettingProvider.notifier).state.autoStart) {
        ref.read(provider.orgbClientProvider.notifier).state = await OpenRGBClient.connect();
        if (ref.read(provider.orgbClientProvider.notifier).state != null) {
          ref.read(provider.orgbControllersProvider.notifier).state =
              await ref.read(provider.orgbClientProvider)!.getAllControllers();
        }
      }
      PresenceService().getPremium((await deviceInfo.windowsInfo).computerName).listen((event) {
        if (!mounted) return;
        ref.read(provider.premiumUserProvider.notifier).state = event.snapshot.value as bool;
      });
    });

    PresenceService().getVersion().listen((event) async {
      final version = event.snapshot.value.toString().replaceAll('.', '');
      final currentVersion = appVersion.replaceAll('.', '');
      if (int.parse(version) > int.parse(currentVersion)) {
        final toast = await WinToast.instance().showToast(
          title: 'New Version Available!',
          subtitle: 'Click on this notification to download the latest version.',
          type: ToastType.text04,
        );
        toast?.eventStream.listen((event) async {
          if (event is ActivatedEvent) {
            await _handleClickRestore();
            if (!mounted) return;
            Navigator.of(context).pushReplacement(FluentPageRoute(builder: (context) => const Downloader()));
          }
        });
      }
    });
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  bool focused = true;

  @override
  Widget build(BuildContext context) {
    return FluentApp(
        theme: ThemeData(
            brightness: ref.watch(provider.systemThemeProvider),
            visualDensity: VisualDensity.adaptivePlatformDensity,
            accentColor: ref.watch(provider.systemColorProvider).toAccentColor(),
            navigationPaneTheme: NavigationPaneThemeData(
                animationDuration: const Duration(milliseconds: 600),
                animationCurve: Curves.easeInOut,
                highlightColor: ref.watch(provider.systemColorProvider),
                iconPadding: const EdgeInsets.only(left: 6),
                labelPadding: const EdgeInsets.only(left: 4),
                backgroundColor: Colors.transparent)),
        debugShowCheckedModeBanner: false,
        title: 'WTbgA',
        home: widget.child);
  }

  Future<void> _handleClickRestore() async {
    await windowManager.setIcon('assets/app_icon.ico');
    await windowManager.restore();
    await windowManager.show();
  }

  Future<void> _trayInit() async {
    await trayManager.setIcon(
      'assets/app_icon.ico',
    );
    Menu menu = Menu(items: [
      MenuItem(key: 'show-app', label: 'Show'),
      MenuItem.separator(),
      MenuItem(key: 'close-app', label: 'Exit'),
    ]);
    await trayManager.setContextMenu(menu);
  }

  void _trayUnInit() async {
    await trayManager.destroy();
  }

  @override
  void onTrayIconMouseDown() async {
    _handleClickRestore();
    _trayUnInit();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onWindowRestore() {
    focused = true;
    setState(() {});
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'show-app':
        windowManager.show();
        break;
      case 'close-app':
        windowManager.close();
        break;
    }
  }

  @override
  void onWindowMinimize() {
    windowManager.hide();
    focused = false;
    _trayInit();
  }
}
