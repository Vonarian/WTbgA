import 'dart:async';
import 'dart:io';

import 'package:blinking_text/blinking_text.dart';
import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:path/path.dart' as p;
import 'package:wtbgassistant/data_receivers/state_receiver.dart';

import '../main.dart';

class TransparentPage extends StatefulWidget {
  final int gLoad;
  final int gearLimit;
  final int flapLimit;
  final double fontSize;
  const TransparentPage(
      {Key? key,
      required this.gLoad,
      required this.gearLimit,
      required this.flapLimit,
      required this.fontSize})
      : super(key: key);
  @override
  _TransparentPageState createState() => _TransparentPageState();
}

class _TransparentPageState extends State<TransparentPage> {
  WindowEffect effect = WindowEffect.transparent;
  Color color = Platform.isWindows ? Color(0x00222222) : Colors.transparent;
  final dragController = DragController();

  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (!mounted) return;
      setState(() {});
    });
    this.setWindowEffect(this.effect);
    setWindow();
  }

  Future<void> setWindow() async {
    await keyRegister();
    await Window.enterFullscreen();
    await Process.start(pathAHK, [path]);
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await hotKeyManager.unregisterAll();
  }

  Future<void> keyRegister() async {
    await hotKey.register(HotKey(KeyCode.digit1, modifiers: [KeyModifier.alt]),
        keyDownHandler: (_) {
      Navigator.pushReplacementNamed(context, '/home');
    });
    await hotKey
        .register(HotKey(KeyCode.backspace, modifiers: [KeyModifier.alt]),
            keyDownHandler: (_) {
      show = !show;
    });
  }

  Future<void> setWindowEffect(WindowEffect? value) async {
    Window.setEffect(effect: value!, color: this.color);
    this.setState(() => this.effect = value);
  }

  String path = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets/AutoHotkeyU64.ahk'
  ]);
  String pathAHK = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets/AutoHotkeyU64.exe'
  ]);
  bool flashGear = false;
  bool flashFlap = false;
  bool flashLoad = false;
  bool inHangar = true;
  bool show = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<ToolDataState>(
        future: ToolDataState.getState(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.altitude == 32 &&
                snapshot.data!.gear == 100 &&
                snapshot.data!.ias == 0) {
              inHangar = true;
            } else {
              inHangar = false;
            }
            if (snapshot.data!.ias >= widget.gearLimit &&
                snapshot.data!.gear > 0) {
              flashGear = true;
            } else {
              flashGear = false;
            }
            if (snapshot.data!.ias >= widget.flapLimit &&
                snapshot.data!.flaps! > 0) {
              print(widget.flapLimit);
              flashFlap = true;
            } else {
              flashFlap = false;
            }
            if (snapshot.data!.load >= widget.gLoad) {
              // print(snapshot.data!.load);

              flashLoad = true;
            } else {
              flashLoad = false;
            }
            if (inHangar) show = false;
            return show
                ? Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 0150,
                        ),
                        Center(
                          child: Flex(
                            direction: Axis.horizontal,
                            children: [
                              Expanded(flex: 1, child: SizedBox()),
                              Expanded(
                                  flex: 3,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            'IAS ',
                                            style: TextStyle(
                                                fontSize: widget.fontSize),
                                          ),
                                          Text(
                                            '${snapshot.data!.ias} Km/h',
                                            style: TextStyle(
                                                fontSize: widget.fontSize),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            'Altitude',
                                            style: TextStyle(
                                                fontSize: widget.fontSize),
                                          ),
                                          Text(
                                            ' ${snapshot.data!.altitude} m',
                                            style: TextStyle(
                                                fontSize: widget.fontSize),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            'Flap',
                                            style: TextStyle(
                                                fontSize: widget.fontSize),
                                          ),
                                          !flashFlap
                                              ? Text(
                                                  '${snapshot.data!.flaps} %',
                                                  style: TextStyle(
                                                      fontSize:
                                                          widget.fontSize),
                                                )
                                              : BlinkText(
                                                  '${snapshot.data!.flaps} %',
                                                  endColor: Colors.red,
                                                  style: TextStyle(
                                                      fontSize:
                                                          widget.fontSize),
                                                ),
                                        ],
                                      ),
                                    ],
                                  )),
                              Expanded(flex: 1, child: SizedBox()),
                              Expanded(
                                  flex: 3,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            'Gear',
                                            style: TextStyle(
                                                fontSize: widget.fontSize),
                                          ),
                                          !flashGear
                                              ? Text(
                                                  '${snapshot.data!.gear} %',
                                                  style: TextStyle(
                                                      fontSize:
                                                          widget.fontSize),
                                                )
                                              : BlinkText(
                                                  '${snapshot.data!.gear} %',
                                                  endColor: Colors.red,
                                                  style: TextStyle(
                                                      fontSize:
                                                          widget.fontSize),
                                                ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            'Climb ',
                                            style: TextStyle(
                                                fontSize: widget.fontSize),
                                          ),
                                          Text(
                                            '${snapshot.data!.climb} m/s',
                                            style: TextStyle(
                                                fontSize: widget.fontSize),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            'GLoad ',
                                            style: TextStyle(
                                                fontSize: widget.fontSize),
                                          ),
                                          !flashLoad
                                              ? Text(
                                                  '${snapshot.data!.load} G',
                                                  style: TextStyle(
                                                      fontSize:
                                                          widget.fontSize),
                                                )
                                              : BlinkText(
                                                  '${snapshot.data!.load} G',
                                                  endColor: Colors.red,
                                                  style: TextStyle(
                                                      fontSize:
                                                          widget.fontSize),
                                                ),
                                        ],
                                      ),
                                    ],
                                  )),
                              Expanded(flex: 1, child: SizedBox()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container();
          }
          if (snapshot.hasError && show) {
            return Text('ERROR: INVALID DATA');
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
