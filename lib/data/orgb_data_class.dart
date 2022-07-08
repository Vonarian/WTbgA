import 'dart:ui' as ui;

import 'package:color/color.dart' as c;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:openrgb/openrgb.dart';

class OpenRGBSettings {
  final OverHeatSettings overHeat;
  final FireSettings fireSettings;

  OpenRGBSettings({
    required this.overHeat,
    required this.fireSettings,
  });

  OpenRGBSettings copyWith({
    OverHeatSettings? overHeat,
    FireSettings? fireSettings,
  }) {
    return OpenRGBSettings(
      overHeat: overHeat ?? this.overHeat,
      fireSettings: fireSettings ?? this.fireSettings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'overHeat': overHeat.toMap(),
      'fireSettings': fireSettings.toMap(),
    };
  }

  factory OpenRGBSettings.fromMap(Map<String, dynamic> map) {
    return OpenRGBSettings(
      overHeat: OverHeatSettings.fromMap(map['overHeat'] as Map<String, dynamic>),
      fireSettings: FireSettings.fromMap(map['fireSettings'] as Map<String, dynamic>),
    );
  }

  Future<void> setAllFire(OpenRGBClient client, List<RGBController> data) async {
    await OpenRGBSettings.setAllCustomSetColor(client, data, fireSettings.color);
  }

  Future<void> setAllOff(OpenRGBClient client, List<RGBController> data) async {
    await OpenRGBSettings.setAllCustomSetColor(client, data, const c.Color.rgb(0, 0, 0));
  }

  Future<void> setAllOverHeat(OpenRGBClient client, List<RGBController> data) async {
    List<int> faultyControllers = await OpenRGBSettings.faultyControllerByModes(client, data);
    for (var i = 0; i < data.length; i++) {
      if (!faultyControllers.contains(i)) {
        var controller = data[i];
        final modeIndex = controller.modes.indexWhere((element) => element.modeName.toLowerCase().contains('static'));
        if (modeIndex != -1) {
          await OpenRGBSettings.setAllCustomSetColor(client, data, overHeat.color);
        } else {
          await client.updateLeds(i, controller.colors.length, overHeat.color);
        }
      }
    }
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

  @override
  String toString() {
    return 'OpenRGBSettings{overHeat: $overHeat, fireSettings: $fireSettings}';
  }
}

class OverHeatSettings {
  final c.Color color;

  OverHeatSettings({required this.color});

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
}

class FireSettings {
  final c.Color color;

  FireSettings({required this.color});

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

extension FluentColortoRGB on Color {
  c.Color fluentToRGB() {
    return c.Color.rgb(red, green, blue);
  }
}
