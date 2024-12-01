import 'app_settings.dart';

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
