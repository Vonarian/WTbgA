import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:color/color.dart' as c;
import 'package:fluent_ui/fluent_ui.dart' as f;
import 'package:openrgb/openrgb.dart';
import 'package:wtbgassistant/main.dart';

class OpenRGBSettings {
  final OverHeatSettings overHeat;
  final FireSettings fireSettings;
  final c.Color loadingColor;
  final int flashTimes;

  const OpenRGBSettings({
    this.overHeat = const OverHeatSettings(),
    this.fireSettings = const FireSettings(),
    this.loadingColor = const c.Color.rgb(63, 240, 4),
    this.flashTimes = 4,
  });

  Future<void> save() async {
    await prefs.setString(
        'openrgb',
        jsonEncode(toMap(), toEncodable: (Object? value) {
          if (value is c.Color) {
            return value.toStringHex();
          } else {
            return value;
          }
        }));
  }

  static Future<OpenRGBSettings> loadFromDisc() async {
    final Map<String, dynamic>? map = json.decode(prefs.getString('openrgb') ?? '{}');
    if (map == null || map.isEmpty || !map.containsKey('loadingColor')) {
      return const OpenRGBSettings();
    }
    return OpenRGBSettings.fromMap(map);
  }

  OpenRGBSettings copyWith({
    OverHeatSettings? overHeat,
    FireSettings? fireSettings,
    c.Color? loadingColor,
    int? flashTimes,
  }) {
    return OpenRGBSettings(
      overHeat: overHeat ?? this.overHeat,
      fireSettings: fireSettings ?? this.fireSettings,
      loadingColor: loadingColor ?? this.loadingColor,
      flashTimes: flashTimes ?? this.flashTimes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'overHeat': overHeat.toMap(),
      'fireSettings': fireSettings.toMap(),
      'loadingColor': loadingColor.toStringHex(),
      'flashTimes': flashTimes,
    };
  }

  factory OpenRGBSettings.fromMap(Map<String, dynamic> map) {
    return OpenRGBSettings(
      overHeat: OverHeatSettings.fromMap(map['overHeat'] as Map<String, dynamic>),
      fireSettings: FireSettings.fromMap(map['fireSettings'] as Map<String, dynamic>),
      loadingColor: c.Color.hex(map['loadingColor']).toRgbColor(),
      flashTimes: map['flashTimes'] ?? 4,
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
      await client.setMode(
          i, data[i].modes.indexWhere((element) => element.modeName.toLowerCase().contains('breath')), color);
      await client.updateLeds(i, data[i].colors.length, color);
    }
  }

  static Future<void> setDeathEffect(OpenRGBClient client, List<RGBController> data) async {
    for (var i = 0; i < 3; i++) {
      await OpenRGBSettings.setAllCustomSetColor(client, data, const f.Color.fromRGBO(255, 0, 0, 1).toRGB());
      await Future.delayed(const Duration(milliseconds: 100));
      await OpenRGBSettings.setAllOff(client, data);
      await Future.delayed(const Duration(milliseconds: 100));
      await OpenRGBSettings.setAllCustomSetColor(client, data, const f.Color.fromRGBO(255, 0, 0, 1).toRGB());
      await Future.delayed(const Duration(milliseconds: 200));
      await OpenRGBSettings.setAllCustomSetColor(client, data, const f.Color.fromRGBO(255, 0, 0, 1).toRGB());
      await Future.delayed(const Duration(milliseconds: 400));
      await OpenRGBSettings.setAllOff(client, data);
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
      'color': color.toStringHex(),
    };
  }

  factory OverHeatSettings.fromMap(Map<String, dynamic> map) {
    return OverHeatSettings(
      color: c.Color.hex(map['color'] as String).toRgbColor(),
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
      'color': color.toStringHex(),
    };
  }

  factory FireSettings.fromMap(Map<String, dynamic> map) {
    return FireSettings(
      color: c.Color.hex(map['color'] as String).toRgbColor(),
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

extension ToRGB on ui.Color {
  c.Color toRGB() {
    return c.Color.rgb(red, green, blue);
  }
}

extension ColorFromMap on c.Color {
  static c.Color fromMap(Map<String, dynamic> map) {
    return c.Color.rgb(map['r'], map['g'], map['b']).toRgbColor();
  }
}

extension ToMap on c.Color {
  Map<String, num> toJson() {
    final rgbColor = toHexColor();
    return {
      'r': rgbColor.r,
      'g': rgbColor.g,
      'b': rgbColor.b,
    };
  }
}

extension ToString on c.Color {
  String toStringHex() {
    final stringColor = toHexColor().toString();
    return stringColor;
  }
}

extension FluentColortoRGB on f.Color {
  c.Color fluentToRGB() {
    return c.Color.rgb(red, green, blue);
  }
}

enum Modes {
  fire,
  overHeat,
}
