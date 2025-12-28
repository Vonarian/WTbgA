import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../main.dart';
import 'warning_settings.dart';

class AppSettings {
  final OverHeatSetting overHeatWarning;
  final EngineSetting engineWarning;
  final OverGSetting overGWarning;
  final PullUpSetting pullUpSetting;
  final ProximitySetting proximitySetting;
  final bool startup;
  final bool fullNotif;

  AppSettings copyWith({
    OverHeatSetting? overHeatWarning,
    EngineSetting? engineWarning,
    OverGSetting? overGWarning,
    bool? fullNotif,
    PullUpSetting? pullUpSetting,
    ProximitySetting? proximitySetting,
    bool? startup,
  }) {
    return AppSettings(
      overHeatWarning: overHeatWarning ?? this.overHeatWarning,
      engineWarning: engineWarning ?? this.engineWarning,
      overGWarning: overGWarning ?? this.overGWarning,
      fullNotif: fullNotif ?? this.fullNotif,
      pullUpSetting: pullUpSetting ?? this.pullUpSetting,
      proximitySetting: proximitySetting ?? this.proximitySetting,
      startup: startup ?? this.startup,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'overHeatWarning': overHeatWarning.toMap(),
      'engineWarning': engineWarning.toMap(),
      'overGWarning': overGWarning.toMap(),
      'pullUpSetting': pullUpSetting.toMap(),
      'proximitySetting': proximitySetting.toMap(),
      'fullNotif': fullNotif,
      'startup': startup,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      overHeatWarning: OverHeatSetting.fromMap(map['overHeatWarning']),
      engineWarning: EngineSetting.fromMap(map['engineWarning']),
      overGWarning: OverGSetting.fromMap(map['overGWarning']),
      pullUpSetting: PullUpSetting.fromMap(map['pullUpSetting']),
      proximitySetting: ProximitySetting.fromMap(map['proximitySetting']),
      fullNotif: map['fullNotif'] ?? false,
      startup: map['startup'] ?? false,
    );
  }

  const AppSettings({
    required this.overHeatWarning,
    required this.engineWarning,
    required this.overGWarning,
    required this.fullNotif,
    required this.pullUpSetting,
    required this.proximitySetting,
    required this.startup,
  });
}

final defaultBeepPath = p.joinAll([
  p.dirname(Platform.resolvedExecutable),
  'data\\flutter_assets\\assets',
  'sounds\\beep.wav',
]);
final defaultPullUpPath = p.joinAll([
  p.dirname(Platform.resolvedExecutable),
  'data\\flutter_assets\\assets',
  'sounds\\pullup.mp3',
]);
final defaultProxyPath = p.joinAll([
  p.dirname(Platform.resolvedExecutable),
  'data\\flutter_assets\\assets',
  'sounds\\proxy.wav',
]);

final defaultOverGPath = p.joinAll([
  p.dirname(Platform.resolvedExecutable),
  'data\\flutter_assets\\assets',
  'sounds\\overg.wav',
]);
final defaultPingPath = p.joinAll([
  p.dirname(Platform.resolvedExecutable),
  'data\\flutter_assets\\assets',
  'sounds\\ping.mp3',
]);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return AppSettings(
      overHeatWarning: OverHeatSetting(
        enabled: true,
        path: defaultBeepPath,
        volume: 22,
      ),
      engineWarning: EngineSetting(
        enabled: true,
        path: defaultBeepPath,
        volume: 22,
      ),
      overGWarning: OverGSetting(
        path: defaultOverGPath,
        enabled: true,
        volume: 22,
      ),
      pullUpSetting: PullUpSetting(
        enabled: true,
        path: defaultPullUpPath,
        volume: 22,
      ),
      proximitySetting: ProximitySetting(
        enabled: true,
        path: defaultProxyPath,
        volume: 22,
        distance: 850,
      ),
      fullNotif: true,
      startup: false,
    );
  }

  void update(AppSettings settings) {
    state = settings;
    save();
  }

  Future<void> save() async {
    await prefs.setString('settings', jsonEncode(state.toMap()));
  }

  Future<void> load() async {
    final String? settingsJson = prefs.getString('settings');
    if (settingsJson != null) {
      final Map<String, dynamic> map = json.decode(settingsJson);
      state = AppSettings.fromMap(map);
    }
    if (!(state.proximitySetting.volume <= 100 &&
        state.proximitySetting.volume >= 0)) {
      setProximitySetting(volume: 22);
      await save();
    }
  }

  void setStartup(bool? value) {
    state = state.copyWith(startup: value);
    save();
  }

  void setFullNotif(bool? value) {
    state = state.copyWith(
      fullNotif: value,
      engineWarning: state.engineWarning.copyWith(enabled: value),
      overHeatWarning: state.overHeatWarning.copyWith(enabled: value),
      overGWarning: state.overGWarning.copyWith(enabled: value),
      pullUpSetting: state.pullUpSetting.copyWith(enabled: value),
      proximitySetting: state.proximitySetting.copyWith(enabled: value),
    );
    save();
  }

  void setOverHeatWarning({String? path, bool? enabled, double? volume}) {
    state = state.copyWith(
      overHeatWarning: state.overHeatWarning.copyWith(
        volume: volume,
        enabled: enabled,
        path: path,
      ),
    );
    save();
  }

  void setEngineWarning({String? path, bool? enabled, double? volume}) {
    state = state.copyWith(
      engineWarning: state.engineWarning.copyWith(
        volume: volume,
        enabled: enabled,
        path: path,
      ),
    );
    save();
  }

  void setOverGWarning({String? path, bool? enabled, double? volume}) {
    state = state.copyWith(
      overGWarning: state.overGWarning.copyWith(
        volume: volume,
        enabled: enabled,
        path: path,
      ),
    );
    save();
  }

  void setPullUpSetting({String? path, bool? enabled, double? volume}) {
    state = state.copyWith(
      pullUpSetting: state.pullUpSetting.copyWith(
        volume: volume,
        enabled: enabled,
        path: path,
      ),
    );
    save();
  }

  void setProximitySetting({
    String? path,
    bool? enabled,
    double? volume,
    int? distance,
  }) {
    state = state.copyWith(
      proximitySetting: state.proximitySetting.copyWith(
        volume: volume,
        enabled: enabled,
        path: path,
        distance: distance,
      ),
    );
    save();
  }
}

enum AppSettingsEnum {
  overHeatSetting,
  engineSetting,
  overGSetting,
  pullUpSetting,
  defaultSetting,
}
