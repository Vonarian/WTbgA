import 'dart:math' as math;
import 'dart:ui';

double getLinearDistanceBetween(Offset offset1, Offset offset2,
    {required double mapSize}) {
  final Offset delta = (offset1 - offset2) * mapSize;
  final distance = delta.distance;
  return double.parse(distance.abs().toStringAsFixed(0));
}

double getDegreesBetween(
    double x, double y, double x2, double y2, double compass) {
  final double deltaX = x2 - x;
  final double deltaY = y2 - y;

  double theta = -compass + 90;
  theta = degreeNormalize(theta);

  double distance = math.sqrt(deltaX * deltaX + deltaY * deltaY);
  double lineDistance =
      (math.tan(radians(theta)) * deltaX + deltaY).abs() / distance;

  double alpha = degrees(math.asin(lineDistance / distance));
  return alpha;
  // final double compassPrime = compass > 180 ? compass - 360 : compass;
  // print('compass: $compass deltaX: ${x2 - x} deltaY: ${y2 - y} compassPrime: $compassPrime');
  // if (deltaX >= 0 && deltaY <= 0) {
  //   return degrees(math.atan2(deltaX.abs(), deltaY.abs())) - compassPrime;
  // }
  // if (deltaX >= 0 && deltaY >= 0) {
  //   return 180 - compassPrime - degrees(math.atan2(deltaX.abs(), deltaY.abs()));
  // }
  // if (deltaX <= 0 && deltaY >= 0) {
  //   return 180 - degrees(math.atan2(deltaX.abs(), deltaY.abs())) + compassPrime;
  // }
  // if (deltaX <= 0 && deltaY <= 0) {
  //   return degrees(math.atan2(deltaX.abs(), deltaY.abs()));
  // }
  // return 0;
}

double degrees(double radians) {
  return radians * (180.0 / math.pi);
}

double degreeNormalize(double degrees) {
  if (degrees > 360) {
    degrees -= 360;
  } else if (degrees < 0) {
    degrees += 360;
  }
  return degrees;
}

double radians(double degrees) {
  return degrees * (math.pi / 180.0);
}

double hypotenuse(double a, double b) {
  return math.sqrt(a * a + b * b);
}

double angleToTarget(double x, double y, double x2, double y2) {
  double vpe = degrees(math.atan(((x - x2) / (y - y2))));
  if (vpe < 0) {
    vpe += 360;
  }
  return vpe;
}
