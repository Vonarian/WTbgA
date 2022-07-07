import 'dart:ui' as ui;

import 'package:color/color.dart' as c;
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
    for (var i = 0; i < data.length; i++) {
      var controller = data[i];
      await client.updateLeds(i, controller.colors.length, fireSettings.color);
      for (var j = 0; j < controller.colors.length; j++) {
        if (controller.colors[0].toRgbColor() == const ui.Color.fromARGB(0, 0, 0, 0).toRGB()) {
          await client.setMode(
              i,
              controller.modes.indexWhere((element) => element.modeName.toLowerCase().contains('static')),
              fireSettings.color);
        }
      }
    }
  }

  Future<void> setAllOff(OpenRGBClient client, List<RGBController> data) async {
    for (var i = 0; i < data.length; i++) {
      var controller = data[i];
      await client.updateLeds(i, controller.colors.length, const c.Color.rgb(0, 0, 0));
      if (controller.colors[0].toRgbColor() != const ui.Color.fromARGB(0, 0, 0, 0).toRGB()) {
        final modeIndex = controller.modes.indexWhere((element) => element.modeName.toLowerCase().contains('static'));
        if (modeIndex != -1) {
          await client.setMode(i, modeIndex, const c.Color.rgb(0, 0, 0));
        }
      }
    }
  }

  Future<void> setAllOverHeat(OpenRGBClient client, List<RGBController> data) async {
    var count = data.length - 1;
    for (var i = 0; i < count; i++) {
      var controller = data[i];
      await client.updateLeds(i, controller.colors.length, fireSettings.color);
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
