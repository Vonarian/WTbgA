import 'package:firebase_dart/firebase_dart.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openrgb/openrgb.dart';
import 'package:wtbgassistant/data/app_settings.dart';
import 'package:wtbgassistant/data/orgb_data_class.dart';
import 'package:wtbgassistant/services/presence.dart';
import 'package:wtbgassistant/services/utility.dart';

class MyProvider {
  final trayProvider = StateProvider<bool>((ref) => true);
  final vehicleNameProvider = StateProvider<String?>((ref) => null);
  final gearLimitProvider = StateProvider<int>((ref) => 1000);

  final flapLimitProvider = StateProvider<int>((ref) => 800);
  final downloadCompleteProvider = StateProvider<bool>((ref) => false);
  final deviceIPProvider = FutureProvider.autoDispose<String>(
    (ref) async {
      String ip = await AppUtil.runPowerShellScript(
          AppUtil.deviceIPPath, ['-ExecutionPolicy', 'Bypass']);
      return ip;
    },
  );
  final versionFBProvider = StreamProvider<String?>(
    (ref) async* {
      await for (Event e in PresenceService().getVersion()) {
        yield e.snapshot.value as String?;
      }
    },
  );
  final systemColorProvider = StateProvider<Color>((ref) => Colors.red);
  final systemThemeProvider =
      StateProvider<Brightness>((ref) => Brightness.dark);
  final orgbClientProvider = StateProvider<OpenRGBClient?>(
    (ref) => null,
  );
  final orgbControllersProvider = StateProvider<List<RGBController>>(
    (ref) => [],
  );
  final rgbSettingProvider =
      StateProvider<OpenRGBSettings>((ref) => const OpenRGBSettings());

  final appSettingsProvider =
      StateNotifierProvider<SettingsNotifier, AppSettings>(
          (ref) => SettingsNotifier());
  final premiumUserProvider = StateProvider<bool>((ref) => false);
  final needPremiumProvider = StateProvider<bool>((ref) => false);
  final developerMessageProvider = StreamProvider<String?>(
    (ref) async* {
      await for (Event e in PresenceService().getDeveloperMessage()) {
        yield e.snapshot.value as String?;
      }
    },
  );

  final wstunnelRunning = StateProvider<bool>((ref) => false);
  final gameRunningProvider = StateProvider<bool>((ref) => false);
  final inMatchProvider = StateProvider<bool>((ref) => false);
  final wtFocusedProvider = StateProvider<bool>((ref) => false);
}
