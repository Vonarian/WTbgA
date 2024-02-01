// {
// "grid_steps" : [ 6500.0, 6500.0 ],
// "grid_zero" : [ -28672.0, 28672.0 ],
// "map_generation" : 19,
// "map_max" : [ 32768.0, 32768.0 ],
// "map_min" : [ -32768.0, -32768.0 ]
// }s dev;

import '../main.dart';

const double earthRadiusKM = 6378.137;

class MapInfo {
  final double gridSteps;
  final double gridZero;
  final int mapGeneration;
  final double mapMax;
  final double mapMin;

  static Future<MapInfo> getMapInfo() async {
    try {
      final response = await dio.get('http://localhost:8111/map_info.json');
      final map = response.data;
      return MapInfo(
        gridSteps: map['grid_steps'][0] as double,
        gridZero: map['grid_zero'][1] as double,
        mapGeneration: map['map_generation'] as int,
        mapMax: map['map_max'][0] as double,
        mapMin: map['map_min'][0] as double,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  String toString() {
    return 'MapInfo{gridSteps: $gridSteps, gridZero: $gridZero, mapGeneration: $mapGeneration, mapMax: $mapMax, mapMin: $mapMin}';
  }

  Map<String, dynamic> toMap() {
    return {
      'gridSteps': gridSteps,
      'gridZero': gridZero,
      'mapGeneration': mapGeneration,
      'mapMax': mapMax,
      'mapMin': mapMin,
    };
  }

  factory MapInfo.fromMap(Map<String, dynamic> map) {
    return MapInfo(
      gridSteps: map['gridSteps'] as double,
      gridZero: map['gridZero'] as double,
      mapGeneration: map['mapGeneration'] as int,
      mapMax: map['mapMax'] as double,
      mapMin: map['mapMin'] as double,
    );
  }

  const MapInfo({
    required this.gridSteps,
    required this.gridZero,
    required this.mapGeneration,
    required this.mapMax,
    required this.mapMin,
  });
}

class Coord {
  final double lat;
  final double lon;
  final double? distance;
  final double? bearing;

  const Coord(this.lat, this.lon, {this.distance, this.bearing});

  @override
  String toString() {
    return 'Coord{lat: $lat, lon: $lon, distance: $distance, bearing: $bearing}';
  }
}
