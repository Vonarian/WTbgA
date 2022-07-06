import 'package:color/color.dart' as c;
import 'package:firebase_dart/firebase_dart.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openrgb/openrgb.dart';
import 'package:wtbgassistant/main.dart';
import 'package:wtbgassistant/services/presence.dart';
import 'package:wtbgassistant/services/utility.dart';

import 'data/data_class.dart';

class MyProvider {
  final StateProvider<bool> fullNotifProvider = StateProvider((ref) => true);
  final StateProvider<bool> oilNotifProvider = StateProvider((ref) => true);
  final StateProvider<bool> engineOHNotifProvider =
      StateProvider((ref) => true);
  final StateProvider<bool> engineDeathNotifProvider =
      StateProvider((ref) => true);

  final StateProvider<bool> waterNotifProvider = StateProvider((ref) => true);

  final StateProvider<bool> trayProvider = StateProvider((ref) => true);
  final StateProvider<String?> vehicleNameProvider =
      StateProvider((ref) => null);
  final StateProvider<int> gearLimitProvider = StateProvider((ref) => 1000);

  final StateProvider<int> flapLimitProvider = StateProvider((ref) => 800);
  final StateProvider<bool> downloadCompleteProvider =
      StateProvider((ref) => false);
  final deviceIPProvider = FutureProvider.autoDispose<String>(
    (ref) async {
      String ip = await AppUtil.runPowerShellScript(
          deviceIPPath, ['-ExecutionPolicy', 'Bypass']);
      return ip;
    },
  );
  final versionFBProvider = StreamProvider<String>(
    (ref) async* {
      await for (Event e in PresenceService().getVersion()) {
        yield e.snapshot.value.toString();
      }
    },
  );
  final systemColorProvider = StateProvider<Color>((ref) => Colors.red);
  final systemThemeProvider =
      StateProvider<Brightness>((ref) => Brightness.dark);
  final orgbClientProvider = StateProvider<OpenRGBClient?>(
    (ref) => null,
  );
  final openRGBSettingProvider = StateProvider<OpenRGBSettings>((ref) =>
      const OpenRGBSettings(
          fireSettings: FireSettings(color: c.Color.rgb(255, 22, 233)),
          overHeat: OverHeatSettings(color: c.Color.rgb(100, 100, 100))));
}
