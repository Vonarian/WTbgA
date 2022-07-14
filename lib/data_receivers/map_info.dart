// {
// "grid_steps" : [ 6500.0, 6500.0 ],
// "grid_zero" : [ -28672.0, 28672.0 ],
// "map_generation" : 19,
// "map_max" : [ 32768.0, 32768.0 ],
// "map_min" : [ -32768.0, -32768.0 ]
// }
import 'dart:developer' as dev;
import 'dart:math';

import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:wtbgassistant/main.dart';
import 'package:wtbgassistant/services/helpers.dart';

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
    } catch (e, st) {
      dev.log('ERROR: $e', stackTrace: st);
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

double hypotenuse(double a, double b) => sqrt(a * a + b * b);

double coordBearing(double lat1, double lon1, double lat2, double lon2) {
  final double dLon = radians(lon2 - lon1).toDouble();
  final double lat1Rad = radians(lat1).toDouble();
  final double lat2Rad = radians(lat2).toDouble();
  final double y = sin(dLon) * cos(lat2Rad);
  final double x = cos(lat1Rad) * sin(lat2Rad) - sin(lat1Rad) * cos(lat2Rad) * cos(dLon);
  double bearing = degrees(atan2(x, y));
  return (bearing + 360) % 360;
}

double coordDistance(double lat1, double lon1, double lat2, double lon2) {
  // Find the total distance (in km) between two lat/lon coordinates (dd).
  final lat1Rad = radians(lat1).toDouble();
  final lat2Rad = radians(lat2).toDouble();
  final dLat = lat2Rad - lat1Rad;
  final lon1Rad = radians(lon1).toDouble();
  final lon2Rad = radians(lon2).toDouble();
  final dLon = lon2Rad - lon1Rad;
  final a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadiusKM * c;
}

Coord coordCoord(double lat, double lon, double distance, double bearing) {
  // Finds the lat/lon coordinates "dist" km away from the given "lat" and "lon"
  // coordinate along the given compass "bearing"
  final latRad = radians(lat).toDouble();
  final lonRad = radians(lon).toDouble();
  final bearingRad = radians(bearing).toDouble();
  final lat2 =
      asin(sin(latRad) * cos(distance / earthRadiusKM) + cos(latRad) * sin(distance / earthRadiusKM) * cos(bearingRad));
  final lon2 = lonRad +
      atan2(sin(bearingRad) * sin(distance / earthRadiusKM) * cos(latRad),
          cos(distance / earthRadiusKM) - sin(latRad) * sin(lat2));
  return Coord(degrees(lat2), degrees(lon2), bearing: bearing, distance: distance);
}

Coord getObjectCoords(double x, double y, double mapSize) {
  //Convert the provided x and y coordinates to lat and lon coordinates
  final double xDistance = x * mapSize;
  final double yDistance = y * mapSize;
  final double distance = hypotenuse(xDistance, yDistance);
  double bearing = degrees(atan2(xDistance, yDistance)) + 90;
  if (bearing < 0) {
    bearing += 360;
  }
  return coordCoord(0, 0, distance, bearing);
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
