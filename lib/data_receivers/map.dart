import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class MapObj {
  const MapObj({
    required this.type,
    required this.color,
    required this.colors,
    required this.blink,
    required this.icon,
    required this.iconBg,
    required this.sx,
    required this.sy,
    required this.ex,
    required this.ey,
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
  });

  final String type;
  final String color;
  final List<int>? colors;
  final int blink;
  final String icon;
  final String iconBg;
  final double? sx;
  final double? sy;
  final double? ex;
  final double? ey;
  final double? x;
  final double? y;
  final double? dx;
  final double? dy;

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'color': color,
      'color[]': colors,
      'blink': blink,
      'icon': icon,
      'iconBg': iconBg,
      'sx': sx,
      'sy': sy,
      'ex': ex,
      'ey': ey,
      'x': x,
      'y': y,
      'dx': dx,
      'dy': dy,
    };
  }

  factory MapObj.fromMap(Map<String, dynamic> map) {
    if (map['type'] == 'aircraft') {
      return MapObj(
        type: map['type'] as String,
        color: map['color'] as String,
        colors: map['color[]'] != null
            ? map['color[]'].cast<int>() as List<int>
            : null,
        blink: map['blink'] as int,
        icon: map['icon'] as String,
        iconBg: (map['iconBg'] ?? 'NONE') as String,
        sx: null,
        sy: null,
        ex: null,
        ey: null,
        x: map['x'] as double,
        y: map['y'] as double,
        dx: map['dx'] as double,
        dy: map['dy'] as double,
      );
    } else if (map['type'] == 'ground_model' ||
        map['type'] == 'respawn_base_fighter' ||
        map['type'] == 'capture_zone' ||
        map['type'] == 'respawn_base_tank') {
      return MapObj(
        type: map['type'] as String,
        color: map['color'] as String,
        colors: map['color[]'] != null
            ? map['color[]'].cast<int>() as List<int>
            : null,
        blink: map['blink'] as int,
        icon: map['icon'] as String,
        iconBg: (map['iconBg'] ?? 'NONE') as String,
        sx: null,
        sy: null,
        ex: null,
        ey: null,
        x: map['x'] as double,
        y: map['y'] as double,
        dx: null,
        dy: null,
      );
    } else {
      return MapObj(
        type: map['type'] as String,
        color: map['color'] as String,
        colors: map['color[]'] != null
            ? map['color[]'].cast<int>() as List<int>
            : null,
        blink: map['blink'] as int,
        icon: map['icon'] as String,
        iconBg: (map['iconBg'] ?? 'NONE') as String,
        sx: map['sx'] as double,
        sy: map['sy'] as double,
        ex: map['ex'] as double,
        ey: map['ey'] as double,
        x: null,
        y: null,
        dx: null,
        dy: null,
      );
    }
  }

  static Future<List<MapObj>> mapObj() async {
    try {
      Response response =
          await get(Uri.parse('http://localhost:8111/map_obj.json'));

      List<dynamic> list = jsonDecode(response.body);
      List<MapObj> mapObjList = [];
      for (final Map<String, dynamic> element in list) {
        mapObjList.add(MapObj.fromMap((element)));
      }
      return mapObjList;
    } catch (e, st) {
      if (kDebugMode) {
        log('ERROR: $e', stackTrace: st);
      }
      rethrow;
    }
  }
}
