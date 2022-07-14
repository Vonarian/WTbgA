import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wtbgassistant/data_receivers/map.dart';
import 'package:wtbgassistant/data_receivers/map_info.dart';
import 'package:wtbgassistant/services/extensions.dart';
import 'package:wtbgassistant/services/helpers.dart';

class GameMap extends StatefulWidget {
  final bool inHangar;

  const GameMap({Key? key, required this.inHangar}) : super(key: key);

  @override
  GameMapState createState() => GameMapState();
}

class GameMapState extends State<GameMap> {
  @override
  void initState() {
    super.initState();
    _getSizes();
    future = MapObj.mapObj();
    Timer.periodic(const Duration(milliseconds: 1200), (timer) async {
      if (mounted) {
        _getSizes();
        future = MapObj.mapObj();
        List<MapObj> mapObjects = await future;
        List<MapObj> enemyFighters = getEnemyFighters(mapObjects);
        player = getPlayer(mapObjects);
        MapInfo mapInfo = await MapInfo.getMapInfo();
        for (MapObj enemyFighter in enemyFighters) {
          if (enemyFighter.iconBg == 'FighterTarget') {
            if (enemyFighter.x != null && enemyFighter.y != null && player?.x != null && player?.y != null) {
              Coord coord = getObjectCoords(player!.x!, player!.y!, mapInfo.mapMax * 2);
              Coord coord2 = getObjectCoords(enemyFighter.x!, enemyFighter.y!, mapInfo.mapMax * 2);
              double distance = coordDistance(coord.lat, coord.lon, coord2.lat, coord2.lon);
              print(distance);
            }
          }
        }
        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  void _getSizes() {
    imageCache.clear();
    if (key.currentContext != null) {
      widgetHeight = key.currentContext!.size!.height;
      widgetWidth = key.currentContext!.size!.width;
    }
  }

  double getLinearDistanceBetween(Offset offset1, Offset offset2, {required double mapSize}) {
    final Offset delta = (offset1 - offset2) * mapSize;
    final distance = delta.distance;
    return double.parse(distance.abs().toStringAsFixed(2));
  }

  double getAngleBetweenPoints(double x, double y, {required double mapSize}) {
    final angle = math.atan2(x, y);
    return degrees(angle);
  }

  List<MapObj> getEnemyFighters(List<MapObj> mapObjects) {
    return mapObjects.where((MapObj mapObj) => mapObj.icon == 'Fighter').toList();
  }

  MapObj getPlayer(List<MapObj> objects) {
    MapObj player = objects.firstWhere((MapObj obj) => obj.icon == 'Player');
    return player;
  }

  MapObj? player;

  double widgetWidth = 0;

  double widgetHeight = 0;
  GlobalKey key = GlobalKey();
  final List<String> enemyHexColor = ['#f40C00', '#ff0D00', '#ff0000'];

  late Future<ui.Image> myFuture;

  FutureBuilder<ui.Image> imageBuilder(MapObj e) {
    return FutureBuilder<ui.Image>(
        future: myFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (e.type == 'aircraft') {
              return CustomPaint(
                  painter: ObjectPainter(
                x: e.x!,
                y: e.y!,
                context: context,
                height: widgetHeight,
                width: widgetWidth,
                image: snapshot.data!,
                colorHex: e.color,
              ));
            } else if (e.type == 'ground_model') {
              return CustomPaint(
                  painter: ObjectPainter(
                x: e.x!,
                y: e.y!,
                context: context,
                height: widgetHeight,
                width: widgetWidth,
                image: snapshot.data!,
                colorHex: e.color,
              ));
            } else if (e.type == 'airfield') {
              return CustomPaint(
                  painter: ObjectPainter(
                x: e.sx!,
                y: e.sy!,
                context: context,
                height: widgetHeight,
                width: widgetWidth,
                image: snapshot.data!,
                colorHex: e.color,
              ));
            } else {
              return const Text('NOPE');
            }
          }
          if (snapshot.hasError) {
            return const Text('');
          } else {
            return const Text('');
          }
        });
  }

  String assetIcon = '';

  Future<List<MapObj>> future = MapObj.mapObj();

  @override
  Widget build(BuildContext context) {
    return !widget.inHangar
        ? Stack(
            children: [
              Image.network(
                'http://localhost:8111/map.img',
                key: key,
                errorBuilder: (context, e, st) {
                  return const Text('Error loading map');
                },
              ),
              FutureBuilder<List<MapObj>>(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Widget> columnChildren = snapshot.data!.map((e) {
                        switch (e.icon.toLowerCase()) {
                          case 'airdefence':
                            assetIcon = 'airdefence';
                            break;
                          case 'lighttank':
                            assetIcon = 'light';
                            break;
                          case 'mediumtank':
                            assetIcon = 'medium';
                            break;
                          case 'spaa':
                            assetIcon = 'spaa';
                            break;
                          case 'player':
                            assetIcon = 'player';
                            break;
                          case 'heavytank':
                            assetIcon = 'heavytank';
                            break;
                          case 'fighter':
                            assetIcon = 'fighter';
                            break;
                        }
                        if (e.type == 'aircraft') {
                          myFuture = ObjectPainter.getUiImage('assets/icons/$assetIcon.png');
                          return imageBuilder(e);
                        } else if (e.type == 'ground_model') {
                          myFuture = ObjectPainter.getUiImage('assets/icons/$assetIcon.png');
                          return imageBuilder(e);
                        } else if (e.type == 'airfield') {
                          myFuture = ObjectPainter.getUiImage('assets/icons/$assetIcon.png');
                          return imageBuilder(e);
                        } else {
                          return const SizedBox();
                        }
                      }).toList();

                      return Stack(
                        children: columnChildren,
                      );
                    }
                    if (snapshot.hasError) {
                      if (kDebugMode) {
                        print(snapshot.error);
                      }
                      return const SizedBox();
                    } else {
                      return const SizedBox();
                    }
                  }),
            ],
          )
        : const Center(
            child: Text(
              'No Data',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
  }
}

class ObjectPainter extends CustomPainter {
  final double y;
  final double x;
  final double? height;
  final double? width;
  final BuildContext context;
  final ui.Image image;
  final String colorHex;

  @override
  Future<void> paint(Canvas canvas, Size size) async {
    var paint1 = Paint()..style = PaintingStyle.fill;
    paint1.colorFilter = ColorFilter.mode(
      HexColor.fromHex(colorHex),
      BlendMode.srcATop,
    );

    if (height != null && width != null) {
      canvas.drawImage(image, Offset((width! * x), height! * y), paint1);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  const ObjectPainter(
      {required this.y,
      required this.x,
      required this.context,
      required this.width,
      required this.height,
      required this.image,
      required this.colorHex});

  static Future<ui.Image> getUiImage(String imageAssetPath) async {
    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    final codec = await ui.instantiateImageCodec(
      assetImageByteData.buffer.asUint8List(),
    );
    final image = (await codec.getNextFrame()).image;
    return image;
  }
}
