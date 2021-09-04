import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:blinking_text/blinking_text.dart';
import 'package:desktoasts/desktoasts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:libwinmedia/libwinmedia.dart';
import 'package:path/path.dart' as p;
import 'package:system_tray/system_tray.dart';
import 'package:url_launcher/url_launcher.dart';

import 'damage_event.dart';
import 'indicatorReceiver.dart';
import 'main.dart';
import 'stateReceiver.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  setupToolData() async {
    ToolDataState stateData = await ToolDataState.getState();
    ToolDataIndicator indicatorData = await ToolDataIndicator.getIndicator();
    List<Damage> dataForId = await Damage.getDamage();
    List<Damage> dataForMsg = await Damage.getDamage();

    Navigator.pushReplacementNamed(context, '/home',
        arguments: {stateData, indicatorData, dataForMsg, dataForId});
  }

  // hostChecker() async {
  //   if (!await canLaunch('http://localhost:8111/state')) {
  //     ScaffoldMessenger.of(context)
  //       ..removeCurrentSnackBar()
  //       ..showSnackBar(SnackBar(
  //         content: BlinkText(
  //           'Unable to connect to game server.',
  //           endColor: Colors.red,
  //         ),
  //         duration: Duration(seconds: 10),
  //       ));
  //   }
  // }

  @override
  void initState() {
    setupToolData();

    super.initState();
  }

  void _launchURL() async => await launch(_url);
  var _url =
      'https://forum.warthunder.com/index.php?/topic/533554-war-thunder-background-assistant-wtbga';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red,
        title: Text(
          'Loading WTbgI',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.cyanAccent),
        ),
      ),
      body: Center(
        child: SpinKitChasingDots(
          color: Colors.redAccent,
          size: 80.0,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setupToolData();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("If you didn't go to the next screen, click on More Info"),
            action: SnackBarAction(
              label: 'More Info',
              onPressed: () async {
                _launchURL();
              },
            ),
            duration: Duration(seconds: 5),
          ));
        },
        backgroundColor: Colors.red,
        child: Icon(Icons.refresh),
      ),
    );
  }
}

//Home

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // static Route<String> dialogBuilder(BuildContext context) {
  //   TextEditingController userInputController = TextEditingController();
  //   // print(userInputController.text);
  //   return DialogRoute(
  //     context: context,
  //     builder: (BuildContext context) => AlertDialog(
  //       actions: [
  //         ElevatedButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: Text('Cancel')),
  //         ElevatedButton(
  //             onPressed: () {
  //               ScaffoldMessenger.of(context)
  //                 ..removeCurrentSnackBar()
  //                 ..showSnackBar(SnackBar(
  //                     content: Text(
  //                         'You will after ${userInputController.text} seconds. ')));
  //               Navigator.of(context).pop(userInputController.text);
  //             },
  //             child: Text('Start')),
  //       ],
  //       title: Text('Timer'),
  //       content: TextField(
  //         // onSubmitted: onSubmit,
  //         onChanged: (value) {},
  //         controller: userInputController,
  //         decoration: InputDecoration(hintText: "Enter the time in seconds"),
  //       ),
  //     ),
  //   );
  // }
  var player = Player(id: 0);

  // void handleTimeout() {}
  Future<void> overheatCheck() async {
    await Damage.getDamage();
    if (isOilNotifOn &&
        stateData.oil != 15 &&
        isFullNotifOn &&
        isDamageIDNew &&
        msgData == "Oil overheated") {
      Toast toast = new Toast(
          type: ToastType.imageAndText02,
          title: '😳OIL WARNING!',
          subtitle: 'Oil is overheating!',
          image: new File('C:/src/wtbginfonfo/assets/WARNING.png'));
      service!.show(toast);
      toast.dispose();

      isDamageIDNew = false;
      player.play();
    }
    if (isEngineNotifOn &&
        stateData.oil != 15 &&
        isFullNotifOn &&
        isDamageIDNew &&
        msgData == 'Engine overheated') {
      Toast toast = new Toast(
          type: ToastType.imageAndText02,
          title: '😳ENGINE WARNING!',
          subtitle: 'Engine is overheating!',
          image: new File('C:/src/wtbginfonfo/assets/WARNING.png'));
      service!.show(toast);
      toast.dispose();

      isDamageIDNew = false;
      player.play();
    }
    if (isWaterNotifOn &&
        stateData.water != 15 &&
        isFullNotifOn &&
        isDamageIDNew &&
        msgData == 'Engine overheated') {
      Toast toast = new Toast(
          actions: [
            'Accept',
            'Decline',
          ],
          type: ToastType.imageAndText02,
          title: '😳ENGINE WARNING!',
          subtitle: 'Engine is overheating!',
          image: new File('C:/src/wtbginfonfo/assets/WARNING.png'));
      service!.show(toast);
      toast.dispose();
      isDamageIDNew = false;
      player.play();
    }
    if (isEngineDeathNotifOn &&
        stateData.oil != 15 &&
        isFullNotifOn &&
        isDamageIDNew &&
        msgData == "Engine died: overheating") {
      Toast toast = Toast(
          type: ToastType.imageAndText02,
          title: '😳ENGINE WARNING!',
          subtitle: 'Engine died!! ',
          image: File('C:/src/wtbginfonfo/assets/WARNING.png'));
      service!.show(toast);
      toast.dispose();

      isDamageIDNew = false;
      player.play();
    }
    if (isEngineDeathNotifOn &&
        stateData.oil != 15 &&
        isFullNotifOn &&
        isDamageIDNew &&
        msgData == "Engine died: propeller broken") {
      Toast toast = Toast(
          type: ToastType.imageAndText02,
          title: '😳ENGINE WARNING!',
          subtitle: 'Engine died!! ',
          image: File('C:/src/wtbginfonfo/assets/WARNING.png'));
      service!.show(toast);
      toast.dispose();

      isDamageIDNew = false;
      player.play();
    }
    if (stateData.oil != 15 &&
        isFullNotifOn &&
        isDamageIDNew &&
        msgData == 'You are out of ammunition. Reloading is not possible.') {
      Toast toast = new Toast(
          type: ToastType.imageAndText02,
          title: '😳WARNING!!',
          subtitle: 'Your vehicle is possibly destroyed / Not repairable😒',
          image: new File('C:/src/wtbginfonfo/assets/WARNING.png'));
      service!.show(toast);
      toast.dispose();

      isDamageIDNew = false;
      player.play();
    }

    run = true;
  }

  int? emptyInt = 0;
  String? emptyString = ' No message';

  ValueNotifier<int?> idData = ValueNotifier<int?>(null);

  Future<void> updateStateIndicator() async {
    ToolDataState dataForState = await ToolDataState.getState();
    ToolDataIndicator dataForIndicator = await ToolDataIndicator.getIndicator();

    if (!mounted) return;
    setState(() {
      stateData = dataForState;
      indicatorData = dataForIndicator;
    });
  }

  Future<void> updateMsgId() async {
    List<Damage> dataForId = await Damage.getDamage();
    List<Damage> dataForMsg = await Damage.getDamage();
    if (!mounted) return;
    setState(() {
      idData.value =
          dataForId.isNotEmpty ? dataForId[dataForId.length - 1].id : emptyInt;
      msgData = dataForMsg.isNotEmpty
          ? dataForMsg[dataForMsg.length - 1].msg
          : emptyString;
    });
  }

  int? firstSpeed;
  int? secondSpeed;
  int counter = 0;
  void highAcceleration() {
    if ((secondSpeed! - firstSpeed!) / 2 >= 10) {
      while (counter < 2) {
        Toast toast = new Toast(
            type: ToastType.imageAndText02,
            title: '😳WARNING!!',
            subtitle: 'Very high acceleration, be careful',
            image: new File('C:/src/wtbginfonfo/assets/WARNING.png'));
        service!.show(toast);
        toast.dispose();
        isDamageIDNew = false;
        player.play();
        counter++;
      }
    }
    if (counter == 1) {
      Future.delayed(const Duration(seconds: 6), () {
        setState(() {
          counter = 0;
        });
      });
    }
  }

  Future<void> averageTAS() async {
    if (stateData.tas != null &&
        stateData.tas != 0 &&
        stateData.tas >= 450 &&
        stateData.flap > 0) {
      setState(() {
        firstSpeed = stateData.tas;
      });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          secondSpeed = stateData.tas;
        });
      });
      Future.delayed(
          const Duration(milliseconds: 2500), () => highAcceleration());
    }
  }

  final SystemTray _systemTray = SystemTray();
  Timer? _timer;
  bool _toggleTrayIcon = true;

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    idData.removeListener((overheatCheck));
  }

  Future<void> initSystemTray() async {
    String? path;
    if (Platform.isWindows) {
      path = p.joinAll([
        p.dirname(Platform.resolvedExecutable),
        'data/flutter_assets/assets',
        'logoWTbgA.jpg'
      ]);
    } else if (Platform.isMacOS) {
      path = p.joinAll(['AppIcon']);
    }

    // We first init the systray menu and then add the menu entries
    await _systemTray.initSystemTray('Tray', toolTip: 'Help', iconPath: path);

    await _systemTray.setContextMenu(
      [
        MenuItem(
          label: 'Show',
          onClicked: () {
            appWindow.show();
          },
        ),
        MenuSeparator(),
        SubMenu(
          label: "SubMenu",
          children: [
            MenuItem(
              label: 'SubItem1',
              enabled: false,
              onClicked: () {
                print("click SubItem1");
              },
            ),
            MenuItem(label: 'SubItem2'),
            MenuItem(label: 'SubItem3'),
          ],
        ),
        MenuSeparator(),
        MenuItem(
          label: 'Exit',
          onClicked: () {
            appWindow.close();
          },
        ),
      ],
    );

    // flash tray icon
    _timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) {
        _toggleTrayIcon = !_toggleTrayIcon;
        _systemTray.setSystemTrayInfo(
          iconPath: _toggleTrayIcon ? "" : path,
        );
      },
    );

    // handle system tray event
    _systemTray.registerSystemTrayEventHandler((eventName) {
      print("eventName: $eventName");
    });
  }

  hostChecker() async {
    if (await canLaunch('http://localhost:8111')) {
    } else {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: BlinkText(
            'Unable to connect to game server.',
            endColor: Colors.red,
          ),
          duration: Duration(seconds: 10),
        ));
    }
  }

  @override
  void initState() {
    initSystemTray();
    updateMsgId();
    updateStateIndicator();
    super.initState();
    const twoSec = Duration(milliseconds: 2000);
    Timer.periodic(twoSec, (Timer t) => updateMsgId());
    const oneSec = Duration(milliseconds: 200);
    Timer.periodic(oneSec, (Timer t) => updateStateIndicator());
    const averageTimer = Duration(milliseconds: 4000);
    Timer.periodic(averageTimer, (Timer t) {
      averageTAS();
      hostChecker();
    });

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      stateData = ModalRoute.of(context)?.settings.arguments as ToolDataState;
      indicatorData =
          ModalRoute.of(context)?.settings.arguments as ToolDataIndicator;
    });
    idData.addListener(() {
      setState(() {
        isDamageIDNew = true;
      });
      overheatCheck();
      run = false;
    });
    Future.delayed(Duration(milliseconds: 250), () {
      widget1Opacity = 1;
    });
  }

  // Future<void> oilNotify() async {
  //   await ToolDataState.getData();
  //   if (int.parse(data.oil) >= int.parse(text1.value) &&
  //       text1.value != '-20' &&
  //       data.oil != 'null' &&
  //       run) {
  //     Toast toast = new Toast(
  //         type: ToastType.imageAndText02,
  //         title: 'Warning!',
  //         subtitle: 'Oil temperature reached red line level!',
  //         image: new File('C:/src/untitled112/assets/Engine.jpg'));
  //     service?.show(toast);
  //     setState(() {
  //       run = false;
  //     });
  //   }
  //   if (int.parse(data.oil) < int.parse(text1.value)) {
  //     setState(() {
  //       run = true;
  //     });
  //   }
  // }

// dialogBuilderBuilder() =>
// void Function(String text) onSubmit
  fuelIndicator() {
    if (stateData.minFuel != null) {
      fuelPercent = (stateData.minFuel / stateData.maxFuel) * 100;
    }
    return Flexible(
        child: Container(
            height: 60,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(10, 123, 10, 0.403921568627451),
                    Color.fromRGBO(0, 50, 158, 0.4196078431372549),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(20.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.2),
                    spreadRadius: 4,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  )
                ]),
            child: stateData.minFuel != null && fuelPercent! >= 25.00
                ? TextButton.icon(
                    icon: Icon(Icons.speed),
                    onPressed: () {},
                    label: Expanded(
                      child: Text(
                        'Remaining Fuel = ${fuelPercent!.toStringAsFixed(0)}%',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            letterSpacing: 2,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : stateData.minFuel != null &&
                        fuelPercent! < 25.00 &&
                        (stateData.height != 32 &&
                            stateData.minFuel != 0 &&
                            stateData.flap != 0)
                    ? TextButton.icon(
                        icon: Icon(Icons.speed),
                        onPressed: () {},
                        label: Expanded(
                          child: BlinkText(
                            'Remaining Fuel = ${fuelPercent!.toStringAsFixed(0)}%',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                letterSpacing: 2,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            endColor: Colors.red,
                          ),
                        ),
                      )
                    : TextButton.icon(
                        icon: Icon(Icons.speed),
                        onPressed: () {},
                        label: Expanded(
                          child: Text(
                            'No Data ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                letterSpacing: 2,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )));
  }

  iasText() {
    return Flexible(
        child: Container(
            height: 60,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(10, 123, 10, 0.403921568627451),
                    Color.fromRGBO(0, 50, 158, 0.4196078431372549),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(20.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.2),
                    spreadRadius: 4,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  )
                ]),
            child: stateData.ias == null || stateData.ias == 0
                ? TextButton.icon(
                    icon: Icon(Icons.speed),
                    onPressed: () {},
                    label: Expanded(
                      child: Text(
                        'Stationary / No data!  ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            letterSpacing: 2,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : indicatorData.mach != null && indicatorData.mach >= 1
                    ? TextButton.icon(
                        icon: Icon(Icons.speed),
                        onPressed: () {},
                        label: Expanded(
                          child: Text(
                            'IAS = ${stateData.ias!} km/h (Above Mach) ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                letterSpacing: 2,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    : TextButton.icon(
                        icon: Icon(Icons.speed),
                        onPressed: () {},
                        label: Expanded(
                          child: Text(
                            'IAS = ${stateData.ias!} km/h ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                letterSpacing: 2,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )));
  }

  engineTempText() {
    return ValueListenableBuilder(
        valueListenable: idData,
        builder: (BuildContext context, value, Widget? child) {
          return Flexible(
              child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(10, 123, 10, 0.403921568627451),
                          Color.fromRGBO(0, 50, 158, 0.4196078431372549),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.2),
                          spreadRadius: 4,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        )
                      ]),
                  child: TextButton.icon(
                    icon: Icon(Icons.airplanemode_active),
                    label: Expanded(
                        child: isFullNotifOn &&
                                msgData == 'Engine overheated' &&
                                run &&
                                indicatorData.engine != 'nul' &&
                                indicatorData.engine != null
                            ? BlinkText(
                                'Engine Temp= ${(indicatorData!.engine.toStringAsFixed(0))} degrees  ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20,
                                    letterSpacing: 2,
                                    color: Colors.black,
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
                                        fontSize: 20,
                                        letterSpacing: 2,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold))
                                : Text('No data  ',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        letterSpacing: 2,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold))),
                    onPressed: () {
                      isEngineDeathNotifOn = !isEngineDeathNotifOn;
                      isEngineNotifOn = !isEngineNotifOn;
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                            content: isEngineDeathNotifOn && isEngineNotifOn
                                ? Text('Engine Notifications are now enabled')
                                : Text(
                                    'Engine Notifications are now disabled')));
                    },
                  )));
        });
  }

  engineThrottleText() {
    return ValueListenableBuilder(
      valueListenable: idData,
      builder: (BuildContext context, value, Widget? child) {
        return Flexible(
            child: Container(
                height: 60,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(10, 123, 10, 0.403921568627451),
                        Color.fromRGBO(0, 50, 158, 0.4196078431372549),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.2),
                        spreadRadius: 4,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      )
                    ]),
                child: TextButton.icon(
                  icon: Icon(Icons.airplanemode_active),
                  label: Expanded(
                      child: indicatorData.throttle != 'null' &&
                              indicatorData.throttle != 'nul'
                          ? Text(
                              'Throttle= ${(double.parse(indicatorData.throttle) * 100).toStringAsFixed(0)}%  ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  letterSpacing: 2,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold))
                          : Text('No data  ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  letterSpacing: 2,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold))),
                  onPressed: () {},
                )));
      },
    );
  }

  oilTempText() {
    return ValueListenableBuilder(
      valueListenable: idData,
      builder: (BuildContext context, value, Widget? child) {
        return Flexible(
            child: Container(
                height: 60,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(10, 123, 10, 0.403921568627451),
                        Color.fromRGBO(0, 50, 158, 0.4196078431372549),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.2),
                        spreadRadius: 4,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      )
                    ]),
                child: TextButton.icon(
                  icon: Icon(Icons.airplanemode_active),
                  label: Expanded(
                      child: (stateData.oil != null && stateData.oil != 15) &&
                              isFullNotifOn &&
                              msgData == "Oil overheated" &&
                              run
                          ? BlinkText(
                              'Oil Temp= ${stateData.oil} degrees  ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  letterSpacing: 2,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              endColor: Colors.red,
                              times: 13,
                              duration: Duration(milliseconds: 200),
                            )
                          : stateData.oil != null && stateData.oil != 15
                              ? Text('Oil Temp= ${stateData.oil} degrees  ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      letterSpacing: 2,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold))
                              : Text('No data  ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      letterSpacing: 2,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold))),
                  onPressed: () {
                    setState(() {
                      isOilNotifOn = !isOilNotifOn;
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                            content: isOilNotifOn
                                ? Text('Oil Notifications are now enabled')
                                : Text('Oil Notifications are now disabled')));
                    });
                  },
                )));
      },
    );
  }

  final buttonColors = WindowButtonColors(
      iconNormal: const Color(0xFF805306),
      mouseOver: const Color(0xFFF6A00C),
      mouseDown: const Color(0xFF805306),
      iconMouseOver: const Color(0xFF805306),
      iconMouseDown: const Color(0xFFFFD500));
  late dynamic stateData;
  late dynamic indicatorData;
  late dynamic msgData;
  double? fuelPercent;
  bool isFullNotifOn = true;
  bool isDamageIDNew = false;
  bool run = true;
  bool isEngineNotifOn = true;
  bool isOilNotifOn = true;
  bool isEngineDeathNotifOn = true;
  bool isWaterNotifOn = true;
  double widget1Opacity = 0.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(fit: StackFit.expand, children: <Widget>[
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
          child: Image.asset(
            "assets/event_korean_war.jpg",
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
        ),
        Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                  leading: MinimizeWindowButton(
                    colors: buttonColors,
                    onPressed: () {
                      appWindow.hide();
                    },
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Go to information page',
                      icon: Icon(
                        Icons.info,
                        color: Colors.cyanAccent,
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/info');
                      },
                    ),
                    // IconButton(
                    //     onPressed: () async {
                    //       String? text = await Navigator.of(context)
                    //           .push(dialogBuilder(context));
                    //       print(text);
                    //       setState(() {
                    //         late String? text1 = text;
                    //       });
                    //     },
                    //     icon: Icon(Icons.access_time))
                  ],
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  title: indicatorData.name != 'NULL'
                      ? Text("You're flying ${indicatorData.name}")
                      : (stateData.height == 32 &&
                              stateData.minFuel == 0 &&
                              stateData.flap == 0)
                          ? Text("You're in Hangar...")
                          : Text('No vehicle data available / Not flying.')),
              body: AnimatedOpacity(
                duration: Duration(seconds: 5),
                opacity: widget1Opacity,
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromRGBO(
                                      10, 123, 10, 0.403921568627451),
                                  Color.fromRGBO(
                                      0, 50, 158, 0.4196078431372549),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(20.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.pink.withOpacity(0.2),
                                  spreadRadius: 4,
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                )
                              ]),
                          child: TextButton.icon(
                            icon: Icon(Icons.height),
                            onPressed: () {},
                            label: stateData.height != null
                                ? Expanded(
                                    child: Text(
                                      'Altitude: ${stateData.height} meters ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20,
                                          letterSpacing: 2,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : Expanded(
                                    child: Text(
                                      'No data available ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20,
                                          letterSpacing: 2,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                          )),
                    ),
                    engineThrottleText(),
                    fuelIndicator(),
                    iasText(),
                    Flexible(
                      child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromRGBO(
                                      10, 123, 10, 0.403921568627451),
                                  Color.fromRGBO(
                                      0, 50, 158, 0.4196078431372549),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(20.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.pink.withOpacity(0.2),
                                  spreadRadius: 4,
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                )
                              ]),
                          child: indicatorData.compass == '0' ||
                                  indicatorData.compass == null
                              ? TextButton.icon(
                                  icon: Icon(Icons.gps_fixed),
                                  onPressed: () {},
                                  label: Expanded(
                                    child: Text(
                                      'No data  ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20,
                                          letterSpacing: 2,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              : TextButton.icon(
                                  icon: Icon(Icons.gps_fixed),
                                  onPressed: () {},
                                  label: Expanded(
                                    child: Text(
                                      'Compass = ${indicatorData.compass?.toStringAsFixed(0)} degrees ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20,
                                          letterSpacing: 2,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )),
                    ),
                    engineTempText(),
                    oilTempText(),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromRGBO(
                                      10, 123, 10, 0.403921568627451),
                                  Color.fromRGBO(
                                      0, 50, 158, 0.4196078431372549),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(20.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.pink.withOpacity(0.2),
                                  spreadRadius: 4,
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                )
                              ]),
                          child:
                              stateData.water == null || stateData.water == 15
                                  ? TextButton.icon(
                                      icon: Icon(Icons.water),
                                      onPressed: () {
                                        isWaterNotifOn = !isWaterNotifOn;
                                        ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(SnackBar(
                                              content: isWaterNotifOn
                                                  ? Text(
                                                      'Water Notifications are now enabled')
                                                  : Text(
                                                      'Water Notifications are now disabled')));
                                      },
                                      label: Expanded(
                                        child: Text(
                                          'Not water-cooled / No data available!  ',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 20,
                                              letterSpacing: 2,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  : TextButton.icon(
                                      icon: Icon(Icons.water),
                                      onPressed: () {
                                        isWaterNotifOn = !isWaterNotifOn;
                                        ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(SnackBar(
                                              content: isWaterNotifOn
                                                  ? Text(
                                                      'Water Notifications are now enabled')
                                                  : Text(
                                                      'Water Notifications are now disabled')));
                                      },
                                      label: Expanded(
                                        child: Text(
                                          'Water Temp = ${stateData.water!} degrees  ',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 20,
                                              letterSpacing: 2,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )),
                    )
                  ],
                ),
              ),
              floatingActionButton: MediaQuery.of(context).size.height >= 450 &&
                      MediaQuery.of(context).size.width >= 450
                  ? FloatingActionButton(
                      backgroundColor: Colors.red,
                      tooltip: isFullNotifOn
                          ? 'Toggle overheat notifier(On)'
                          : 'Toggle overheat notifier(Off)',
                      child: isFullNotifOn
                          ? Icon(
                              Icons.notifications,
                              color: Colors.green[400],
                            )
                          : Icon(
                              Icons.notifications_off,
                              color: Colors.black,
                            ),
                      onPressed: () {
                        setState(() {
                          isFullNotifOn = !isFullNotifOn;
                        });
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(SnackBar(
                              content: isFullNotifOn
                                  ? Text(
                                      'Notifications are now enabled',
                                      style: TextStyle(color: Colors.green),
                                    )
                                  : Text(
                                      'Notifications are now disabled',
                                      style: TextStyle(color: Colors.red),
                                    )));
                      })
                  : null,
            ),
          ],
        ),
      ]),
    );
  }
}
