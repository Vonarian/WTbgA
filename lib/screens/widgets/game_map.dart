import 'dart:async';
import 'dart:ui' as ui;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wtbgassistant/data_receivers/map.dart';

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
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        image = Image.network(
          'http://localhost:8111/map.img',
          key: key,
          errorBuilder: (context, e, st) {
            return const Text('Error loading map');
          },
        );
        _getSizes();
        setState(() {});
      }
    });
  }

  _getSizes() {
    imageCache.clear();
    if (key.currentContext != null) {
      widgetHeight = key.currentContext!.size!.height;
      widgetWidth = key.currentContext!.size!.width;
    }
  }

  double widgetWidth = 0;
  double widgetHeight = 0;
  GlobalKey key = GlobalKey();

  Image image = Image.network(
    'http://localhost:8111/map.img',
  );

  late Future<ui.Image> myFuture;
  FutureBuilder imageBuilder(MapObj e) {
    return FutureBuilder<ui.Image>(
        future: myFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (e.type == 'aircraft') {
              List<int>? colors = e.colors;
              return CustomPaint(
                  painter: ObjectPainter(
                x: e.x!,
                y: e.y!,
                context: context,
                height: widgetHeight,
                width: widgetWidth,
                image: snapshot.data!,
                colors: colors,
              ));
            } else if (e.type == 'ground_model') {
              List<int>? colors = e.colors;
              return CustomPaint(
                  painter: ObjectPainter(
                x: e.x!,
                y: e.y!,
                context: context,
                height: widgetHeight,
                width: widgetWidth,
                image: snapshot.data!,
                colors: colors,
              ));
            } else if (e.type == 'airfield') {
              List<int>? colors = e.colors;

              return CustomPaint(
                  painter: ObjectPainter(
                x: e.sx!,
                y: e.sy!,
                context: context,
                height: widgetHeight,
                width: widgetWidth,
                image: snapshot.data!,
                colors: colors,
              ));
            } else {
              return const Text('NOPE');
            }
          }
          if (snapshot.hasError) {
            return const Text('ERROR');
          } else {
            return const Text('LOADING');
          }
        });
  }

  String assetIcon = '';
  @override
  Widget build(BuildContext context) {
    return !widget.inHangar
        ? Stack(
            children: [
              image,
              FutureBuilder<List<MapObj>>(
                  future: MapObj.mapObj(),
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
                          myFuture = ObjectPainter.getUiImage(
                              'assets/icons/$assetIcon.png');
                          return imageBuilder(e);
                        } else if (e.type == 'ground_model') {
                          myFuture = ObjectPainter.getUiImage(
                              'assets/icons/$assetIcon.png');
                          return imageBuilder(e);
                        } else if (e.type == 'airfield') {
                          myFuture = ObjectPainter.getUiImage(
                              'assets/icons/$assetIcon.png');
                          return imageBuilder(e);
                        } else {
                          return const Text('NOPE');
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
            child: Text('In Hangar'),
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
  final List<int>? colors;
  @override
  Future<void> paint(Canvas canvas, Size size) async {
    var paint1 = Paint()..style = PaintingStyle.fill;
    paint1.colorFilter = ColorFilter.mode(
      Color.fromARGB(255, colors![0], colors![1], colors![2]),
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
      required this.colors});
  static Future<ui.Image> getUiImage(String imageAssetPath) async {
    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    final codec = await ui.instantiateImageCodec(
      assetImageByteData.buffer.asUint8List(),
    );
    final image = (await codec.getNextFrame()).image;
    return image;
  }
}
