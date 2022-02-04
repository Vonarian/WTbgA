import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:path/path.dart' as p;
import 'package:wtbgassistant/data_receivers/indicator_receiver.dart';
import 'package:wtbgassistant/data_receivers/state_receiver.dart';
import 'package:wtbgassistant/services/csv_class.dart';

import '../main.dart';

class TransparentPage extends ConsumerStatefulWidget {
  final double fontSize;
  const TransparentPage({Key? key, required this.fontSize}) : super(key: key);
  @override
  _TransparentPageState createState() => _TransparentPageState();
}

class _TransparentPageState extends ConsumerState<TransparentPage> {
  WindowEffect effect = WindowEffect.transparent;
  Color color =
      Platform.isWindows ? const Color(0x00222222) : Colors.transparent;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (!mounted) return;
      loadChecker();
      flapChecker();
      ToolDataIndicator? toolDataIndicator =
          await ToolDataIndicator.getIndicator();
      if (toolDataIndicator != null) {
        vehicleName = toolDataIndicator.type;
      }
      Map<String, String> namesMap = convertNamesToMap(csvNames);
      if (vehicleName != null) {
        fmData = await FmData.setObject(namesMap[vehicleName] ?? '');
      }
      if (fmData != null) {
        gearLimit = fmData!.critGearSpd;
      }
      setState(() {});
    });
    setWindowEffect(effect);
    setWindow();

    Future.delayed(Duration.zero, () async {
      csvNames = await File(namesPath).readAsString();
      ToolDataIndicator? toolDataIndicator =
          await ToolDataIndicator.getIndicator();
      if (toolDataIndicator != null) {
        vehicleName = toolDataIndicator.type;
      }
      Map<String, String> namesMap = convertNamesToMap(csvNames);
      fmData = await FmData.setObject(namesMap[vehicleName] ?? '');
      setState(() {});
    });
  }

  Map<String, String> convertNamesToMap(String csvStringNames) {
    Map<String, String> map = {};

    for (final rows in LineSplitter.split(csvStringNames)
        .skip(1)
        .map((line) => line.split(';'))) {
      map[rows.first] = rows[1];
    }

    return map;
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
    // await hotKey
    //     .register(HotKey(KeyCode.backspace, modifiers: [KeyModifier.alt]),
    //         keyDownHandler: (_) {
    //   show = !show;
    // });
  }

  Future<void> setWindowEffect(WindowEffect? value) async {
    Window.setEffect(effect: value!, color: color);
    setState(() => effect = value);
  }

  void loadChecker() {
    if (!mounted) return;
    if (fmData != null) {
      maxLoad = (fmData!.critWingOverload2 /
          ((fmData!.emptyMass + fuelMass) * 9.81 / 2));
      if (maxLoad == null) return;
      if ((load) >= (maxLoad! - 0.4)) {
        flashLoad = true;
      } else {
        flashLoad = false;
      }
    }
  }

  void flapChecker() {
    if (fmData != null) {
      // print(flap);
      if (flap != 0 && flap <= (fmData!.flapState1 * 100 - 40)) {
        if (ias >= fmData!.flapDestruction1) {
          flashFlap = true;
        }
      } else if (flap >= fmData!.flapState2 * 100) {
        if (ias >= (fmData!.flapDestruction2 - 40)) {
          flashFlap = true;
        }
      } else {
        flashFlap = false;
      }
    }
  }

  String csvNames = '';

  String path = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets/AutoHotkeyU64.ahk'
  ]);
  String pathAHK = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets/AutoHotkeyU64.exe'
  ]);
  String pathPng = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets/image.png'
  ]);
  String namesPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'fm_names_db.csv'
  ]);
  bool flashGear = false;
  bool flashFlap = false;
  bool flashLoad = false;
  bool inHangar = true;
  double load = 0;
  bool show = true;
  int fuelMass = 500;
  int flap = 0;
  int ias = 0;
  int gearLimit = 1200;
  FmData? fmData;
  String? vehicleName;
  double? maxLoad;
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
            load = snapshot.data!.load;
            ias = snapshot.data!.ias;

            if (snapshot.data!.flaps != null) {
              flap = snapshot.data!.flaps!;
            }
            if (snapshot.data!.ias >= gearLimit && snapshot.data!.gear > 0) {
              flashGear = true;
            } else {
              flashGear = false;
            }
            if (fmData == null) {
              show = false;
            } else {
              show = true;
            }
            if (fmData != null) {
              maxLoad = (fmData!.critWingOverload2 /
                  ((fmData!.emptyMass + fuelMass) * 9.81 / 2));
            }
            if (inHangar) show = false;
            if (!inHangar) show = true;
            return show
                ? Center(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 0150,
                        ),
                        Center(
                          child: Flex(
                            direction: Axis.horizontal,
                            children: [
                              const Expanded(flex: 1, child: SizedBox()),
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
                                                          widget.fontSize + 5),
                                                ),
                                        ],
                                      ),
                                    ],
                                  )),
                              const Expanded(flex: 1, child: SizedBox()),
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
                                                          widget.fontSize + 5),
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
                                                  '${snapshot.data!.load} G (${maxLoad?.toStringAsFixed(1)})',
                                                  style: TextStyle(
                                                      fontSize:
                                                          widget.fontSize),
                                                )
                                              : BlinkText(
                                                  '${snapshot.data!.load} G (${maxLoad?.toStringAsFixed(1)})',
                                                  endColor: Colors.red,
                                                  style: TextStyle(
                                                      fontSize:
                                                          widget.fontSize + 5),
                                                ),
                                        ],
                                      ),
                                    ],
                                  )),
                              const Expanded(flex: 1, child: SizedBox()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container();
          }
          if (snapshot.hasError && show) {
            return const Text('ERROR: INVALID DATA');
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
