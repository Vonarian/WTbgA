import 'package:firebase_dart/firebase_dart.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openrgb/openrgb.dart' as orgb;
import 'package:version/version.dart';

import 'models/orgb_data_class.dart';
import 'models/settings/app_settings.dart';
import 'services/presence.dart';

// Notifiers for simple state
class TrayNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void set(bool value) => state = value;
}

final trayProvider = NotifierProvider<TrayNotifier, bool>(TrayNotifier.new);

class VehicleNameNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

final vehicleNameProvider = NotifierProvider<VehicleNameNotifier, String?>(
  VehicleNameNotifier.new,
);

class GearLimitNotifier extends Notifier<double> {
  @override
  double build() => 1000;
  void set(double value) => state = value;
}

final gearLimitProvider = NotifierProvider<GearLimitNotifier, double>(
  GearLimitNotifier.new,
);

class FlapLimitNotifier extends Notifier<int> {
  @override
  int build() => 800;
  void set(int value) => state = value;
}

final flapLimitProvider = NotifierProvider<FlapLimitNotifier, int>(
  FlapLimitNotifier.new,
);

class DownloadCompleteNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
}

final downloadCompleteProvider =
    NotifierProvider<DownloadCompleteNotifier, bool>(
      DownloadCompleteNotifier.new,
    );

final versionFBProvider = StreamProvider.family<Version?, bool>((
  ref,
  valid,
) async* {
  if (!valid) {
    yield null;
  }
  await for (Event e in PresenceService().getVersion()) {
    yield Version.parse(e.snapshot.value);
  }
});

class SystemColorNotifier extends Notifier<Color> {
  @override
  Color build() => Colors.red;
  void set(Color value) => state = value;
}

final systemColorProvider = NotifierProvider<SystemColorNotifier, Color>(
  SystemColorNotifier.new,
);

class SystemThemeNotifier extends Notifier<Brightness> {
  @override
  Brightness build() => Brightness.dark;
  void set(Brightness value) => state = value;
}

final systemThemeProvider = NotifierProvider<SystemThemeNotifier, Brightness>(
  SystemThemeNotifier.new,
);

class ORGBClientNotifier extends Notifier<orgb.OpenRGBClient?> {
  @override
  orgb.OpenRGBClient? build() => null;
  void set(orgb.OpenRGBClient? value) => state = value;
}

final orgbClientProvider =
    NotifierProvider<ORGBClientNotifier, orgb.OpenRGBClient?>(
      ORGBClientNotifier.new,
    );

class ORGBControllersNotifier extends Notifier<List<orgb.RGBController>> {
  @override
  List<orgb.RGBController> build() => [];
  void set(List<orgb.RGBController> value) => state = value;
}

final orgbControllersProvider =
    NotifierProvider<ORGBControllersNotifier, List<orgb.RGBController>>(
      ORGBControllersNotifier.new,
    );

class RGBSettingNotifier extends Notifier<OpenRGBSettings> {
  @override
  OpenRGBSettings build() => const OpenRGBSettings();
  void set(OpenRGBSettings value) => state = value;
}

final rgbSettingProvider =
    NotifierProvider<RGBSettingNotifier, OpenRGBSettings>(
      RGBSettingNotifier.new,
    );

final appSettingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

final developerMessageProvider = StreamProvider<String?>((ref) async* {
  await for (Event e in PresenceService().getDeveloperMessage()) {
    yield e.snapshot.value as String?;
  }
});

class GameRunningNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
}

final gameRunningProvider = NotifierProvider<GameRunningNotifier, bool>(
  GameRunningNotifier.new,
);

class InMatchNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
}

final inMatchProvider = NotifierProvider<InMatchNotifier, bool>(
  InMatchNotifier.new,
);

class WtFocusedNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
}

final wtFocusedProvider = NotifierProvider<WtFocusedNotifier, bool>(
  WtFocusedNotifier.new,
);
