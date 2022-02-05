import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wtbgassistant/data_receivers/map.dart';

class GameMap extends StatefulWidget {
  final bool inHangar;
  const GameMap({Key? key, required this.inHangar}) : super(key: key);

  @override
  _GameMapState createState() => _GameMapState();
}

class _GameMapState extends State<GameMap> {
  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        image = Image.network(
          'http://localhost:8111/map.img',
          key: key,
        );

        setState(() {});
        _getSizes();
      }
    });
  }

  _getSizes() {
    imageCache!.clear();
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
  FutureBuilder imageFuture(MapObj e) {
    return FutureBuilder<ui.Image>(
        future: myFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (e.type == 'aircraft') {
              return CustomPaint(
                  painter: ObjectPainter(
                x: e.x!,
                y: e.y!,
                colors: e.colors,
                context: context,
                height: widgetHeight,
                width: widgetWidth,
                image: snapshot.data!,
              ));
            } else if (e.type == 'ground_model') {
              return CustomPaint(
                  painter: ObjectPainter(
                x: e.x!,
                y: e.y!,
                colors: e.colors,
                context: context,
                height: widgetHeight,
                width: widgetWidth,
                image: snapshot.data!,
              ));
            } else if (e.type == 'airfield') {
              return CustomPaint(
                  painter: ObjectPainter(
                x: e.sx!,
                y: e.sy!,
                colors: e.colors,
                context: context,
                height: widgetHeight,
                width: widgetWidth,
                image: snapshot.data!,
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
    if (kDebugMode) {}
    return Stack(children: <Widget>[
      !widget.inHangar
          ? image
          : ImageFiltered(
              child: Image.asset(
                'assets/bg.jpg',
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
              imageFilter: ui.ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0)),
      !widget.inHangar
          ? FutureBuilder<List<MapObj>>(
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
                      return imageFuture(e);
                    } else if (e.type == 'ground_model') {
                      myFuture = ObjectPainter.getUiImage(
                          'assets/icons/$assetIcon.png');
                      return imageFuture(e);
                    } else if (e.type == 'airfield') {
                      myFuture = ObjectPainter.getUiImage(
                          'assets/icons/$assetIcon.png');
                      return imageFuture(e);
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
              })
          : Container(),
    ]);
  }
}

class ObjectPainter extends CustomPainter {
  double y;
  double x;
  double? height;
  double? width;
  List<int?>? colors;
  BuildContext context;
  ui.Image image;

  @override
  Future<void> paint(Canvas canvas, Size size) async {
    var paint1 = Paint()
      ..color =
          Color.fromARGB(255, colors?[0] ?? 0, colors?[1] ?? 0, colors?[2] ?? 0)
      ..style = PaintingStyle.fill;

    if (height != null && width != null) {
      canvas.drawImage(image, Offset((width! * x), height! * y), paint1);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  ObjectPainter(
      {required this.y,
      required this.x,
      required this.colors,
      required this.context,
      required this.width,
      required this.height,
      required this.image});
  static Future<ui.Image> getUiImage(String imageAssetPath) async {
    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    final codec = await ui.instantiateImageCodec(
      assetImageByteData.buffer.asUint8List(),
    );
    final image = (await codec.getNextFrame()).image;
    return image;
  }
}
