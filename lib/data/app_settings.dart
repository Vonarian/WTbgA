import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../main.dart';

class AppSettings {
  final OverHeatSetting overHeatWarning;
  final EngineSetting engineWarning;
  final OverGSetting overGWarning;
  final PullUpSetting pullUpSetting;
  final bool fullNotif;

  AppSettings copyWith({
    OverHeatSetting? overHeatWarning,
    EngineSetting? engineWarning,
    OverGSetting? overGWarning,
    bool? fullNotif,
    PullUpSetting? pullUpSetting,
  }) {
    return AppSettings(
      overHeatWarning: overHeatWarning ?? this.overHeatWarning,
      engineWarning: engineWarning ?? this.engineWarning,
      overGWarning: overGWarning ?? this.overGWarning,
      fullNotif: fullNotif ?? this.fullNotif,
      pullUpSetting: pullUpSetting ?? this.pullUpSetting,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'overHeatWarning': overHeatWarning.toMap(),
      'engineWarning': engineWarning.toMap(),
      'overGWarning': overGWarning.toMap(),
      'pullUpSetting': pullUpSetting.toMap(),
      'fullNotif': fullNotif,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      overHeatWarning: OverHeatSetting.fromMap(map['overHeatWarning']),
      engineWarning: EngineSetting.fromMap(map['engineWarning']),
      overGWarning: OverGSetting.fromMap(map['overGWarning']),
      pullUpSetting: PullUpSetting.fromMap(map['pullUpSetting']),
      fullNotif: map['fullNotif'],
    );
  }

  const AppSettings({
    required this.overHeatWarning,
    required this.engineWarning,
    required this.overGWarning,
    required this.fullNotif,
    required this.pullUpSetting,
  });
}

final defaultBeepPath =
    p.joinAll([p.dirname(Platform.resolvedExecutable), 'data\\flutter_assets\\assets', 'sounds\\beep.wav']);
final defaultPullUpPath =
    p.joinAll([p.dirname(Platform.resolvedExecutable), 'data\\flutter_assets\\assets', 'sounds\\pullup.mp3']);

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier()
      : super(AppSettings(
          overHeatWarning: OverHeatSetting(enabled: true, path: defaultBeepPath, volume: 0.22),
          engineWarning: EngineSetting(enabled: true, path: defaultBeepPath, volume: 0.22),
          overGWarning: OverGSetting(path: defaultBeepPath, enabled: true, volume: 0.22),
          pullUpSetting: PullUpSetting(enabled: true, path: defaultPullUpPath, volume: 0.22),
          fullNotif: true,
        ));

  void update(AppSettings settings) {
    state = settings;
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

  void setOverHeatWarning(String path, bool enabled, double volume) {
    state = state.copyWith(overHeatWarning: OverHeatSetting(path: path, enabled: enabled, volume: volume));
  }

  void setEngineWarning(String path, bool enabled, double volume) {
    state = state.copyWith(engineWarning: EngineSetting(path: path, enabled: enabled, volume: volume));
  }

  void setOverGWarning(String path, bool enabled, double volume) {
    state = state.copyWith(overGWarning: OverGSetting(path: path, enabled: enabled, volume: volume));
  }

  void setPullUpSetting(String path, bool enabled, double volume) {
    state = state.copyWith(pullUpSetting: PullUpSetting(path: path, enabled: enabled, volume: volume));
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

  factory OverHeatSetting.fromMap(Map<String, dynamic> map) {
    return OverHeatSetting(
      path: map['path'] as String,
      enabled: map['enabled'] as bool,
      volume: map['volume'] as double,
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

  factory OverGSetting.fromMap(Map<String, dynamic> map) {
    return OverGSetting(
      path: map['path'] as String,
      enabled: map['enabled'] as bool,
      volume: map['volume'] as double,
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

  factory EngineSetting.fromMap(Map<String, dynamic> map) {
    return EngineSetting(
      path: map['path'] as String,
      enabled: map['enabled'] as bool,
      volume: map['volume'] as double,
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

  factory PullUpSetting.fromMap(Map<String, dynamic> map) {
    return PullUpSetting(
      enabled: map['enabled'] as bool,
      volume: map['volume'] as double,
      path: map['path'] as String,
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

enum AppSettingsEnum {
  overHeatSetting,
  engineSetting,
  overGSetting,
  pullUpSetting,
  defaultSetting,
}
