import 'dart:async';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinging_point/pinging_point.dart';
import 'package:wtbgassistant/data_receivers/indicator_receiver.dart';
import 'package:wtbgassistant/data_receivers/map.dart';
import 'package:wtbgassistant/data_receivers/map_info.dart';
import 'package:wtbgassistant/services/extensions.dart';

import '../../main.dart';
import '../../services/helpers.dart';

class GameMap extends ConsumerStatefulWidget {
  final bool isInMatch;

  const GameMap({Key? key, required this.isInMatch}) : super(key: key);

  @override
  GameMapState createState() => GameMapState();
}

class GameMapState extends ConsumerState<GameMap>
    with SingleTickerProviderStateMixin {
  late final StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    _getSizes();
    future = MapObj.mapObj();
    canPlay.addListener(() async {
      if (!canPlay.value) {
        await Future.delayed(const Duration(milliseconds: 3250));
        canPlay.value = true;
      }
    });
    subscription = IndicatorData.getIndicator().listen((data) {
      compass = data?.compass ?? 0;
    });
    Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (mounted) {
        if (!ref.read(provider.inMatchProvider)) return;
        _getSizes();
        future = MapObj.mapObj();
        mapSize = (await MapInfo.getMapInfo()).mapMax * 2;
        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    canPlay.removeListener(() {});
    super.dispose();
  }

  void _getSizes() {
    imageCache.clear();
    if (key.currentContext != null) {
      widgetHeight = key.currentContext!.size!.height;
      widgetWidth = key.currentContext!.size!.width;
    }
  }

  MapObj? getPlayer(List<MapObj> objects) {
    MapObj? player = objects.firstWhereOrNull(
      (MapObj? obj) => obj?.icon == 'Player',
    );
    return player;
  }

  double compass = 0;
  MapObj? player;
  double? mapSize;
  double widgetWidth = 0;
  double widgetHeight = 0;
  final canPlay = ValueNotifier<bool>(true);
  GlobalKey key = GlobalKey();
  final List<String> enemyHexColor = [
    '#f40C00',
    '#ff0D00',
    '#ff0000',
    '#f00C00'
  ];

  FutureBuilder<ui.Image> imageBuilder(MapObj e, Future<ui.Image> future) {
    final settings = ref.watch(provider.appSettingsProvider);
    final wtFocused = ref.watch(provider.wtFocusedProvider);
    double? distance;
    bool flag = false;
    if (player != null &&
        (e.icon == 'Fighter' || e.icon == 'Assault') &&
        e.x != null &&
        e.y != null) {
      distance = getLinearDistanceBetween(
        Offset(e.x!, e.y!),
        Offset(player!.x!, player!.y!),
        mapSize: mapSize ?? 0,
      );
      flag = enemyHexColor.contains(e.color) &&
          (e.icon == 'Fighter' || e.icon == 'Assault') &&
          distance < settings.proximitySetting.distance;
    }
    return FutureBuilder<ui.Image>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (flag) {
              if (!wtFocused && canPlay.value) {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  if (settings.proximitySetting.enabled) {
                    await audio2.play(
                      DeviceFileSource(settings.proximitySetting.path),
                      volume: settings.proximitySetting.volume,
                      mode: PlayerMode.lowLatency,
                    );
                    canPlay.value = false;
                  }
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
                colorHex: e.icon == 'Player' ? '#FFFFFF' : e.color,
                compass: compass,
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
                airfield: true,
                startOffset: Offset(widgetWidth * e.sx!, widgetHeight * e.sy!),
                endOffset: Offset(widgetWidth * e.ex!, widgetHeight * e.ey!),
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
    return widget.isInMatch
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
                          final future = ObjectPainter.getUiImage(
                              'assets/icons/$assetIcon.png');
                          return imageBuilder(e, future);
                        } else if (e.type == 'ground_model') {
                          final future = ObjectPainter.getUiImage(
                              'assets/icons/$assetIcon.png');
                          return imageBuilder(e, future);
                        } else if (e.type == 'airfield') {
                          final future = ObjectPainter.getUiImage(
                              'assets/icons/$assetIcon.png');
                          return imageBuilder(e, future);
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
  final Offset startOffset;
  final Offset endOffset;
  final double? height;
  final double? width;
  final ui.Image image;
  final String colorHex;
  final bool airfield;
  final double compass;

  @override
  Future<void> paint(Canvas canvas, Size size) async {
    var paint1 = Paint()..style = PaintingStyle.fill;
    paint1.colorFilter = ColorFilter.mode(
      HexColor.fromHex(colorHex),
      BlendMode.srcATop,
    );
    var paintAirfieldLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.9;
    paintAirfieldLine.colorFilter =
        ColorFilter.mode(HexColor.fromHex(colorHex), BlendMode.srcATop);

    if (height != null && width != null && !airfield) {
      canvas.drawImage(image, Offset((width! * x), height! * y), paint1);
    } else if (height != null && width != null && airfield) {
      canvas.drawLine(startOffset, endOffset, paintAirfieldLine);
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
    this.airfield = false,
    this.startOffset = const Offset(0, 0),
    this.endOffset = const Offset(0, 0),
    this.compass = 0,
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
