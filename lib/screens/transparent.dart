import 'dart:async';
import 'dart:io';

import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:path/path.dart' as p;
import 'package:wtbgassistant/data_receivers/state_receiver.dart';

import '../main.dart';

class TransparentPage extends StatefulWidget {
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
        keyDownHandler: (_) async {
      try {
        await Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        print(e);
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
          child: FutureBuilder<ToolDataState>(
        future: ToolDataState.getState(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text('IAS '),
                                  Text('${snapshot.data!.ias} Km/h'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text('Altitude'),
                                  Text(' ${snapshot.data!.height} m'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text('Flap'),
                                  Text('${snapshot.data!.flap} %'),
                                ],
                              ),
                            ],
                          )),
                      Expanded(flex: 1, child: SizedBox()),
                      Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    'Gear',
                                  ),
                                  Text('${snapshot.data!.gear} %'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text('Climb '),
                                  Text('${snapshot.data!.climb} m/s'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text('GLoad '),
                                  Text('${snapshot.data!.load} G'),
                                ],
                              ),
                            ],
                          )),
                      Expanded(flex: 1, child: SizedBox()),
                    ],
                  ),
                ),
              ],
            );
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            return CircularProgressIndicator(
              color: Colors.purple,
            );
          }
        },
      )),
    );
  }
}
