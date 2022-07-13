import 'dart:ui' as ui;

import 'package:color/color.dart' as c;
import 'package:fluent_ui/fluent_ui.dart' as f;

extension HexColor on ui.Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static ui.Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return ui.Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `false`).
  String toHex({bool leadingHashSign = false}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

extension IsNotNull on Object? {
  bool get notNull => this != null;
}

extension ToRGB on ui.Color {
  c.Color toRGB() {
    return c.Color.rgb(red, green, blue);
  }
}

extension ColorFromMap on c.Color {
  static c.Color fromMap(Map<String, dynamic> map) {
    return c.Color.rgb(map['r'], map['g'], map['b']);
  }
}

extension ColorToMap on c.Color {
  Map<String, num> toJson() {
    final color = toRgbColor();
    return {
      'r': color.r,
      'g': color.g,
      'b': color.b,
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
