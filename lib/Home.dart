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
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:libwinmedia/libwinmedia.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tray_manager/tray_manager.dart';
// import 'package:system_tray/system_tray.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import 'damage_event.dart';
import 'indicatorReceiver.dart';
import 'main.dart';
import 'stateReceiver.dart';

final windowManager = WindowManager.instance;

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
    return Stack(children: [
      ImageFiltered(
          child: Image.asset('assets/event_korean_war.jpg'),
          imageFilter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0)),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
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
              content: Text(
                  "If you didn't go to the next screen, click on More Info"),
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
      ),
    ]);
  }
}

//Home

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WindowListener, TrayListener {
  static Route<String> dialogBuilderIasFlap(BuildContext context) {
    TextEditingController userInputIasFlap = TextEditingController();
    return DialogRoute(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(
                          'You will be notified if IAS reaches red line speed of ${userInputIasFlap.text} km/h (With flaps open). ')));
                Navigator.of(context).pop(userInputIasFlap.text);
              },
              child: Text('Notify')),
        ],
        title: Text('Red line notifier (Enter red line flap speed). '),
        content: TextField(
          // onSubmitted: onSubmit,
          onChanged: (value) {},
          controller: userInputIasFlap,
          decoration: InputDecoration(hintText: "Enter the IAS in km/h"),
        ),
      ),
    );
  }

  static Route<String> dialogBuilderOverG(BuildContext context) {
    TextEditingController userInputOverG = TextEditingController();
    return DialogRoute(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: TextField(
                onChanged: (value) {},
                controller: userInputOverG,
                decoration:
                    InputDecoration(hintText: 'Enter the G load number'),
              ),
              title: Text('Red line notifier (Enter red line G load speed). '),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel')),
                ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                            content: Text(
                                'You will be notified if G load reaches red line load of ${userInputOverG.text}. ')));
                      Navigator.of(context).pop(userInputOverG.text);
                    },
                    child: Text('Notify'))
              ],
            ));
  }

  static Route<String> dialogBuilderIasGear(BuildContext context) {
    TextEditingController userInputIasGear = TextEditingController();
    return DialogRoute(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: TextField(
                onChanged: (value) {},
                controller: userInputIasGear,
                decoration: InputDecoration(hintText: 'Enter the IAS in km/h'),
              ),
              title: Text('Red line notifier (Enter red line gear speed). '),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel')),
                ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                            content: Text(
                                'You will be notified if IAS reaches red line speed of ${userInputIasGear.text} km/h (With gears open). ')));
                      Navigator.of(context).pop(userInputIasGear.text);
                    },
                    child: Text('Notify'))
              ],
            ));
  }

  var player = Player(id: 0);
  var warningLogo = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'WARNING.png'
  ]);
  void userRedLineFlap() {
    if (!mounted) return;
    if (stateData.ias != null && textForIasFlap.value != null) {
      if (stateData.ias >= int.parse(textForIasFlap.value!) &&
          isUserIasFlapNew &&
          stateData.flap > 0) {
        Toast toast = new Toast(
            type: ToastType.imageAndText02,
            title: '😳Flap WARNING!',
            subtitle:
                'Be careful, flaps are open and IAS has reached red line!',
            image: new File(warningLogo));
        service!.show(toast);
        toast.dispose();
        service?.stream.listen((event) {
          if (event is ToastActivated) {
            windowManager.show();
          }
        });
        player.play();
        isUserIasFlapNew = false;
      }
      if (stateData.ias < int.parse(textForIasFlap.value!)) {
        setState(() {
          isUserIasFlapNew = true;
        });
      }
    }
  }

  void userRedLineGear() {
    if (!mounted) return;
    if (stateData.ias != null && textForIasGear.value != null) {
      if (stateData.ias >= int.parse(textForIasGear.value!) &&
          isUserIasGearNew &&
          stateData.gear > 0) {
        Toast toast = new Toast(
            type: ToastType.imageAndText02,
            title: '😳Gear WARNING!',
            subtitle:
                'Be careful, gears are open and IAS has reached red line!',
            image: new File(warningLogo));
        service!.show(toast);
        toast.dispose();
        service?.stream.listen((event) {
          if (event is ToastActivated) {
            windowManager.show();
          }
        });
        gearUpPlayer.play();
        isUserIasGearNew = false;
      }
      if (stateData.ias >= int.parse(textForIasGear.value!) &&
          stateData.gear > 0) {
        gearUpPlayer.play();
      }
      if (stateData.ias < int.parse(textForIasGear.value!)) {
        setState(() {
          isUserIasGearNew = true;
        });
      }
    }
  }

  var pullUpPlayer = Player(id: 3);
  var gearUpPlayer = Player(id: 2);
  var overGPlayer = Player(id: 1);
  Future<void> pullUpChecker() async {
    if (!mounted) return;
    if (indicatorData.vertical != null &&
        (stateData.ias > 400 &&
            stateData.climb != null &&
            stateData.climb < -60 &&
            indicatorData.vertical <= 135 &&
            indicatorData.vertical >= 50) &&
        stateData.height < 2200) {
      pullUpPlayer.play();
    }
  }

  Future<void> loadChecker() async {
    if (!mounted) return;
    if (textForGLoad.value != null &&
        isUserGLoadNew &&
        stateData.load != null &&
        stateData.load >= int.parse(textForGLoad.value!)) {
      overGPlayer.play();
    }
  }

  Future<void> vehicleStateCheck() async {
    await Damage.getDamage();
    if (_isOilNotifOn &&
        stateData.oil != 15 &&
        _isFullNotifOn &&
        isDamageIDNew &&
        msgData == "Engine died: no fuel" &&
        isDamageMsgNew) {
      Toast toast = new Toast(
          type: ToastType.imageAndText02,
          title: '😳Engine WARNING!',
          subtitle: 'Engine ran out of fuel and died!',
          image: new File(warningLogo));
      service!.show(toast);
      toast.dispose();
      service?.stream.listen((event) {
        if (event is ToastActivated) {
          windowManager.show();
        }
      });
      isDamageIDNew = false;
      player.play();
    }
    if (_isOilNotifOn &&
        stateData.oil != 15 &&
        _isFullNotifOn &&
        isDamageIDNew &&
        msgData == "Oil overheated") {
      Toast toast = new Toast(
          type: ToastType.imageAndText02,
          title: '😳OIL WARNING!',
          subtitle: 'Oil is overheating!',
          image: new File(warningLogo));
      service!.show(toast);
      toast.dispose();
      service?.stream.listen((event) {
        if (event is ToastActivated) {
          windowManager.show();
        }
      });
      isDamageIDNew = false;
      player.play();
    }
    if (isEngineNotifOn &&
        stateData.oil != 15 &&
        _isFullNotifOn &&
        isDamageIDNew &&
        msgData == 'Engine overheated') {
      Toast toast = new Toast(
          type: ToastType.imageAndText02,
          title: '😳ENGINE WARNING!',
          subtitle: 'Engine is overheating!',
          image: new File(warningLogo));
      service!.show(toast);
      toast.dispose();
      service?.stream.listen((event) {
        if (event is ToastActivated) {
          windowManager.show();
        }
      });
      isDamageIDNew = false;
      player.play();
    }
    if (_isWaterNotifOn &&
        stateData.water != 15 &&
        _isFullNotifOn &&
        isDamageIDNew &&
        msgData == 'Engine overheated') {
      Toast toast = new Toast(
          type: ToastType.imageAndText02,
          title: '😳ENGINE WARNING!',
          subtitle: 'Engine is overheating!',
          image: new File(warningLogo));
      service!.show(toast);
      service?.stream.listen((event) {
        if (event is ToastActivated) {
          windowManager.show();
        }
      });
      toast.dispose();
      isDamageIDNew = false;
      player.play();
    }
    if (_isEngineDeathNotifOn &&
        stateData.oil != 15 &&
        _isFullNotifOn &&
        isDamageIDNew &&
        msgData == "Engine died: overheating") {
      Toast toast = Toast(
          type: ToastType.imageAndText02,
          title: '😳ENGINE WARNING!',
          subtitle: 'Engine died!! ',
          image: File(warningLogo));
      service!.show(toast);
      toast.dispose();
      service?.stream.listen((event) {
        if (event is ToastActivated) {
          windowManager.show();
        }
      });
      isDamageIDNew = false;
      player.play();
    }
    if (_isEngineDeathNotifOn &&
        stateData.oil != 15 &&
        _isFullNotifOn &&
        isDamageIDNew &&
        msgData == "Engine died: propeller broken") {
      Toast toast = Toast(
          type: ToastType.imageAndText02,
          title: '😳ENGINE WARNING!',
          subtitle: 'Engine died!! ',
          image: File(warningLogo));
      service!.show(toast);
      toast.dispose();
      service?.stream.listen((event) {
        if (event is ToastActivated) {
          windowManager.show();
        }
      });
      isDamageIDNew = false;
      player.play();
    }
    if (stateData.oil != 15 &&
        _isFullNotifOn &&
        isDamageIDNew &&
        msgData == 'You are out of ammunition. Reloading is not possible.') {
      Toast toast = new Toast(
          type: ToastType.imageAndText02,
          title: '😳WARNING!!',
          subtitle: 'Your vehicle is possibly destroyed / Not repairable😒',
          image: new File(warningLogo));
      service!.show(toast);
      toast.dispose();
      service?.stream.listen((event) {
        if (event is ToastActivated) {
          windowManager.show();
        }
      });
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

  // Future<void> updateRam() async {
  //   var ramTotalReceive = MemInfo().mem_total_gb;
  //   var ramUsageReceive = MemInfo().swap_total_gb;
  //   setState(() {
  //     ramUsage = ramUsageReceive;
  //     ramTotal = ramTotalReceive;
  //   });
  // }

  void flapChecker() {
    if (((indicatorData.flap1 != indicatorData.flap2) ||
        msgData == 'Asymmetric flap extension' && isDamageIDNew)) {
      Toast toast = new Toast(
          type: ToastType.imageAndText02,
          title: '😳Flap WARNING!!',
          subtitle: 'Flaps are not opened equally, be careful',
          image: new File(warningLogo));
      service!.show(toast);
      toast.dispose();
      service?.stream.listen((event) {
        if (event is ToastActivated) {
          windowManager.show();
        }
      });
      isDamageIDNew = false;
      player.play();
    }
  }

  void highAcceleration() {
    if (!mounted) return;
    if (secondSpeed != null) {
      return;
    }
    double? avgTAS = ((secondSpeed! - firstSpeed!) / 2);
    if (avgTAS >= 10) {
      while (counter < 2) {
        Toast toast = new Toast(
            type: ToastType.imageAndText02,
            title: '😳WARNING!!',
            subtitle: 'Very high acceleration, be careful',
            image: new File(warningLogo));
        service!.show(toast);
        toast.dispose();
        service?.stream.listen((event) {
          if (event is ToastActivated) {
            windowManager.show();
          }
        });
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

  Future<void> averageTasForStall() async {
    if (!mounted) return;
    if (stateData.tas != null) {
      setState(() {
        firstSpeed = stateData.tas;
      });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          secondSpeed = stateData.tas;
        });
        return avgTAS = ((secondSpeed! - firstSpeed!) / 2);
      });
      Future.delayed(
          const Duration(milliseconds: 2500), () => highAcceleration());
    }
  }

  Future<void> averageTAS() async {
    if (!mounted) return;
    if (stateData.tas != null && stateData.tas >= 450 && stateData.flap > 0) {
      setState(() {
        firstSpeed = stateData.tas;
      });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          secondSpeed = stateData.tas;
        });
        return avgTAS = ((secondSpeed! - firstSpeed!) / 2);
      });
      Future.delayed(
          const Duration(milliseconds: 2500), () => highAcceleration());
    }
  }

  // final SystemTray _systemTray = SystemTray();
  // Timer? _timer;
  // bool _toggleTrayIcon = true;

  @override
  void dispose() {
    super.dispose();
    // _timer?.cancel();
    TrayManager.instance.removeListener(this);
    windowManager.removeListener(this);
    idData.removeListener((vehicleStateCheck));
    textForIasFlap.removeListener((userRedLineFlap));
  }

  void _handleClickMinimize() async {
    windowManager.minimize();
  }

  void _handleClickRestore() async {
    windowManager.restore();
  }
  // Future<void> initSystemTray() async {
  //   String? path;
  //   if (Platform.isWindows) {
  //     path = p.joinAll([
  //       p.dirname(Platform.resolvedExecutable),
  //       'data/flutter_assets/assets',
  //       'logoWTbgA.jpg'
  //     ]);
  //   } else if (Platform.isMacOS) {
  //     path = p.joinAll(['AppIcon']);
  //   }
  //
  //   // We first init the systray menu and then add the menu entries
  //   await _systemTray.initSystemTray('Tray', toolTip: 'Help', iconPath: path);
  //
  //   await _systemTray.setContextMenu(
  //     [
  //       MenuItem(
  //         label: 'Show',
  //         onClicked: () {
  //           // appWindow.show();
  //         },
  //       ),
  //       MenuSeparator(),
  //       SubMenu(
  //         label: "SubMenu",
  //         children: [
  //           MenuItem(
  //             label: 'SubItem1',
  //             enabled: false,
  //             onClicked: () {
  //               print("click SubItem1");
  //             },
  //           ),
  //           MenuItem(label: 'SubItem2'),
  //           MenuItem(label: 'SubItem3'),
  //         ],
  //       ),
  //       MenuSeparator(),
  //       MenuItem(
  //         label: 'Exit',
  //         onClicked: () {
  //           // appWindow.close();
  //         },
  //       ),
  //     ],
  //   );
  //
  //   // flash tray icon
  //   _timer = Timer.periodic(
  //     const Duration(milliseconds: 500),
  //     (timer) {
  //       _toggleTrayIcon = !_toggleTrayIcon;
  //       _systemTray.setSystemTrayInfo(
  //         iconPath: _toggleTrayIcon ? "" : path,
  //       );
  //     },
  //   );
  //
  //   // handle system tray event
  //   _systemTray.registerSystemTrayEventHandler((eventName) {
  //     print("eventName: $eventName");
  //   });
  // }

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
    // updateRam();
    _prefs.then((SharedPreferences prefs) {
      _isOilNotifOn = (prefs.getBool('isOilNotifOn') ?? true);
    });
    _prefs.then((SharedPreferences prefs) {
      _isTrayEnabled = (prefs.getBool('isTrayEnabled') ?? true);
    });
    _prefs.then((SharedPreferences prefs) {
      _isWaterNotifOn = (prefs.getBool('isWaterNotifOn') ?? true);
    });
    _prefs.then((SharedPreferences prefs) {
      _isEngineDeathNotifOn = (prefs.getBool('isEngineDeathNotifOn') ?? true);
    });
    _prefs.then((SharedPreferences prefs) {
      _isFullNotifOn = (prefs.getBool('isFullNotifOn') ?? true);
    });
    keyRegister();
    TrayManager.instance.addListener(this);
    windowManager.addListener(this);
    updateMsgId();
    updateStateIndicator();
    super.initState();
    const twoSec = Duration(milliseconds: 2000);
    Timer.periodic(twoSec, (Timer t) {
      updateMsgId();
      flapChecker();
      // updateRam();
    });
    const oneSec = Duration(milliseconds: 200);
    Timer.periodic(oneSec, (Timer t) => updateStateIndicator());
    const averageTimer = Duration(milliseconds: 2000);
    Timer.periodic(averageTimer, (Timer t) {
      averageTAS();
      averageTasForStall();
      hostChecker();
    });
    windowManager.addListener(this);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      stateData = ModalRoute.of(context)?.settings.arguments as ToolDataState;
      indicatorData =
          ModalRoute.of(context)?.settings.arguments as ToolDataIndicator;
    });
    idData.addListener(() {
      setState(() {
        isDamageIDNew = true;
      });
      vehicleStateCheck();
      run = false;
    });
    textForIasFlap.addListener(() {
      isUserIasFlapNew = true;
    });
    msgDataNotifier.addListener(() {
      isDamageMsgNew = true;
    });
    textForIasGear.addListener(() {
      isUserIasGearNew = true;
    });
    textForGLoad.addListener(() {
      isUserGLoadNew = true;
    });
    const redLineTimer = Duration(milliseconds: 1500);
    Timer.periodic(redLineTimer, (Timer t) {
      userRedLineFlap();
      userRedLineGear();
      loadChecker();
      pullUpChecker();
    });
    Future.delayed(Duration(milliseconds: 250), () {
      widget1Opacity = 1;
    });
  }

  void _trayInit() async {
    await TrayManager.instance.setIcon(
      'assets/app_icon.ico',
    );
    List<MenuItem> menuItems = [
      MenuItem(
        identifier: 'exit-app',
        title: 'Exit',
      ),
      MenuItem(identifier: 'show-app', title: 'Show')
    ];
    await TrayManager.instance.setContextMenu(menuItems);
  }

  void _trayUnInit() async {
    await TrayManager.instance.destroy();
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
    // bool isFullScreen = await windowManager.isFullScreen();
    // HotKeyManager.instance.register(
    //   HotKey(
    //     KeyCode.digit3,
    //     modifiers: [KeyModifier.alt],
    //   ),
    //   keyDownHandler: (_) async {
    //     if (!isFullScreen) {
    //       await Window.enterFullscreen();
    //     }
    //     if (isFullScreen) {
    //       await Window.exitFullscreen();
    //     }
    //     print(isFullScreen);
    //   },
    // );
  }

  fuelIndicator() {
    if (stateData.minFuel != null) {
      fuelPercent = (stateData.minFuel / stateData.maxFuel) * 100;
    }
    return Flexible(
        child: MediaQuery.of(context).size.height >= 235
            ? Container(
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
                        color: Colors.pink.withOpacity(boxShadowOpacity),
                        spreadRadius: 4,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      )
                    ]),
                child: stateData.minFuel != null && fuelPercent! >= 15.00
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
                            fuelPercent! < 15.00 &&
                            (stateData.height != 32 && stateData.minFuel != 0)
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
                                'No Data.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20,
                                    letterSpacing: 2,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ))
            : Container(
                height: 45,
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
                        color: Colors.pink.withOpacity(boxShadowOpacity),
                        spreadRadius: 4,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      )
                    ]),
                child: stateData.minFuel != null && fuelPercent! >= 15.00
                    ? TextButton.icon(
                        icon: Icon(Icons.speed),
                        onPressed: () {},
                        label: Expanded(
                          child: Text(
                            'Remaining Fuel = ${fuelPercent!.toStringAsFixed(0)}%',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 17,
                                letterSpacing: 2,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    : stateData.minFuel != null &&
                            fuelPercent! < 15.00 &&
                            (stateData.height != 32 && stateData.minFuel != 0)
                        ? TextButton.icon(
                            icon: Icon(Icons.speed),
                            onPressed: () {},
                            label: Expanded(
                              child: BlinkText(
                                'Remaining Fuel = ${fuelPercent!.toStringAsFixed(0)}%',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 17,
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
                                'No Data.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 17,
                                    letterSpacing: 2,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )));
  }

  waterTempText() {
    return Flexible(
        fit: FlexFit.loose,
        child: MediaQuery.of(context).size.height >= 235
            ? Container(
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
                        color: Colors.pink.withOpacity(boxShadowOpacity),
                        spreadRadius: 4,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      )
                    ]),
                child: stateData.water == null || stateData.water == 15
                    ? TextButton.icon(
                        icon: Icon(Icons.water),
                        onPressed: () {
                          _isWaterNotifOn = !_isWaterNotifOn;
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(SnackBar(
                                content: _isWaterNotifOn
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
                          _isWaterNotifOn = !_isWaterNotifOn;
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(SnackBar(
                                content: _isWaterNotifOn
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
                      ))
            : Container(
                height: 45,
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
                        color: Colors.pink.withOpacity(boxShadowOpacity),
                        spreadRadius: 4,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      )
                    ]),
                child: stateData.water == null || stateData.water == 15
                    ? TextButton.icon(
                        icon: Icon(Icons.water),
                        onPressed: () {
                          _isWaterNotifOn = !_isWaterNotifOn;
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(SnackBar(
                                content: _isWaterNotifOn
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
                                fontSize: 17,
                                letterSpacing: 2,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    : TextButton.icon(
                        icon: Icon(Icons.water),
                        onPressed: () {
                          _isWaterNotifOn = !_isWaterNotifOn;
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(SnackBar(
                                content: _isWaterNotifOn
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
                                fontSize: 17,
                                letterSpacing: 2,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )));
  }

  altitudeText() {
    return Flexible(
        child: MediaQuery.of(context).size.height >= 235
            ? Container(
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
                        color: Colors.pink.withOpacity(boxShadowOpacity),
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
                            'No data available. ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                letterSpacing: 2,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                ))
            : Container(
                height: 45,
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
                        color: Colors.pink.withOpacity(boxShadowOpacity),
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
                                fontSize: 17,
                                letterSpacing: 2,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      : Expanded(
                          child: Text(
                            'No data available. ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 17,
                                letterSpacing: 2,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                )));
  }

  climbRate() {
    ToolDataState.getState();
    averageTasForStall();
    return Flexible(
        child: MediaQuery.of(context).size.height >= 235
            ? Container(
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
                        color: Colors.pink.withOpacity(boxShadowOpacity),
                        spreadRadius: 4,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      )
                    ]),
                child: TextButton.icon(
                    icon: Icon(Icons.arrow_upward),
                    onPressed: () {},
                    label: indicatorData.vertical != null &&
                                stateData.ias != null &&
                                stateData.climb != null &&
                                (stateData.ias < 250 &&
                                    stateData.climb != null &&
                                    stateData.climb != null &&
                                    stateData.climb < 60 &&
                                    indicatorData.vertical >= -135 &&
                                    indicatorData.vertical <= -50) ||
                            (stateData.ias != null &&
                                    stateData.ias < 180 &&
                                    stateData.climb != null &&
                                    stateData.climb < 10) &&
                                stateData.ias != 0 &&
                                stateData.height > 250
                        ? Expanded(
                            child: BlinkText(
                            'Absolute Climb rate = ${stateData.climb} m/s (Possible stall!)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                letterSpacing: 2,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            endColor: Colors.red,
                          ))
                        : stateData.climb != null && stateData.climb != 0.0
                            ? Expanded(
                                child: Text(
                                'Absolute Climb rate = ${stateData.climb} m/s',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20,
                                    letterSpacing: 2,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ))
                            : Expanded(
                                child: Text(
                                'No Data. ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20,
                                    letterSpacing: 2,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ))),
              )
            : Container(
                height: 45,
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
                        color: Colors.pink.withOpacity(boxShadowOpacity),
                        spreadRadius: 4,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      )
                    ]),
                child: TextButton.icon(
                    icon: Icon(Icons.arrow_upward),
                    onPressed: () {},
                    label: indicatorData.vertical != null &&
                                stateData.ias != null &&
                                (stateData.ias < 250 &&
                                    stateData.climb != null &&
                                    stateData.climb != null &&
                                    stateData.climb < 60 &&
                                    indicatorData.vertical >= -135 &&
                                    indicatorData.vertical <= -50) ||
                            (stateData.ias != null &&
                                    stateData.ias < 180 &&
                                    stateData.climb != null &&
                                    stateData.climb < 10) &&
                                stateData.ias != 0 &&
                                stateData.height > 250
                        ? Expanded(
                            child: BlinkText(
                            'Absolute Climb rate = ${stateData.climb} m/s (Possible stall!)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 17,
                                letterSpacing: 2,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            endColor: Colors.red,
                          ))
                        : stateData.climb != null && stateData.climb != 0.0
                            ? Expanded(
                                child: Text(
                                'Absolute Climb rate = ${stateData.climb} m/s',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 17,
                                    letterSpacing: 2,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ))
                            : Expanded(
                                child: Text(
                                'No Data. ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 17,
                                    letterSpacing: 2,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ))),
              ));
  }

  iasText() {
    return Flexible(
        child: MediaQuery.of(context).size.height >= 235
            ? Container(
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
                        color: Colors.pink.withOpacity(boxShadowOpacity),
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
                    : indicatorData.mach != null &&
                            indicatorData.mach >= 1 &&
                            stateData.ias != null
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
                          ))
            : Container(
                height: 45,
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
                        color: Colors.pink.withOpacity(boxShadowOpacity),
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
                                fontSize: 17,
                                letterSpacing: 2,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    : indicatorData.mach != null &&
                            indicatorData.mach >= 1 &&
                            stateData.ias != null
                        ? TextButton.icon(
                            icon: Icon(Icons.speed),
                            onPressed: () {},
                            label: Expanded(
                              child: Text(
                                'IAS = ${stateData.ias!} km/h (Above Mach) ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 17,
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
                                    fontSize: 17,
                                    letterSpacing: 2,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )));
  }

  compassText() {
    return Flexible(
        child: MediaQuery.of(context).size.height >= 235
            ? Container(
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
                        color: Colors.pink.withOpacity(boxShadowOpacity),
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
                            'No data.  ',
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
                      ))
            : Container(
                height: 45,
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
                        color: Colors.pink.withOpacity(boxShadowOpacity),
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
                            'No data.  ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 17,
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
                                fontSize: 17,
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
              child: MediaQuery.of(context).size.height >= 235
                  ? Container(
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
                              color: Colors.red.withOpacity(boxShadowOpacity),
                              spreadRadius: 4,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            )
                          ]),
                      child: TextButton.icon(
                        icon: Icon(Icons.airplanemode_active),
                        label: Expanded(
                            child: _isFullNotifOn &&
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
                                    : Text('No data.  ',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 20,
                                            letterSpacing: 2,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold))),
                        onPressed: () {},
                      ))
                  : Container(
                      height: 45,
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
                              color: Colors.red.withOpacity(boxShadowOpacity),
                              spreadRadius: 4,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            )
                          ]),
                      child: TextButton.icon(
                        icon: Icon(Icons.airplanemode_active),
                        label: Expanded(
                            child: _isFullNotifOn &&
                                    msgData == 'Engine overheated' &&
                                    run &&
                                    indicatorData.engine != 'nul' &&
                                    indicatorData.engine != null
                                ? BlinkText(
                                    'Engine Temp= ${(indicatorData!.engine.toStringAsFixed(0))} degrees  ',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 15,
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
                                            fontSize: 15,
                                            letterSpacing: 2,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold))
                                    : Text('No data.  ',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 15,
                                            letterSpacing: 2,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold))),
                        onPressed: () {},
                      )));
        });
  }

  engineThrottleText() {
    return ValueListenableBuilder(
      valueListenable: idData,
      builder: (BuildContext context, value, Widget? child) {
        return Flexible(
            child: MediaQuery.of(context).size.height >= 235
                ? Container(
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
                            color: Colors.red.withOpacity(boxShadowOpacity),
                            spreadRadius: 4,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          )
                        ]),
                    child: TextButton.icon(
                      icon: Icon(Icons.airplanemode_active),
                      label: MediaQuery.of(context).size.height >= 235
                          ? Expanded(
                              child: indicatorData.throttle != 'null' && indicatorData.throttle != 'nul'
                                  ? Text('Throttle= ${(double.parse(indicatorData.throttle) * 100).toStringAsFixed(0)}%  ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20,
                                          letterSpacing: 2,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold))
                                  : Text('No data.  ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20,
                                          letterSpacing: 2,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)))
                          : Expanded(
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
                                  : Text('No data.  ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 13, letterSpacing: 2, color: Colors.black, fontWeight: FontWeight.bold))),
                      onPressed: () {},
                    ))
                : Container(
                    height: 45,
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
                            color: Colors.red.withOpacity(boxShadowOpacity),
                            spreadRadius: 4,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          )
                        ]),
                    child: TextButton.icon(
                      icon: Icon(Icons.airplanemode_active),
                      label: MediaQuery.of(context).size.height >= 235
                          ? Expanded(
                              child: indicatorData.throttle != 'null' && indicatorData.throttle != 'nul'
                                  ? Text('Throttle= ${(double.parse(indicatorData.throttle) * 100).toStringAsFixed(0)}%  ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 17,
                                          letterSpacing: 2,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold))
                                  : Text('No data.  ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 17,
                                          letterSpacing: 2,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)))
                          : Expanded(
                              child: indicatorData.throttle != 'null' &&
                                      indicatorData.throttle != 'nul'
                                  ? Text(
                                      'Throttle= ${(double.parse(indicatorData.throttle) * 100).toStringAsFixed(0)}%  ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 17,
                                          letterSpacing: 2,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold))
                                  : Text('No data.  ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 17, letterSpacing: 2, color: Colors.black, fontWeight: FontWeight.bold))),
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
            child: MediaQuery.of(context).size.height >= 235
                ? Container(
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
                            color: Colors.red.withOpacity(boxShadowOpacity),
                            spreadRadius: 4,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          )
                        ]),
                    child: TextButton.icon(
                      icon: Icon(Icons.airplanemode_active),
                      label: Expanded(
                          child: (stateData.oil != null &&
                                      stateData.oil != 15) &&
                                  _isFullNotifOn &&
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
                                  : Text('No data.  ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20,
                                          letterSpacing: 2,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold))),
                      onPressed: () {},
                    ))
                : Container(
                    height: 45,
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
                            color: Colors.red.withOpacity(boxShadowOpacity),
                            spreadRadius: 4,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          )
                        ]),
                    child: TextButton.icon(
                      icon: Icon(Icons.airplanemode_active),
                      label: Expanded(
                          child: (stateData.oil != null &&
                                      stateData.oil != 15) &&
                                  _isFullNotifOn &&
                                  msgData == "Oil overheated" &&
                                  run
                              ? BlinkText(
                                  'Oil Temp= ${stateData.oil} degrees  ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 17,
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
                                          fontSize: 17,
                                          letterSpacing: 2,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold))
                                  : Text('No data.  ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 17,
                                          letterSpacing: 2,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold))),
                      onPressed: () {},
                    )));
      },
    );
  }

  drawerBuilder() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(color: Colors.blueGrey),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Icon(
                Icons.notifications,
                size: 100,
              ),
            ),
            SizedBox(
              height: 24,
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                  onPressed: () async {
                    final SharedPreferences prefs = await _prefs;
                    bool isFullNotifOn =
                        (prefs.getBool('isFullNotifOn') ?? true);
                    isFullNotifOn = !isFullNotifOn;
                    setState(() {
                      _isFullNotifOn = isFullNotifOn;
                    });
                    prefs.setBool("isFullNotifOn", isFullNotifOn);
                  },
                  label: _isFullNotifOn
                      ? Text(
                          'Notifications: On',
                          style: TextStyle(color: Colors.green),
                        )
                      : Text(
                          'Notifications: Off',
                          style: TextStyle(color: Colors.red),
                        ),
                  icon: _isFullNotifOn
                      ? Icon(Icons.notifications)
                      : Icon(Icons.notifications_off)),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                  onPressed: () async {
                    final SharedPreferences prefs = await _prefs;
                    bool isEngineDeathNotifOn =
                        (prefs.getBool('isEngineDeathNotifOn') ?? true);
                    isEngineDeathNotifOn = !isEngineDeathNotifOn;
                    setState(() {
                      _isEngineDeathNotifOn = isEngineDeathNotifOn;
                    });
                    prefs.setBool("isWaterNotifOn", isEngineDeathNotifOn);
                  },
                  label: _isEngineDeathNotifOn
                      ? Text(
                          'Engine Notification: On',
                          style: TextStyle(color: Colors.green),
                        )
                      : Text(
                          'Engine Notification: Off',
                          style: TextStyle(color: Colors.red),
                        ),
                  icon: _isEngineDeathNotifOn
                      ? Icon(Icons.notifications)
                      : Icon(Icons.notifications_off)),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                  onPressed: () async {
                    final SharedPreferences prefs = await _prefs;
                    bool isOilNotifOn = (prefs.getBool('isOilNotifOn') ?? true);
                    isOilNotifOn = !isOilNotifOn;
                    setState(() {
                      _isOilNotifOn = isOilNotifOn;
                    });
                    prefs.setBool("isOilNotifOn", isOilNotifOn);
                  },
                  label: _isOilNotifOn
                      ? Text(
                          'Oil Notification: On',
                          style: TextStyle(color: Colors.green),
                        )
                      : Text(
                          'Oil Notification: Off',
                          style: TextStyle(color: Colors.red),
                        ),
                  icon: _isOilNotifOn
                      ? Icon(Icons.notifications)
                      : Icon(Icons.notifications_off)),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                  onPressed: () async {
                    final SharedPreferences prefs = await _prefs;
                    bool isWaterNotifOn =
                        (prefs.getBool('isWaterNotifOn') ?? true);
                    isWaterNotifOn = !isWaterNotifOn;
                    setState(() {
                      _isWaterNotifOn = isWaterNotifOn;
                    });
                    prefs.setBool("isWaterNotifOn", isWaterNotifOn);
                  },
                  label: _isWaterNotifOn
                      ? Text(
                          'Water Notification: On',
                          style: TextStyle(color: Colors.green),
                        )
                      : Text(
                          'Water Notification: Off',
                          style: TextStyle(color: Colors.red),
                        ),
                  icon: _isWaterNotifOn
                      ? Icon(Icons.notifications)
                      : Icon(Icons.notifications_off)),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                  onPressed: () async {
                    final SharedPreferences prefs = await _prefs;
                    bool isTrayEnabled =
                        (prefs.getBool('isTrayEnabled') ?? true);
                    isTrayEnabled = !isTrayEnabled;
                    setState(() {
                      _isTrayEnabled = isTrayEnabled;
                    });
                    prefs.setBool("isTrayEnabled", isTrayEnabled);
                  },
                  label: _isTrayEnabled
                      ? Text(
                          'Minimize to tray: On',
                          style: TextStyle(color: Colors.green),
                        )
                      : Text(
                          'Minimize to tray: Off',
                          style: TextStyle(color: Colors.red),
                        ),
                  icon: Icon(Icons.minimize_rounded)),
            ),
            // Container(
            //     alignment: Alignment.topLeft,
            //     decoration: BoxDecoration(color: Colors.black87),
            //     child: Text(
            //       '$ramUsage/$ramTotal GB used',
            //       style: TextStyle(color: Colors.green),
            //     )),
          ],
        ),
      ),
    );
  }

  // final buttonColors = WindowButtonColors(
  //     iconNormal: const Color(0xFF805306),
  //     mouseOver: const Color(0xFFF6A00C),
  //     mouseDown: const Color(0xFF805306),
  //     iconMouseOver: const Color(0xFF805306),
  //     iconMouseDown: const Color(0xFFFFD500));
  var ramUsage;
  var ramTotal;
  late dynamic stateData;
  late dynamic indicatorData;
  late dynamic msgData;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  ValueNotifier<String?> msgDataNotifier = ValueNotifier('2000');
  ValueNotifier<String?> textForIasFlap = ValueNotifier('2000');
  ValueNotifier<String?> textForIasGear = ValueNotifier('2000');
  ValueNotifier<String?> textForGLoad = ValueNotifier('2000');
  bool _isTrayEnabled = true;
  bool _removeIconAfterRestored = true;
  bool _showWindowBelowTrayIcon = false;
  bool isUserIasFlapNew = false;
  bool isUserIasGearNew = false;
  bool isUserGLoadNew = false;
  bool _isFullNotifOn = true;
  bool isDamageIDNew = false;
  bool isDamageMsgNew = false;
  bool run = true;
  bool isEngineNotifOn = true;
  bool _isOilNotifOn = true;
  bool _isEngineDeathNotifOn = true;
  bool _isWaterNotifOn = true;
  double? fuelPercent;
  double boxShadowOpacity = 0.07;
  double widget1Opacity = 0.0;
  double? avgTAS;
  int? firstSpeed;
  int? secondSpeed;
  int counter = 0;
  Color borderColor = Color(0xFF805306);
  final windowManager = WindowManager.instance;
  var logoPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    '/logoWTbgA.jpg'
  ]);

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
      color: borderColor,
      child: Flex(
        direction: Axis.vertical,
        children: [
          WindowTitleBarBox(
            child: MoveWindow(
              child: Container(
                color: Colors.red,
                width: MediaQuery.of(context).size.width,
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // IconButton(
                    //     onPressed: () {
                    //       // systemT
                    //     },
                    //     icon: Icon(Icons.arrow_drop_down)),
                    MinimizeWindowButton(
                      animate: true,
                      colors: WindowButtonColors(
                          iconNormal: Colors.white,
                          mouseOver: Colors.white.withOpacity(0.1),
                          mouseDown: Colors.white.withOpacity(0.2),
                          iconMouseOver: Colors.white,
                          iconMouseDown: Colors.white),
                      onPressed: () {
                        _handleClickMinimize();
                        _isTrayEnabled ? windowManager.hide() : null;
                      },
                    ),
                    MaximizeWindowButton(
                      animate: true,
                      colors: WindowButtonColors(
                          iconNormal: Colors.white,
                          mouseOver: Colors.white.withOpacity(0.1),
                          mouseDown: Colors.white.withOpacity(0.2),
                          iconMouseOver: Colors.white,
                          iconMouseDown: Colors.white),
                    ),
                    CloseWindowButton(
                      animate: true,
                      onPressed: () {
                        windowManager.terminate();
                      },
                      colors: WindowButtonColors(
                          mouseOver: Color(0xFFD32F2F),
                          mouseDown: Color(0xFFB71C1C),
                          iconNormal: Colors.white,
                          iconMouseOver: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              child: Stack(children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
              child: Image.asset(
                'assets/event_korean_war.jpg',
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),
            Scaffold(
              drawer: drawerBuilder(),
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: true,
              appBar: MediaQuery.of(context).size.height >= 300
                  ? AppBar(
                      leading: Builder(
                        builder: (BuildContext context) {
                          return IconButton(
                            icon: Icon(Icons.list),
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                          );
                        },
                      ),
                      automaticallyImplyLeading: false,
                      elevation: 0.75,
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
                        IconButton(
                          hoverColor: Colors.yellowAccent[100],
                          tooltip:
                              'Enter red line speed for IAS with flaps open',
                          icon: Icon(
                            Icons.warning,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            String? pressedTextFlap =
                                await Navigator.of(context)
                                    .push(dialogBuilderIasFlap(context));
                            setState(() {
                              textForIasFlap.value = pressedTextFlap;
                            });
                          },
                        ),
                        IconButton(
                          onPressed: () async {
                            String? pressedTextGear =
                                await Navigator.of(context)
                                    .push(dialogBuilderIasGear(context));
                            setState(() {
                              textForIasGear.value = pressedTextGear;
                            });
                          },
                          icon: Icon(
                            Icons.warning,
                            color: Colors.deepPurple,
                          ),
                          tooltip: 'Enter IAS speed for gear red line',
                        ),
                        IconButton(
                            tooltip: 'Enter maximum GLoad to get warning',
                            onPressed: () async {
                              String? pressedTextGLoad =
                                  await Navigator.of(context)
                                      .push(dialogBuilderOverG(context));
                              setState(() {
                                textForGLoad.value = pressedTextGLoad;
                              });
                            },
                            icon: Icon(
                              Icons.warning,
                              color: Colors.amber,
                            )),
                        IconButton(
                            tooltip: 'Enter transparent page.',
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/transparent');
                            },
                            icon: Icon(Icons.window_rounded))
                      ],
                      backgroundColor: Colors.transparent,
                      centerTitle: true,
                      title: indicatorData.name != 'NULL'
                          ? Text("You're flying ${indicatorData.name}")
                          : (stateData.height == 32 &&
                                  stateData.minFuel == 0 &&
                                  stateData.flap == 0)
                              ? Text("You're in Hangar...")
                              : Text('No vehicle data available / Not flying.'))
                  : null,
              body: AnimatedOpacity(
                  duration: Duration(seconds: 5),
                  opacity: widget1Opacity,
                  child: MediaQuery.of(context).size.height >= 235
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            engineThrottleText(),
                            engineTempText(),
                            fuelIndicator(),
                            altitudeText(),
                            compassText(),
                            iasText(),
                            climbRate(),
                            oilTempText(),
                            waterTempText()
                          ],
                        )
                      : SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  engineThrottleText(),
                                  engineTempText(),
                                  fuelIndicator(),
                                ],
                              ),
                              Row(
                                children: [
                                  altitudeText(),
                                  compassText(),
                                ],
                              ),
                              Row(
                                children: [
                                  iasText(),
                                  climbRate(),
                                ],
                              ),
                              Row(
                                children: [oilTempText(), waterTempText()],
                              )
                            ],
                          ),
                        )),
              // floatingActionButton: MediaQuery.of(context).size.height >= 450 &&
              //         MediaQuery.of(context).size.width >= 450
              //     ? FloatingActionButton(
              //         backgroundColor: Colors.red,
              //         tooltip: isFullNotifOn
              //             ? 'Toggle overheat notifier(On)'
              //             : 'Toggle overheat notifier(Off)',
              //         child: isFullNotifOn
              //             ? Icon(
              //                 Icons.notifications,
              //                 color: Colors.green[400],
              //               )
              //             : Icon(
              //                 Icons.notifications_off,
              //                 color: Colors.black,
              //               ),
              //         onPressed: () {
              //           setState(() {
              //             isFullNotifOn = !isFullNotifOn;
              //           });
              //           ScaffoldMessenger.of(context)
              //             ..removeCurrentSnackBar()
              //             ..showSnackBar(SnackBar(
              //                 content: isFullNotifOn
              //                     ? Text(
              //                         'Notifications are now enabled',
              //                         style: TextStyle(color: Colors.green),
              //                       )
              //                     : Text(
              //                         'Notifications are now disabled',
              //                         style: TextStyle(color: Colors.red),
              //                       )));
              //         })
              //     : null,
            ),
          ])),
        ],
      ),
    );
  }

  @override
  void onTrayIconMouseDown() async {
    if (_showWindowBelowTrayIcon) {
      Size windowSize = await windowManager.getSize();
      Rect trayIconBounds = await TrayManager.instance.getBounds();
      Size trayIconSize = trayIconBounds.size;
      Offset trayIconNewPosition = trayIconBounds.topLeft;

      Offset newPosition = Offset(
        trayIconNewPosition.dx - ((windowSize.width - trayIconSize.width) / 2),
        trayIconNewPosition.dy,
      );

      windowManager.setPosition(newPosition);
      await Future.delayed(Duration(milliseconds: 100));
    }
    _handleClickRestore();
  }

  @override
  void onTrayIconRightMouseDown() {
    TrayManager.instance.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    print(menuItem.toJson());

    switch (menuItem.identifier) {
      case "exit-app":
        windowManager.terminate();
        break;
      case 'show-app':
        windowManager.show();
        break;
    }
  }

  @override
  void onWindowMinimize() async {
    _trayInit();
  }

  @override
  void onWindowRestore() async {
    if (_removeIconAfterRestored) {
      _trayUnInit();
    }
  }
}
