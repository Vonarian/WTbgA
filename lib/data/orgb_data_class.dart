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

  Future<void> setAll(OpenRGBClient client) async {
    var data = await client.getAllControllers();
    var count = data.length;
    for (var i = 0; i < count; i++) {
      var controller = data[i];
      client.updateLeds(i, controller.colors.length, fireSettings.color);
    }
  }
}

class OverHeatSettings {
  final c.Color color;
  final ModeData? mode;
  final int controllerId;

  OverHeatSettings({required this.color, this.mode, required this.controllerId});

  Map<String, dynamic> toMap() {
    return {
      'color': color.toJson(),
      'mode': mode?.toMap(),
      'controllerId': controllerId,
    };
  }

  factory OverHeatSettings.fromMap(Map<String, dynamic> map) {
    return OverHeatSettings(
      color: ColorFromMap.fromMap(map['color'] as Map<String, num>),
      mode: ModeData.fromMap(map['mode'] as Map<String, dynamic>),
      controllerId: map['controllerId'] as int,
    );
  }
}

class FireSettings {
  final c.Color color;
  final ModeData? mode;
  final int controllerId;

  FireSettings({required this.color, this.mode, required this.controllerId});

  Map<String, dynamic> toMap() {
    return {
      'color': color.toJson(),
      'mode': mode?.toMap(),
      'controllerId': controllerId,
    };
  }

  factory FireSettings.fromMap(Map<String, dynamic> map) {
    return FireSettings(
      color: ColorFromMap.fromMap(map['color'] as Map<String, num>),
      mode: ModeData.fromMap(map['mode'] as Map<String, dynamic>),
      controllerId: map['controllerId'] as int,
    );
  }
}

extension ToRGB on ui.Color {
  c.Color toRGB() {
    return c.Color.rgb(red, green, blue);
  }
}

extension ColorFromMap on c.Color {
  static c.Color fromMap(Map<String, num> map) {
    return c.Color.rgb(map['r'] as num, map['g'] as num, map['b'] as num).toRgbColor();
  }
}
extension ToMao on c.Color {
  Map<String, int> toJson() {
    final rgbColor = toRgbColor();
    return {
      'r': rgbColor.r.toInt(),
      'g': rgbColor.g.toInt(),
      'b': rgbColor.b.toInt(),
    };
  }
}