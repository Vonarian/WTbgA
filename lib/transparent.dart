import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:wtbgassistant/state_receiver.dart';

import 'damage_event.dart';
import 'home.dart';
import 'indicator_receiver.dart';

class TransparentPage extends StatefulWidget {
  @override
  _TransparentPageState createState() => _TransparentPageState();
}

class _TransparentPageState extends State<TransparentPage> {
  AcrylicEffect effect = AcrylicEffect.transparent;
  Color color = Platform.isWindows ? Color(0x00222222) : Colors.transparent;
  // keyRegister() async {
  //
  // }

  Future<void> updateData() async {
    ToolDataState stateDataInitial = await ToolDataState.getState();
    ToolDataIndicator indicatorDataInitial =
        await ToolDataIndicator.getIndicator();
    if (!mounted) return;
    setState(() {
      stateData = stateDataInitial;
      indicatorData = indicatorDataInitial;
    });
  }

  int? emptyInt = 0;
  String? emptyString = ' No message';
  Future<void> updateMsgId() async {
    List<Damage> dataForId = await Damage.getDamage();
    List<Damage> dataForMsg = await Damage.getDamage();
    if (!mounted) return;
    setState(() {
      idData.value = (dataForId.isNotEmpty
          ? dataForId[dataForId.length - 1].id
          : emptyInt)!;
      msgData = dataForMsg.isNotEmpty
          ? dataForMsg[dataForMsg.length - 1].msg
          : emptyString;
    });
  }

  iasText() {
    return Flexible(
        child: Container(
      child: stateData.ias != null && stateData.ias != 0
          ? Text(
              'IAS = ${stateData.ias}km/h',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17,
                  letterSpacing: 2,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold),
            )
          : Text(
              'No Data for IAS',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17,
                  letterSpacing: 2,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold),
            ),
    ));
  }

  oilTempText() {
    return ValueListenableBuilder(
      valueListenable: idData,
      builder: (BuildContext context, value, Widget? child) {
        return Container(
          child: (stateData.oil != null && stateData.oil != 15) &&
                  msgData == "Oil overheated"
              ? BlinkText(
                  'Oil Temp= ${stateData.oil} degrees  ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 17,
                      letterSpacing: 2,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                  endColor: Colors.red,
                  times: 13,
                  duration: Duration(milliseconds: 200),
                )
              : stateData.oil != null && stateData.oil != 15
                  ? Text('Oil Temp= ${stateData.oil} degrees  ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 2,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold))
                  : Text('No data.  ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 2,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  fuelIndicator() {
    if (stateData.minFuel != null) {
      fuelPercent = (stateData.minFuel / stateData.maxFuel) * 100;
    }
    return Container(
      color: Colors.transparent,
      child: stateData.minFuel != null && fuelPercent! >= 15.00
          ? Text(
              'Remaining Fuel = ${fuelPercent!.toStringAsFixed(0)}%',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17,
                  letterSpacing: 2,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold),
            )
          : stateData.minFuel != null &&
                  fuelPercent! < 15.00 &&
                  (stateData.height != 32 && stateData.minFuel != 0)
              ? BlinkText(
                  'Remaining Fuel = ${fuelPercent!.toStringAsFixed(0)}%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 17,
                      letterSpacing: 2,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                  endColor: Colors.red,
                )
              : Text(
                  'No Data',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 17,
                      letterSpacing: 2,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                ),
    );
  }

  engineTempText() {
    return ValueListenableBuilder(
        valueListenable: idData,
        builder: (BuildContext context, value, Widget? child) {
          return Container(
              child: msgData == 'Engine overheated' &&
                      indicatorData.engine != 'nul' &&
                      indicatorData.engine != null
                  ? BlinkText(
                      'Engine Temp= ${(indicatorData!.engine.toStringAsFixed(0))} degrees  ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 2,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                      endColor: Colors.red,
                      times: 13,
                      duration: Duration(milliseconds: 300),
                    )
                  : indicatorData.engine != null
                      ? Text(
                          'Engine Temp= ${(indicatorData.engine.toStringAsFixed(0))} degrees  ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 17,
                              letterSpacing: 2,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold))
                      : Text('No data.  ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 17,
                              letterSpacing: 2,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold)));
        });
  }

  keyRegister() async {
    HotKeyManager.instance.register(
      HotKey(
        KeyCode.digit5,
        modifiers: [KeyModifier.alt],
      ),
      keyDownHandler: (_) async {
        bool isVisible = await windowManager.isVisible();
        if (isVisible) {
          windowManager.hide();
        } else {
          windowManager.show();
        }
      },
    );
    HotKeyManager.instance.register(
        HotKey(
          KeyCode.delete,
          modifiers: [KeyModifier.alt],
        ), keyDownHandler: (_) {
      windowManager.terminate();
    });
    bool isAlwaysOnTop = await windowManager.isAlwaysOnTop();

    HotKeyManager.instance.register(
      HotKey(
        KeyCode.digit2,
        modifiers: [KeyModifier.alt],
      ),
      keyDownHandler: (_) async {
        windowManager.setAlwaysOnTop(!isAlwaysOnTop);
        Future.delayed(Duration(milliseconds: 200));
        isAlwaysOnTop = await windowManager.isAlwaysOnTop();
        windowManager.setCustomFrame(isFrameless: true);
        print(isAlwaysOnTop);
      },
    );
    HotKeyManager.instance.register(
        HotKey(
          KeyCode.digit1,
          modifiers: [KeyModifier.alt],
        ), keyDownHandler: (_) {
      if (mounted) {
        Navigator.pushNamed(context, '/home');
      }
    });
  }

  @override
  void initState() {
    updateData();
    updateMsgId();
    keyRegister();

    doWhenWindowReady(() async {
      final win = appWindow;
      win.alignment = Alignment.center;
      win.title = "WTbgA";
      win.show();
      bool isAlwaysOnTop = await windowManager.isAlwaysOnTop();
      windowManager.setAlwaysOnTop(isAlwaysOnTop);
    });
    const _timer = Duration(milliseconds: 2000);
    Timer.periodic(_timer, (Timer t) {
      updateData();
      updateMsgId();
    });
    super.initState();
    this.setWindowEffect(this.effect);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      stateData = ModalRoute.of(context)?.settings.arguments;
      indicatorData = ModalRoute.of(context)?.settings.arguments;
    });
  }

  void setWindowEffect(AcrylicEffect? value) {
    Acrylic.setEffect(effect: value!, gradientColor: this.color);
    this.setState(() => this.effect = value);
  }

  dynamic stateData;
  dynamic indicatorData;
  ValueNotifier<int> idData = ValueNotifier(-1);
  String? msgData;
  double? fuelPercent;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        iasText(),
                        fuelIndicator(),
                        engineTempText(),
                      ],
                    ),
                  )
                ],
              )),
          // Platform.isWindows
          //     ? WindowTitleBarBox(
          //         child: MoveWindow(
          //           child: Container(
          //             width: MediaQuery.of(context).size.width,
          //             height: 56.0,
          //             child: Row(
          //               mainAxisAlignment: MainAxisAlignment.end,
          //               children: [
          //                 MinimizeWindowButton(
          //                   colors: WindowButtonColors(
          //                       iconNormal: Colors.white,
          //                       mouseOver: Colors.white.withOpacity(0.1),
          //                       mouseDown: Colors.white.withOpacity(0.2),
          //                       iconMouseOver: Colors.white,
          //                       iconMouseDown: Colors.white),
          //                 ),
          //                 MaximizeWindowButton(
          //                   colors: WindowButtonColors(
          //                       iconNormal: Colors.white,
          //                       mouseOver: Colors.white.withOpacity(0.1),
          //                       mouseDown: Colors.white.withOpacity(0.2),
          //                       iconMouseOver: Colors.white,
          //                       iconMouseDown: Colors.white),
          //                 ),
          //                 CloseWindowButton(
          //                   colors: WindowButtonColors(
          //                       mouseOver: Color(0xFFD32F2F),
          //                       mouseDown: Color(0xFFB71C1C),
          //                       iconNormal: Colors.white,
          //                       iconMouseOver: Colors.white),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       )
          //     : Container(),
        ],
      ),
    );
  }
}
