import 'dart:async';
import 'dart:convert';

import 'package:color/color.dart' as c;
import 'package:openrgb/openrgb.dart';
import 'package:wtbgassistant/main.dart';
import 'package:wtbgassistant/services/extensions.dart';

class OpenRGBSettings {
  final OverHeatSettings overHeat;
  final FireSettings fireSettings;
  final c.Color loadingColor;
  final int flashTimes;
  final bool autoStart;
  final int delayBetweenFlashes;

  const OpenRGBSettings({
    this.overHeat = const OverHeatSettings(),
    this.fireSettings = const FireSettings(),
    this.loadingColor = const c.Color.rgb(63, 240, 4),
    this.flashTimes = 4,
    this.autoStart = true,
    this.delayBetweenFlashes = 350,
  });

  Future<void> save() async {
    await prefs.setString(
        'openrgb',
        jsonEncode(toMap(), toEncodable: (Object? value) {
          if (value is c.Color) {
            return value.toJson();
          } else {
            return value;
          }
        }));
  }

  static Future<OpenRGBSettings?> loadFromDisc() async {
    final Map<String, dynamic>? map = jsonDecode(prefs.getString('openrgb') ?? '{}');
    if (map == null || map.isEmpty) {
      return const OpenRGBSettings();
    }
    return OpenRGBSettings.fromMap(map);
  }

  OpenRGBSettings copyWith({
    OverHeatSettings? overHeat,
    FireSettings? fireSettings,
    c.Color? loadingColor,
    int? flashTimes,
    bool? autoStart,
    int? delayBetweenFlashes,
  }) {
    return OpenRGBSettings(
      overHeat: overHeat ?? this.overHeat,
      fireSettings: fireSettings ?? this.fireSettings,
      loadingColor: loadingColor ?? this.loadingColor,
      flashTimes: flashTimes ?? this.flashTimes,
      autoStart: autoStart ?? this.autoStart,
      delayBetweenFlashes: delayBetweenFlashes ?? this.delayBetweenFlashes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'overHeat': overHeat.toMap(),
      'fireSettings': fireSettings.toMap(),
      'loadingColor': loadingColor.toJson(),
      'flashTimes': flashTimes,
      'autoStart': autoStart,
      'delayBetweenFlashes': delayBetweenFlashes,
    };
  }

  factory OpenRGBSettings.fromMap(Map<String, dynamic> map) {
    return OpenRGBSettings(
      overHeat: OverHeatSettings.fromMap(map['overHeat']),
      fireSettings: FireSettings.fromMap(map['fireSettings']),
      loadingColor: ColorFromMap.fromMap(map['loadingColor']),
      flashTimes: map['flashTimes'] ?? 4,
      autoStart: map['autoStart'] ?? true,
      delayBetweenFlashes: map['delayBetweenFlashes'] ?? 350,
    );
  }

  Future<void> setAllFire(OpenRGBClient client, List<RGBController> data) async {
    await OpenRGBSettings.setAllCustomSetColor(client, data, fireSettings.color);
  }

  static Future<void> setAllOff(OpenRGBClient client, List<RGBController> data) async {
    await OpenRGBSettings.setAllCustomSetColor(client, data, const c.Color.rgb(0, 0, 0));
  }

  Future<void> setAllOverHeat(OpenRGBClient client, List<RGBController> data) async {
    await OpenRGBSettings.setAllCustomSetColor(client, data, overHeat.color);
  }

  static Future<void> setAllCustomMode(OpenRGBClient client, List<RGBController> data) async {
    List<int> faultyControllers = await OpenRGBSettings.faultyControllerByModes(client, data);
    for (var i = 0; i < data.length; i++) {
      if (!faultyControllers.contains(i)) {
        await client.setCustomMode(i);
      }
    }
  }

  static Future<List<int>> faultyControllerByModes(OpenRGBClient client, List<RGBController> data) async {
    var faulty = <int>[];
    for (var i = 0; i < data.length; i++) {
      final controller = data[i];
      List<bool> faultyModes = [];
      for (var j = 0; j < controller.modes.length; j++) {
        final mode = controller.modes[j];
        if (mode.modeNumColors == 0) {
          faultyModes.add(true);
        }
      }
      if (faultyModes.length == controller.modes.length) {
        faulty.add(i);
      }
    }
    return faulty;
  }

  static Future<void> setAllCustomSetColor(OpenRGBClient client, List<RGBController> data, c.Color color) async {
    await OpenRGBSettings.setAllCustomMode(client, data);
    final updatedData = await client.getAllControllers();
    for (var i = 0; i < data.length; i++) {
      await client.setMode(i, updatedData[i].activeMode, color);
      if (updatedData[i].modes[updatedData[i].activeMode].modeColorPerLED) {
        await client.updateLeds(i, updatedData[i].colors.length, color);
      }
    }
  }

  static Future<void> setLoadingEffect(OpenRGBClient client, List<RGBController> data, c.Color color) async {
    for (var i = 0; i < data.length; i++) {
      var modeIndex = data[i].modes.indexWhere((element) {
        String modeName = element.modeName.toLowerCase();
        return modeName.contains('breath') ||
            modeName.contains('rainbow') ||
            modeName.contains('cycle') ||
            modeName.contains('strob') ||
            modeName.contains('fade') ||
            modeName.contains('blink') ||
            modeName.contains('flash');
      });
      if (modeIndex != -1) {
        await client.setMode(i, modeIndex, color);
      }
    }
  }

  static Future<void> setGradientOn(OpenRGBClient client, List<RGBController> data, int redInt) async {
    await OpenRGBSettings.setAllCustomMode(client, data);
    final updatedData = await client.getAllControllers();
    for (var i = 0; i < data.length; i++) {
      for (var j = 0; j < redInt; j++) {
        if (updatedData[i].modes[updatedData[i].activeMode].modeColorPerLED) {
          await client.updateLeds(i, updatedData[i].colors.length, c.Color.rgb(j, 0, 0));
        } else {
          await client.setMode(i, updatedData[i].activeMode, c.Color.rgb(j, 0, 0));
        }
      }
    }
  }

  static Future<void> setGradientOff(OpenRGBClient client, List<RGBController> data, int redInt) async {
    await OpenRGBSettings.setAllCustomMode(client, data);
    final updatedData = await client.getAllControllers();
    for (var i = 0; i < data.length; i++) {
      for (var j = redInt; j >= 0; j--) {
        await client.setMode(i, updatedData[i].activeMode, c.Color.rgb(j, 0, 0));
        if (updatedData[i].modes[updatedData[i].activeMode].modeColorPerLED) {
          await client.updateLeds(i, updatedData[i].colors.length, c.Color.rgb(j, 0, 0));
        }
      }
    }
  }

  static Future<void> setDeathEffect(OpenRGBClient client, List<RGBController> data, List<int> values) async {
    await OpenRGBSettings.setGradientOn(client, data, values.first - 170);
    await OpenRGBSettings.setGradientOff(client, data, values.last - 170);
    await OpenRGBSettings.setGradientOn(client, data, values.first);
    await OpenRGBSettings.setGradientOff(client, data, values.last);
    await OpenRGBSettings.setGradientOn(client, data, values.first - 170);
    await OpenRGBSettings.setGradientOff(client, data, values.last);
    await OpenRGBSettings.setGradientOn(client, data, values.first - 170);
    await OpenRGBSettings.setGradientOff(client, data, values.last - 170);
  }

  static Future<void> setJoinBattleEffect(OpenRGBClient client, List<RGBController> data, c.Color color,
      {int times = 4, int delay = 130}) async {
    for (var i = 0; i < times; i++) {
      await OpenRGBSettings.setAllCustomSetColor(client, data, color);
      await Future.delayed(Duration(milliseconds: delay));
      await OpenRGBSettings.setAllOff(client, data);
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  String toString() {
    return 'OpenRGBSettings{overHeat: $overHeat, fireSettings: $fireSettings, loadingColor: $loadingColor}';
  }
}

class OverHeatSettings {
  final c.Color color;

  const OverHeatSettings({this.color = const c.Color.rgb(247, 73, 4)});

  Map<String, dynamic> toMap() {
    return {
      'color': color.toJson(),
    };
  }

  factory OverHeatSettings.fromMap(Map<String, dynamic> map) {
    return OverHeatSettings(
      color: ColorFromMap.fromMap(map['color']),
    );
  }

  @override
  String toString() {
    return 'OverHeatSettings{color: $color}';
  }

  OverHeatSettings copyWith({
    c.Color? color,
  }) {
    return OverHeatSettings(
      color: color ?? this.color,
    );
  }
}

class FireSettings {
  final c.Color color;

  const FireSettings({this.color = const c.Color.rgb(255, 0, 0)});

  Map<String, dynamic> toMap() {
    return {
      'color': color.toJson(),
    };
  }

  factory FireSettings.fromMap(Map<String, dynamic> map) {
    return FireSettings(
      color: ColorFromMap.fromMap(map['color']),
    );
  }

  @override
  String toString() {
    return 'FireSettings{color: $color}';
  }

  FireSettings copyWith({
    c.Color? color,
  }) {
    return FireSettings(
      color: color ?? this.color,
    );
  }
}

enum Modes {
  fire,
  overHeat,
}
