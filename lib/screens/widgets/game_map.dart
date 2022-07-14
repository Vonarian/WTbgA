import 'dart:async';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinging_point/pinging_point.dart';
import 'package:system_windows/system_windows.dart';
import 'package:wtbgassistant/data_receivers/map.dart';
import 'package:wtbgassistant/data_receivers/map_info.dart';
import 'package:wtbgassistant/services/extensions.dart';

import '../../main.dart';

class GameMap extends ConsumerStatefulWidget {
  final bool inHangar;

  const GameMap({Key? key, required this.inHangar}) : super(key: key);

  @override
  GameMapState createState() => GameMapState();
}

class GameMapState extends ConsumerState<GameMap> {
  var systemWindows = SystemWindows();

  @override
  void initState() {
    super.initState();
    _getSizes();
    future = MapObj.mapObj();
    Timer.periodic(const Duration(milliseconds: 1200), (timer) async {
      if (mounted) {
        _getSizes();
        future = MapObj.mapObj();
        mapSize = (await MapInfo.getMapInfo()).mapMax * 2;
        windows = await systemWindows.getActiveApps();
        wtFocused = windows.firstWhere((element) => element.title.contains('War Thunder')).isActive;
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
    return double.parse(distance.abs().toStringAsFixed(0));
  }

  MapObj getPlayer(List<MapObj> objects) {
    MapObj player = objects.firstWhere((MapObj obj) => obj.icon == 'Player');
    return player;
  }

  MapObj? player;
  double? mapSize;
  double widgetWidth = 0;
  double widgetHeight = 0;
  List<SystemWindow> windows = [];
  bool wtFocused = false;
  GlobalKey key = GlobalKey();
  final List<String> enemyHexColor = ['#f40C00', '#ff0D00', '#ff0000', '#f00C00'];

  late Future<ui.Image> myFuture;

  FutureBuilder<ui.Image> imageBuilder(MapObj e) {
    double? distance;
    bool? flag;
    if (player != null && e.icon == 'Fighter' && e.x != null && e.y != null) {
      distance = getLinearDistanceBetween(
        Offset(e.x!, e.y!),
        Offset(player!.x!, player!.y!),
        mapSize: mapSize ?? 0,
      );
      flag = enemyHexColor.contains(e.color) && e.icon == 'Fighter' && distance < 850;
    }
    return FutureBuilder<ui.Image>(
        future: myFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (flag ?? false) {
              if (!wtFocused) {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  final settings = ref.watch(provider.appSettingsProvider).proximitySetting;
                  await audio2.play(
                    DeviceFileSource(settings.path),
                    volume: settings.volume,
                    mode: PlayerMode.lowLatency,
                  );
                });
              }
              if (e.type == 'aircraft') {
                return PingingPoint.pingingPoint(
                  x: e.x!,
                  y: e.y!,
                  pointColor: HexColor.fromHex(e.color),
                  pointSize: 8,
                  height: widgetHeight,
                  width: widgetWidth,
                );
              } else if (e.type == 'ground_model') {
                return CustomPaint(
                    painter: ObjectPainter(
                  x: e.x!,
                  y: e.y!,
                  height: widgetHeight,
                  width: widgetWidth,
                  image: snapshot.data!,
                  colorHex: e.color,
                ));
              } else if (e.type == 'airfield') {
                return CustomPaint(
                    painter: ObjectPainter(
                  x: e.x!,
                  y: e.y!,
                  height: widgetHeight,
                  width: widgetWidth,
                  image: snapshot.data!,
                  colorHex: e.color,
                ));
              } else {
                return const Text('NOPE');
              }
            }
            if (e.type == 'aircraft') {
              return CustomPaint(
                  painter: ObjectPainter(
                x: e.x!,
                y: e.y!,
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
                      player = getPlayer(snapshot.data!);
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

  const ObjectPainter({
    required this.y,
    required this.x,
    this.width,
    this.height,
    required this.image,
    required this.colorHex,
  });

  static Future<ui.Image> getUiImage(String imageAssetPath) async {
    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    final codec = await ui.instantiateImageCodec(
      assetImageByteData.buffer.asUint8List(),
    );
    final image = (await codec.getNextFrame()).image;
    return image;
  }
}
