import 'dart:ui';

double getLinearDistanceBetween(Offset offset1, Offset offset2,
    {required double mapSize}) {
  final Offset delta = (offset1 - offset2) * mapSize;
  final distance = delta.distance;
  return double.parse(distance.abs().toStringAsFixed(0));
}
