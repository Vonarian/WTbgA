import 'package:dio/dio.dart';

import '../main.dart';

enum MapType {
  aircraft,
  groundModel,
  respawnBaseFighter,
  captureZone,
  respawnBaseTank,
  airfield,
  bombingPoint,
  other;

  String get name => switch (this) {
    aircraft => 'aircraft',
    groundModel => 'ground_model',
    respawnBaseFighter => 'respawn_base_fighter',
    captureZone => 'capture_zone',
    respawnBaseTank => 'respawn_base_tank',
    airfield => 'airfield',
    bombingPoint => 'bombing_point',
    other => 'other',
  };

  static MapType fromString(String type) {
    return MapType.values.firstWhere(
      (e) => e.name == type.toLowerCase(),
      orElse: () => MapType.other,
    );
  }
}

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

  final MapType type;
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
        type: MapType.fromString(map['type'] as String),
        color: map['color'] as String,
        colors: map['color[]'] != null
            ? map['color[]'].cast<int>() as List<int>
            : null,
        blink: map['blink'] as int,
        icon: map['icon'] as String,
        iconBg: (map['icon_bg'] ?? 'NONE') as String,
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
        type: MapType.fromString(map['type'] as String),
        color: map['color'] as String,
        colors: map['color[]'] != null
            ? map['color[]'].cast<int>() as List<int>
            : null,
        blink: map['blink'] as int,
        icon: map['icon'] as String,
        iconBg: (map['icon_bg'] ?? 'NONE'),
        sx: null,
        sy: null,
        ex: null,
        ey: null,
        x: map['x'] as double?,
        y: map['y'] as double?,
        dx: null,
        dy: null,
      );
    } else {
      return MapObj(
        type: MapType.fromString(map['type'] as String),
        color: map['color'] as String,
        colors: map['color[]'] != null
            ? map['color[]'].cast<int>() as List<int>
            : null,
        blink: map['blink'] as int,
        icon: map['icon'] as String,
        iconBg: (map['icon_bg'] ?? 'NONE'),
        sx: map['sx'],
        sy: map['sy'],
        ex: map['ex'],
        ey: map['ey'],
        x: null,
        y: null,
        dx: null,
        dy: null,
      );
    }
  }

  static Future<List<MapObj>> mapObj() async {
    try {
      Response response = await dio
          .get('http://localhost:8111/map_obj.json')
          .timeout(const Duration(milliseconds: 350));

      List<MapObj> mapObjList = [];
      if (response.data == null) throw Exception('Empty response');
      if (response.data.isNotEmpty) {
        for (final Map<String, dynamic> element in response.data) {
          mapObjList.add(MapObj.fromMap((element)));
        }
      }
      return mapObjList;
    } catch (e) {
      rethrow;
    }
  }
}
