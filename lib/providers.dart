import 'package:firebase_dart/firebase_dart.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openrgb/openrgb.dart' as orgb;

import 'models/app_settings.dart';
import 'models/orgb_data_class.dart';
import 'services/presence.dart';

class MyProvider {
  final trayProvider = StateProvider<bool>((ref) => true);
  final vehicleNameProvider = StateProvider<String?>((ref) => null);
  final gearLimitProvider = StateProvider<double>((ref) => 1000);

  final flapLimitProvider = StateProvider<int>((ref) => 800);
  final downloadCompleteProvider = StateProvider<bool>((ref) => false);

  final versionFBProvider = StreamProvider.family<String?, bool>(
    (ref, valid) async* {
      if (!valid) {
        yield null;
      }
      await for (Event e in PresenceService().getVersion()) {
        yield e.snapshot.value as String?;
      }
    },
  );
  final systemColorProvider = StateProvider<Color>((ref) => Colors.red);
  final systemThemeProvider =
      StateProvider<Brightness>((ref) => Brightness.dark);
  final orgbClientProvider = StateProvider<orgb.OpenRGBClient?>(
    (ref) => null,
  );
  final orgbControllersProvider = StateProvider<List<orgb.RGBController>>(
    (ref) => [],
  );
  final rgbSettingProvider =
      StateProvider<OpenRGBSettings>((ref) => const OpenRGBSettings());

  final appSettingsProvider =
      StateNotifierProvider<SettingsNotifier, AppSettings>(
          (ref) => SettingsNotifier());
  final developerMessageProvider = StreamProvider<String?>(
    (ref) async* {
      await for (Event e in PresenceService().getDeveloperMessage()) {
        yield e.snapshot.value as String?;
      }
    },
  );

  final gameRunningProvider = StateProvider<bool>((ref) => false);
  final inMatchProvider = StateProvider<bool>((ref) => false);
  final wtFocusedProvider = StateProvider<bool>((ref) => false);
}
