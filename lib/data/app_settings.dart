import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:win32_registry/win32_registry.dart';

import '../main.dart';

class AppSettings {
  final OverHeatSetting overHeatWarning;
  final EngineSetting engineWarning;
  final OverGSetting overGWarning;
  final PullUpSetting pullUpSetting;
  final ProximitySetting proximitySetting;
  final WindscribeSettings windscribeSettings;
  final bool fullNotif;

  AppSettings copyWith({
    OverHeatSetting? overHeatWarning,
    EngineSetting? engineWarning,
    OverGSetting? overGWarning,
    bool? fullNotif,
    PullUpSetting? pullUpSetting,
    ProximitySetting? proximitySetting,
    WindscribeSettings? windscribeSettings,
  }) {
    return AppSettings(
      overHeatWarning: overHeatWarning ?? this.overHeatWarning,
      engineWarning: engineWarning ?? this.engineWarning,
      overGWarning: overGWarning ?? this.overGWarning,
      fullNotif: fullNotif ?? this.fullNotif,
      pullUpSetting: pullUpSetting ?? this.pullUpSetting,
      proximitySetting: proximitySetting ?? this.proximitySetting,
      windscribeSettings: windscribeSettings ?? this.windscribeSettings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'overHeatWarning': overHeatWarning.toMap(),
      'engineWarning': engineWarning.toMap(),
      'overGWarning': overGWarning.toMap(),
      'pullUpSetting': pullUpSetting.toMap(),
      'proximitySetting': proximitySetting.toMap(),
      'windscribeSettings': windscribeSettings.toMap(),
      'fullNotif': fullNotif,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      overHeatWarning: OverHeatSetting.fromMap(map['overHeatWarning']),
      engineWarning: EngineSetting.fromMap(map['engineWarning']),
      overGWarning: OverGSetting.fromMap(map['overGWarning']),
      pullUpSetting: PullUpSetting.fromMap(map['pullUpSetting']),
      proximitySetting: ProximitySetting.fromMap(map['proximitySetting']),
      windscribeSettings: WindscribeSettings.fromMap(map['windscribeSettings']),
      fullNotif: map['fullNotif'],
    );
  }

  const AppSettings({
    required this.overHeatWarning,
    required this.engineWarning,
    required this.overGWarning,
    required this.fullNotif,
    required this.pullUpSetting,
    required this.proximitySetting,
    required this.windscribeSettings,
  });
}

final defaultBeepPath = p.joinAll([
  p.dirname(Platform.resolvedExecutable),
  'data\\flutter_assets\\assets',
  'sounds\\beep.wav'
]);
final defaultPullUpPath = p.joinAll([
  p.dirname(Platform.resolvedExecutable),
  'data\\flutter_assets\\assets',
  'sounds\\pullup.mp3'
]);
final defaultProxyPath = p.joinAll([
  p.dirname(Platform.resolvedExecutable),
  'data\\flutter_assets\\assets',
  'sounds\\proxy.wav'
]);

final defaultOverGPath = p.joinAll([
  p.dirname(Platform.resolvedExecutable),
  'data\\flutter_assets\\assets',
  'sounds\\overg.wav'
]);
final defaultPingPath = p.joinAll([
  p.dirname(Platform.resolvedExecutable),
  'data\\flutter_assets\\assets',
  'sounds\\ping.mp3'
]);

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier()
      : super(AppSettings(
          overHeatWarning:
              OverHeatSetting(enabled: true, path: defaultBeepPath, volume: 22),
          engineWarning:
              EngineSetting(enabled: true, path: defaultBeepPath, volume: 22),
          overGWarning:
              OverGSetting(path: defaultOverGPath, enabled: true, volume: 22),
          pullUpSetting:
              PullUpSetting(enabled: true, path: defaultPullUpPath, volume: 22),
          proximitySetting: ProximitySetting(
              enabled: true, path: defaultProxyPath, volume: 22, distance: 850),
          windscribeSettings: WindscribeSettings(notifPath: defaultPingPath),
          fullNotif: true,
        ));

  void update(AppSettings settings) {
    state = settings;
  }

  Future<String?> setupWindscribePath() async {
    RegistryKey? key;
    RegistryKey? key2;
    RegistryKey? key3;
    try {
      key = Registry.openPath(RegistryHive.currentUser,
          path: r'Software\Windscribe\Installer');
    } catch (e, st) {
      log(e.toString(), stackTrace: st);
    }
    try {
      key2 = Registry.openPath(RegistryHive.localMachine,
          path: r'Software\Windscribe\Installer');
    } catch (e, st) {
      log(e.toString(), stackTrace: st);
    }
    try {
      key3 = Registry.openPath(RegistryHive.allUsers,
          path: r'Software\Windscribe\Installer');
    } catch (e, st) {
      log(e.toString(), stackTrace: st);
    }
    final value = key?.getValueAsString('applicationPath') ??
        key2?.getValueAsString('applicationPath') ??
        key3?.getValueAsString('applicationPath');
    if (value != null) {
      state = state.copyWith(
          windscribeSettings: state.windscribeSettings
              .copyWith(path: '$value\\windscribe-cli.exe'));
      return '$value\\windscribe-cli.exe';
    }
    key?.close();
    key2?.close();
    key3?.close();
    return null;
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
  }

  void setFullNotif(bool? value) {
    state = state.copyWith(fullNotif: value);
  }

  void setOverHeatWarning({String? path, bool? enabled, double? volume}) {
    state = state.copyWith(
        overHeatWarning: state.overHeatWarning.copyWith(
      volume: volume,
      enabled: enabled,
      path: path,
    ));
  }

  void setEngineWarning({String? path, bool? enabled, double? volume}) {
    state = state.copyWith(
        engineWarning: state.engineWarning.copyWith(
      volume: volume,
      enabled: enabled,
      path: path,
    ));
  }

  void setOverGWarning({String? path, bool? enabled, double? volume}) {
    state = state.copyWith(
        overGWarning: state.overGWarning.copyWith(
      volume: volume,
      enabled: enabled,
      path: path,
    ));
  }

  void setPullUpSetting({String? path, bool? enabled, double? volume}) {
    state = state.copyWith(
        pullUpSetting: state.pullUpSetting.copyWith(
      volume: volume,
      enabled: enabled,
      path: path,
    ));
  }

  void setProximitySetting(
      {String? path, bool? enabled, double? volume, int? distance}) {
    state = state.copyWith(
        proximitySetting: state.proximitySetting.copyWith(
      volume: volume,
      enabled: enabled,
      path: path,
      distance: distance,
    ));
  }

  void setWindscribe(
      {String? notifPath, bool? autoSwitch, double? volume, String? path}) {
    state = state.copyWith(
        windscribeSettings: state.windscribeSettings.copyWith(
            volume: volume,
            autoSwitch: autoSwitch,
            notifPath: notifPath,
            path: path));
  }
}

class OverHeatSetting {
  final String path;
  final bool enabled;
  final double volume;

  const OverHeatSetting({
    required this.path,
    required this.enabled,
    required this.volume,
  });

  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'enabled': enabled,
      'volume': volume,
    };
  }

  factory OverHeatSetting.fromMap(Map<String, dynamic>? map) {
    return OverHeatSetting(
      path: map?['path'] ?? defaultBeepPath,
      enabled: map?['enabled'] ?? true,
      volume: map?['volume'] ?? 22,
    );
  }

  OverHeatSetting copyWith({
    String? path,
    bool? enabled,
    double? volume,
  }) {
    return OverHeatSetting(
      path: path ?? this.path,
      enabled: enabled ?? this.enabled,
      volume: volume ?? this.volume,
    );
  }
}

class OverGSetting {
  final String path;
  final bool enabled;
  final double volume;

  const OverGSetting({
    required this.path,
    required this.enabled,
    required this.volume,
  });

  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'enabled': enabled,
      'volume': volume,
    };
  }

  factory OverGSetting.fromMap(Map<String, dynamic>? map) {
    return OverGSetting(
      path: map?['path'] ?? defaultOverGPath,
      enabled: map?['enabled'] ?? true,
      volume: map?['volume'] ?? 22,
    );
  }

  OverGSetting copyWith({
    String? path,
    bool? enabled,
    double? volume,
  }) {
    return OverGSetting(
      path: path ?? this.path,
      enabled: enabled ?? this.enabled,
      volume: volume ?? this.volume,
    );
  }
}

class EngineSetting {
  final String path;
  final bool enabled;
  final double volume;

  const EngineSetting({
    required this.path,
    required this.enabled,
    required this.volume,
  });

  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'enabled': enabled,
      'volume': volume,
    };
  }

  factory EngineSetting.fromMap(Map<String, dynamic>? map) {
    return EngineSetting(
      path: map?['path'] ?? defaultBeepPath,
      enabled: map?['enabled'] ?? true,
      volume: map?['volume'] ?? 22,
    );
  }

  EngineSetting copyWith({
    String? path,
    bool? enabled,
    double? volume,
  }) {
    return EngineSetting(
      path: path ?? this.path,
      enabled: enabled ?? this.enabled,
      volume: volume ?? this.volume,
    );
  }
}

class PullUpSetting {
  final bool enabled;
  final double volume;
  final String path;

  const PullUpSetting({
    required this.enabled,
    required this.volume,
    required this.path,
  });

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'volume': volume,
      'path': path,
    };
  }

  factory PullUpSetting.fromMap(Map<String, dynamic>? map) {
    return PullUpSetting(
      enabled: map?['enabled'] ?? true,
      volume: map?['volume'] ?? 22,
      path: map?['path'] ?? defaultPullUpPath,
    );
  }

  PullUpSetting copyWith({
    bool? enabled,
    double? volume,
    String? path,
  }) {
    return PullUpSetting(
      enabled: enabled ?? this.enabled,
      volume: volume ?? this.volume,
      path: path ?? this.path,
    );
  }
}

class ProximitySetting {
  final String path;
  final bool enabled;
  final double volume;
  final int distance;

  const ProximitySetting({
    required this.path,
    required this.enabled,
    required this.volume,
    required this.distance,
  });

  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'enabled': enabled,
      'volume': volume,
      'distance': distance,
    };
  }

  factory ProximitySetting.fromMap(Map<String, dynamic>? map) {
    return ProximitySetting(
      path: map?['path'] ?? defaultProxyPath,
      enabled: map?['enabled'] ?? false,
      volume: map?['volume'] ?? 22,
      distance: map?['distance'] ?? 850,
    );
  }

  ProximitySetting copyWith({
    String? path,
    bool? enabled,
    double? volume,
    int? distance,
  }) {
    return ProximitySetting(
      path: path ?? this.path,
      enabled: enabled ?? this.enabled,
      volume: volume ?? this.volume,
      distance: distance ?? this.distance,
    );
  }

  @override
  String toString() {
    return 'ProximitySetting{path: $path, enabled: $enabled, volume: $volume, distance: $distance}';
  }
}

class WindscribeSettings {
  final bool autoSwitch;
  final String notifPath;
  final double volume;
  final String? path;

  const WindscribeSettings({
    this.autoSwitch = false,
    required this.notifPath,
    this.volume = 22,
    this.path,
  });

  Future<void> connectWindscribe() async {
    if (path == null) return;
    final process = await Process.start(path!, ['connect']);
    await for (var e in process.stdout.transform(utf8.decoder)) {
      log(e);
    }
    await audio2.play(DeviceFileSource(notifPath),
        volume: volume / 100, mode: PlayerMode.lowLatency);
  }

  Future<void> disconnectWindscribe() async {
    if (path == null) return;
    final process = await Process.start(path!, ['disconnect']);
    await for (var e in process.stdout.transform(utf8.decoder)) {
      log(e);
    }
    await Process.run('taskkill', ['/F', '/IM', 'wstunnel.exe']);
    await audio2.play(DeviceFileSource(notifPath),
        volume: volume / 100, mode: PlayerMode.lowLatency);
  }

  Map<String, dynamic> toMap() {
    return {
      'autoSwitch': autoSwitch,
      'notifPath': notifPath,
      'volume': volume,
      'path': path,
    };
  }

  factory WindscribeSettings.fromMap(Map<String, dynamic>? map) {
    return WindscribeSettings(
      autoSwitch: map?['autoSwitch'] ?? false,
      notifPath: map?['notifPath'] ?? defaultPingPath,
      volume: map?['volume'] ?? 22,
      path: map?['path'],
    );
  }

  WindscribeSettings copyWith({
    bool? autoSwitch,
    String? notifPath,
    double? volume,
    String? path,
  }) {
    return WindscribeSettings(
      autoSwitch: autoSwitch ?? this.autoSwitch,
      notifPath: notifPath ?? this.notifPath,
      volume: volume ?? this.volume,
      path: path ?? this.path,
    );
  }

  @override
  String toString() {
    return 'WindscribeSettings{autoSwitch: $autoSwitch, notifPath: $notifPath, volume: $volume, path: $path}';
  }
}

enum AppSettingsEnum {
  overHeatSetting,
  engineSetting,
  overGSetting,
  pullUpSetting,
  defaultSetting,
}
