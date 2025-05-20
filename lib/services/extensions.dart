import 'dart:convert';
import 'dart:ui' as ui;

import 'package:color/color.dart' as color;
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:gap/gap.dart';

extension HexColor on ui.Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static ui.Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return ui.Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `false`).
  String toHex({bool leadingHashSign = false}) =>
      '${leadingHashSign ? '#' : ''}'
      '${a.toInt().toRadixString(16).padLeft(2, '0')}'
      '${r.toInt().toRadixString(16).padLeft(2, '0')}'
      '${g.toInt().toRadixString(16).padLeft(2, '0')}'
      '${b.toInt().toRadixString(16).padLeft(2, '0')}';
}

extension IsNotNull on Object? {
  bool get notNull => this != null;
}

extension ToRGB on ui.Color {
  color.Color toRGB() {
    return color.Color.rgb(r, g, b);
  }
}

extension ColorFromMap on color.Color {
  static color.Color fromMap(Map<String, dynamic> map) {
    return color.Color.rgb(map['r'], map['g'], map['b']);
  }
}

extension ColorToMap on color.Color {
  Map<String, num> toJson() {
    final color = toRgbColor();
    return {
      'r': color.r,
      'g': color.g,
      'b': color.b,
    };
  }
}

extension ToString on color.Color {
  String toStringHex() {
    final stringColor = toHexColor().toString();
    return stringColor;
  }
}

extension FluentColortoRGB on fluent.Color {
  color.Color fluentToRGB() {
    return color.Color.rgb(r, b, b);
  }
}

extension StringToJson on String {
  dynamic decodeJson() => jsonDecode(this);
}

extension EnhancedWidgetList on List<Widget> {
  List<Widget> withDividerBetween(BuildContext context) => [
        if (isNotEmpty) this[0],
        for (int i = 1; i < length; i++) ...[
          this[i],
          Divider(
              style: DividerThemeData(
            decoration: BoxDecoration(
                color: FluentTheme.of(context).scaffoldBackgroundColor),
          )),
        ],
      ];

  List<Widget> withSpaceBetween(double space) => [
        if (isNotEmpty) this[0],
        for (int i = 1; i < length; i++) ...[
          Gap(space),
          this[i],
        ],
      ];
}
