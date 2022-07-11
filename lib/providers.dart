import 'package:firebase_dart/firebase_dart.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openrgb/openrgb.dart';
import 'package:wtbgassistant/data/app_settings.dart';
import 'package:wtbgassistant/data/orgb_data_class.dart';
import 'package:wtbgassistant/services/presence.dart';
import 'package:wtbgassistant/services/utility.dart';

class MyProvider {
  final StateProvider<bool> trayProvider = StateProvider((ref) => true);
  final StateProvider<String?> vehicleNameProvider = StateProvider((ref) => null);
  final StateProvider<int> gearLimitProvider = StateProvider((ref) => 1000);

  final StateProvider<int> flapLimitProvider = StateProvider((ref) => 800);
  final StateProvider<bool> downloadCompleteProvider = StateProvider((ref) => false);
  final deviceIPProvider = FutureProvider.autoDispose<String>(
    (ref) async {
      String ip = await AppUtil.runPowerShellScript(AppUtil.deviceIPPath, ['-ExecutionPolicy', 'Bypass']);
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
  final systemThemeProvider = StateProvider<Brightness>((ref) => Brightness.dark);
  final orgbClientProvider = StateProvider<OpenRGBClient?>(
    (ref) => null,
  );
  final orgbControllersProvider = StateProvider<List<RGBController>>(
    (ref) => [],
  );
  final rgbSettingProvider = StateProvider<OpenRGBSettings>((ref) => const OpenRGBSettings());

  final appSettingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) => SettingsNotifier());
  final premiumUserProvider = StateProvider<bool>((ref) => false);
  final needPremiumProvider = StateProvider<bool>((ref) => false);
  final developerMessageProvider = StreamProvider<String?>(
    (ref) async* {
      await for (Event e in PresenceService().getDeveloperMessage()) {
        yield e.snapshot.value as String?;
      }
    },
  );
}
