import 'dart:math' as math;
import 'dart:math';

import 'package:percent_indicator/circular_percent_indicator.dart';

import '../data_receivers/map_info.dart';

double degrees(double radians) {
  return radians * (180.0 / math.pi);
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
