import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:blinking_text/blinking_text.dart';
import 'package:desktoasts/desktoasts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:libwinmedia/libwinmedia.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock/wakelock.dart';
import 'package:window_manager/window_manager.dart';

import 'chat.dart';
import 'damage_event.dart';
import 'indicator_receiver.dart';
import 'main.dart';
import 'state_receiver.dart';

final windowManager = WindowManager.instance;

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

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
  final _url =
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
          title: const Text(
            'Loading WTbgI',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.cyanAccent),
          ),
        ),
        body: const Center(
          child: SpinKitChasingDots(
            color: Colors.redAccent,
            size: 80.0,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            setupToolData();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text(
                  "If you didn't go to the next screen, click on More Info"),
              action: SnackBarAction(
                label: 'More Info',
                onPressed: () async {
                  _launchURL();
                },
              ),
              duration: const Duration(seconds: 5),
            ));
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.refresh),
        ),
      ),
    ]);
  }
}

//Home

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WindowListener, TrayListener {
  static Route<int> dialogBuilderIasFlap(BuildContext context) {
    TextEditingController userInputIasFlap = TextEditingController();
    return DialogRoute(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(
                          'You will be notified if IAS reaches red line speed of ${userInputIasFlap.text} km/h (With flaps open). ')));
                Navigator.of(context).pop(int.parse(userInputIasFlap.text));
              },
              child: const Text('Notify')),
        ],
        title: const Text('Red line notifier (Enter red line flap speed). '),
        content: TextField(
          // onSubmitted: onSubmit,
          onChanged: (value) {},
          controller: userInputIasFlap,
          decoration: const InputDecoration(hintText: "Enter the IAS in km/h"),
        ),
      ),
    );
  }

  static Route<int> dialogBuilderOverG(BuildContext context) {
    TextEditingController userInputOverG = TextEditingController();
    return DialogRoute(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: TextField(
                onChanged: (value) {},
                controller: userInputOverG,
                decoration:
                    const InputDecoration(hintText: 'Enter the G load number'),
              ),
              title: const Text(
                  'Red line notifier (Enter red line G load speed). '),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel')),
                ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                            content: Text(
                                'You will be notified if G load reaches red line load of ${userInputOverG.text}. ')));
                      Navigator.of(context).pop(int.parse(userInputOverG.text));
                    },
                    child: const Text('Notify'))
              ],
            ));
  }

  static Route<int> dialogBuilderIasGear(BuildContext context) {
    TextEditingController userInputIasGear = TextEditingController();
    return DialogRoute(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: TextField(
                onChanged: (value) {},
                controller: userInputIasGear,
                decoration:
                    const InputDecoration(hintText: 'Enter the IAS in km/h'),
              ),
              title:
                  const Text('Red line notifier (Enter red line gear speed). '),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel')),
                ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                            content: Text(
                                'You will be notified if IAS reaches red line speed of ${userInputIasGear.text} km/h (With gears open). ')));
                      Navigator.of(context)
                          .pop(int.parse(userInputIasGear.text));
                    },
                    child: const Text('Notify'))
              ],
            ));
  }

  void userRedLineFlap() {
    if (stateData.flap == null) return;
    if (stateData.ias != null && _textForIasFlap.value != null) {
      if (stateData.ias >= _textForIasFlap.value &&
          isUserIasFlapNew &&
          stateData.flap > 0) {
        Toast toast = Toast(
            type: ToastType.imageAndText02,
            title: '😳Flap WARNING!',
            subtitle:
                'Be careful, flaps are open and IAS has reached red line!',
            image: File(warningLogo));
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
      if (stateData.ias < _textForIasFlap.value) {
        setState(() {
          isUserIasFlapNew = true;
        });
      }
    }
  }

  void userRedLineGear() {
    if (!mounted) return;
    if (stateData.ias != null && _textForIasGear.value != null) {
      if (stateData.ias >= _textForIasGear.value! &&
          isUserIasGearNew &&
          stateData.gear > 0) {
        Toast toast = Toast(
            type: ToastType.imageAndText02,
            title: '😳Gear WARNING!',
            subtitle:
                'Be careful, gears are open and IAS has reached red line!',
            image: File(warningLogo));
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
      if (stateData.ias >= _textForIasGear.value! && stateData.gear > 0) {
        gearUpPlayer.play();
      }
      if (stateData.ias < _textForIasGear.value!) {
        setState(() {
          isUserIasGearNew = true;
        });
      }
    }
  }

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
    if (_textForGLoad.value != null &&
        isUserGLoadNew &&
        stateData.load != null &&
        stateData.load >= _textForGLoad.value!) {
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
      Toast toast = Toast(
          type: ToastType.imageAndText02,
          title: '😳Engine WARNING!',
          subtitle: 'Engine ran out of fuel and died!',
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
    if (_isOilNotifOn &&
        stateData.oil != 15 &&
        _isFullNotifOn &&
        isDamageIDNew &&
        msgData == "Oil overheated") {
      Toast toast = Toast(
          type: ToastType.imageAndText02,
          title: '😳OIL WARNING!',
          subtitle: 'Oil is overheating!',
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
    if (isEngineNotifOn &&
        stateData.oil != 15 &&
        _isFullNotifOn &&
        isDamageIDNew &&
        msgData == 'Engine overheated') {
      Toast toast = Toast(
          type: ToastType.imageAndText02,
          title: '😳ENGINE WARNING!',
          subtitle: 'Engine is overheating!',
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
    if (_isWaterNotifOn &&
        stateData.water != 15 &&
        _isFullNotifOn &&
        isDamageIDNew &&
        msgData == 'Engine overheated') {
      Toast toast = Toast(
          type: ToastType.imageAndText02,
          title: '😳ENGINE WARNING!',
          subtitle: 'Engine is overheating!',
          image: File(warningLogo));
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
      Toast toast = Toast(
          type: ToastType.imageAndText02,
          title: '😳WARNING!!',
          subtitle: 'Your vehicle is possibly destroyed / Not repairable😒',
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

    run = true;
  }

  int? emptyInt = 0;
  String? emptyString = 'No Data';
  bool? emptyBool;
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

  Future<void> updateChat() async {
    List<ChatEvents> dataForChatId = await ChatEvents.getChat();
    List<ChatEvents> dataForChatMsg = await ChatEvents.getChat();
    List<ChatEvents> dataForChatEnemy = await ChatEvents.getChat();
    List<ChatEvents> dataForChatSender = await ChatEvents.getChat();
    List<ChatEvents> dataForChatMode = await ChatEvents.getChat();
    if (!mounted) return;
    setState(() {
      chatIdFirst.value = dataForChatId.isNotEmpty
          ? dataForChatId[dataForChatId.length - 1].id
          : emptyInt;
      chatMsgFirst = dataForChatMsg.isNotEmpty
          ? dataForChatMsg[dataForChatMsg.length - 1].msg
          : emptyString;
      chatModeFirst = dataForChatMode.isNotEmpty
          ? dataForChatMode[dataForChatMode.length - 1].mode
          : emptyString;
      chatEnemyFirst = dataForChatEnemy.isNotEmpty
          ? dataForChatEnemy[dataForChatEnemy.length - 1].enemy
          : emptyBool;
      chatSenderFirst = dataForChatSender.isNotEmpty
          ? dataForChatSender[dataForChatSender.length - 1].sender
          : emptyString;
      chatIdSecond.value = dataForChatId.isNotEmpty
          ? dataForChatId[dataForChatId.length - 2].id
          : emptyInt;
      chatMsgSecond = dataForChatMsg.isNotEmpty
          ? dataForChatMsg[dataForChatMsg.length - 2].msg
          : emptyString;
      chatModeSecond = dataForChatMode.isNotEmpty
          ? dataForChatMode[dataForChatMode.length - 2].mode
          : emptyString;
      chatEnemySecond = dataForChatEnemy.isNotEmpty
          ? dataForChatEnemy[dataForChatEnemy.length - 2].enemy
          : emptyBool;
      chatSenderSecond = dataForChatSender.isNotEmpty
          ? dataForChatSender[dataForChatSender.length - 2].sender
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
    if (indicatorData.flap1 == null) return;
    if (((indicatorData.flap1 != indicatorData.flap2) ||
        msgData == 'Asymmetric flap extension' && isDamageIDNew)) {
      Toast toast = Toast(
          type: ToastType.imageAndText02,
          title: '😳Flap WARNING!!',
          subtitle: 'Flaps are not opened equally, be careful',
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
  }

  // void highAcceleration() {
  //   if (!mounted) return;
  //   if (secondSpeed == null) {
  //     return;
  //   }
  //   double? avgTAS = ((secondSpeed! - firstSpeed!) / 2);
  //   if (avgTAS >= 10 && counter == 0) {
  //     Toast toast = Toast(
  //         type: ToastType.imageAndText02,
  //         title: '😳WARNING!!',
  //         subtitle: 'Very high acceleration, be careful',
  //         image: File(warningLogo));
  //     service!.show(toast);
  //     toast.dispose();
  //     service?.stream.listen((event) {
  //       if (event is ToastActivated) {
  //         windowManager.show();
  //       }
  //     });
  //     player.play();
  //     counter++;
  //   }
  //   if (counter == 1) {
  //     Future.delayed(const Duration(seconds: 6), () {
  //       setState(() {
  //         counter = 0;
  //       });
  //     });
  //   }
  // }

  Future averageIasForStall() async {
    if (!mounted) return;
    if (secondSpeed == null) return;
    if (stateData.ias != null) {
      setState(() {
        firstSpeed = stateData.ias;
      });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          secondSpeed = stateData.ias;
        });
      });
    }
  }

  Future<void> critAoaChecker() async {
    // print(stateData.aoa);
    // print(critAoa);
    if (stateData.aoa == null || critAoa == null) return;
    if (stateData.gear > 0) return;

    if (critAoa != null && (stateData.aoa >= (critAoa! * -1))) {
      pullUpPlayer.play();
      print('pullUpPlayed');
      critAoaBool = true;
    }
    if (!(critAoa != null && (stateData.aoa >= (critAoa! * -1)))) {
      critAoaBool = false;
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
    _textForIasFlap.removeListener((userRedLineFlap));
  }

  Future<void> _handleClickMinimize() async {
    windowManager.minimize();
  }

  Future<void> _handleClickRestore() async {
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

  Future<void> hostChecker() async {
    if (await canLaunch('http://localhost:8111')) {
    } else {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: BlinkText(
            'Unable to connect to game server.',
            endColor: Colors.red,
          ),
          duration: Duration(seconds: 10),
        ));
    }
  }

  void receiveDiskValues() {
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
    _prefs.then((SharedPreferences prefs) {
      _textForIasFlap.value = (prefs.getInt('textForIasFlap') ?? 2000);
      if (_textForIasFlap.value != 2000) {
        isUserIasFlapNew = true;
      }
    });
    _prefs.then((SharedPreferences prefs) {
      _textForIasGear.value = (prefs.getInt('textForIasGear') ?? 2000);
      if (_textForIasGear.value != 2000) {
        isUserIasGearNew = true;
      }
    });
    _prefs.then((SharedPreferences prefs) {
      _textForGLoad.value = (prefs.getInt('textForGLoad') ?? 12);
      if (_textForGLoad.value != 12) {
        isUserGLoadNew = true;
      }
    });
  }

  @override
  void initState() {
    // updateRam();
    keyRegister();
    TrayManager.instance.addListener(this);
    windowManager.addListener(this);
    updateMsgId();
    updateStateIndicator();
    updateChat();
    chatSettingsManager();
    super.initState();
    const twoSec = Duration(milliseconds: 2000);
    Timer.periodic(twoSec, (Timer t) {
      updateMsgId();
      flapChecker();
      updateChat();
      chatSettingsManager();
      critAoaChecker();
      // print(stateData.aoa);
      // updateRam();
    });
    const oneSec = Duration(milliseconds: 200);
    Timer.periodic(oneSec, (Timer t) {
      updateStateIndicator();
    });
    const averageTimer = Duration(milliseconds: 2000);
    Timer.periodic(averageTimer, (Timer t) {
      // averageTAS();
      averageIasForStall();
      hostChecker();
    });
    windowManager.addListener(this);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      stateData = ModalRoute.of(context)?.settings.arguments;
      indicatorData = ModalRoute.of(context)?.settings.arguments;
    });
    idData.addListener(() {
      setState(() {
        isDamageIDNew = true;
      });
      vehicleStateCheck();
      run = false;
    });
    _textForIasFlap.addListener(() {
      isUserIasFlapNew = true;
    });
    msgDataNotifier.addListener(() {
      isDamageMsgNew = true;
    });
    _textForIasGear.addListener(() {
      isUserIasGearNew = true;
    });
    _textForGLoad.addListener(() {
      isUserGLoadNew = true;
    });
    chatIdFirst.addListener(() {
      setState(() {
        chatSettingsManager();
      });
    });
    const redLineTimer = Duration(milliseconds: 1500);
    Timer.periodic(redLineTimer, (Timer t) {
      userRedLineFlap();
      userRedLineGear();
      loadChecker();
      pullUpChecker();
      _csvThing();
    });
    Future.delayed(const Duration(milliseconds: 250), () {
      widget1Opacity = 1;
    });
    receiveDiskValues();
  }

  Future<void> _csvThing() async {
    final csvString = File(csvPath).readAsStringSync();
    Future.delayed(const Duration(milliseconds: 250), () {
      critAoa = convertCsvFileToMap(
          csvString)[indicatorData.name.toString().toLowerCase()];
      // print(convertCsvFileToMap(
      //     csvString)[indicatorData.name.toString().toLowerCase()]);

      // print(indicatorData.name.toString().toLowerCase());
      // print(convertCsvFileToMap(csvString).containsKey('f_5e'));
    });
    // a-20g: -13.0
    // a-26b: -12.0
    // a-26b_10: -12.0
    // a-26c: -12.0
    // a2d: -17.2
    // a5m4: -20.0
  }

  Map<String, double> convertCsvFileToMap(String csvString) => {
        for (final columns in LineSplitter.split(csvString)
            .skip(1)
            .map((line) => line.split(';')))
          columns.first: double.parse(columns.last.split(',').last)
      };

  Future<void> _trayInit() async {
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
  Future<void> keyRegister() async {
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
    // bool isAlwaysOnTop = await windowManager.isAlwaysOnTop();

    // HotKeyManager.instance.register(
    //   HotKey(
    //     KeyCode.digit2,
    //     modifiers: [KeyModifier.alt],
    //   ),
    //   keyDownHandler: (_) async {
    //     windowManager.setAlwaysOnTop(!isAlwaysOnTop);
    //     Future.delayed(const Duration(milliseconds: 200));
    //     isAlwaysOnTop = await windowManager.isAlwaysOnTop();
    //     windowManager.setCustomFrame(isFrameless: true);
    //   },
    // );
    HotKeyManager.instance
        .register(HotKey(KeyCode.backspace, modifiers: [KeyModifier.alt]),
            keyDownHandler: (_) {
      setState(() {
        showIas = true;
        showAlt = true;
        showCompass = true;
        showEngineTemp = true;
        showOilTemp = true;
        showWaterTemp = true;
        showThrottle = true;
        showClimb = true;
        showFuel = true;
      });
    });
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

  Widget fuelIndicator() {
    if (stateData.minFuel != null) {
      fuelPercent = (stateData.minFuel / stateData.maxFuel) * 100;
    }
    return AnimatedContainer(
        duration: const Duration(seconds: 2),
        height: MediaQuery.of(context).size.height >= 235
            ? normalHeight
            : smallHeight,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
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
                offset: const Offset(0, 3),
              )
            ]),
        child: stateData.minFuel != null && fuelPercent! >= 15.00
            ? TextButton.icon(
                icon: const Icon(Icons.speed),
                onPressed: () {
                  showFuel = !showFuel;
                },
                label: Text(
                  'Remaining Fuel = ${fuelPercent!.toStringAsFixed(0)}%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 2,
                      color: textColor,
                      fontWeight: FontWeight.bold),
                ),
              )
            : stateData.minFuel != null &&
                    fuelPercent! < 15.00 &&
                    (stateData.height != 32 && stateData.minFuel != 0)
                ? TextButton.icon(
                    icon: const Icon(Icons.speed),
                    onPressed: () {
                      showFuel = !showFuel;
                    },
                    label: BlinkText(
                      'Remaining Fuel = ${fuelPercent!.toStringAsFixed(0)}%',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          letterSpacing: 2,
                          color: textColor,
                          fontWeight: FontWeight.bold),
                      endColor: Colors.red,
                    ),
                  )
                : TextButton.icon(
                    icon: const Icon(Icons.speed),
                    onPressed: () {
                      showFuel = !showFuel;
                    },
                    label: Text(
                      'No Data.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          letterSpacing: 2,
                          color: textColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ));
  }

  Widget waterTempText() {
    return AnimatedContainer(
        duration: const Duration(seconds: 2),
        height: MediaQuery.of(context).size.height >= 235
            ? normalHeight
            : smallHeight,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
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
                offset: const Offset(0, 3),
              )
            ]),
        child: stateData.water == null || stateData.water == 15
            ? TextButton.icon(
                icon: const Icon(Icons.water),
                onPressed: () {
                  showWaterTemp = !showWaterTemp;
                },
                label: Text(
                  'Not water-cooled / No data available!  ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 2,
                      color: textColor,
                      fontWeight: FontWeight.bold),
                ),
              )
            : TextButton.icon(
                icon: const Icon(Icons.water),
                onPressed: () {
                  showWaterTemp = !showWaterTemp;
                },
                label: Text(
                  'Water Temp = ${stateData.water!} degrees  ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 2,
                      color: textColor,
                      fontWeight: FontWeight.bold),
                ),
              ));
  }

  Widget altitudeText() {
    return AnimatedContainer(
        duration: const Duration(seconds: 2),
        height: MediaQuery.of(context).size.height >= 235
            ? normalHeight
            : smallHeight,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
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
                offset: const Offset(0, 3),
              )
            ]),
        child: TextButton.icon(
          icon: const Icon(Icons.height),
          onPressed: () {
            showAlt = !showAlt;
          },
          label: stateData.height != null
              ? Text(
                  'Altitude: ${stateData.height} meters ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 2,
                      color: textColor,
                      fontWeight: FontWeight.bold),
                )
              : Text(
                  'No data available. ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 2,
                      color: textColor,
                      fontWeight: FontWeight.bold),
                ),
        ));
  }

  Widget climbRate() {
    ToolDataState.getState();
    averageIasForStall();
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      height: MediaQuery.of(context).size.height >= 235
          ? normalHeight
          : smallHeight,
      decoration: BoxDecoration(
          gradient: const LinearGradient(
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
              offset: const Offset(0, 3),
            )
          ]),
      child: TextButton.icon(
          icon: const Icon(Icons.arrow_upward),
          onPressed: () {
            showClimb = !showClimb;
          },
          label: critAoaBool ||
                  (indicatorData.vertical != null &&
                          stateData.ias != null &&
                          stateData.climb != null &&
                          (stateData.ias < 250 &&
                              stateData.climb != null &&
                              stateData.climb < 60 &&
                              indicatorData.vertical >= -135 &&
                              indicatorData.vertical <= -50) ||
                      (stateData.ias != null &&
                              stateData.ias < 180 &&
                              stateData.climb != null &&
                              stateData.climb < 10) &&
                          stateData.ias != 0 &&
                          stateData.height > 250)
              ? BlinkText(
                  'Absolute Climb rate = ${stateData.climb} m/s (Possible stall!)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 2,
                      color: textColor,
                      fontWeight: FontWeight.bold),
                  endColor: Colors.red,
                )
              : stateData.climb != null && stateData.climb != 0.0
                  ? Text(
                      'Absolute Climb rate = ${stateData.climb} m/s',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          letterSpacing: 2,
                          color: textColor,
                          fontWeight: FontWeight.bold),
                    )
                  : Text(
                      'No Data. ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          letterSpacing: 2,
                          color: textColor,
                          fontWeight: FontWeight.bold),
                    )),
    );
  }

  Widget iasText() {
    return AnimatedContainer(
        duration: const Duration(seconds: 2),
        height: MediaQuery.of(context).size.height >= 235
            ? normalHeight
            : smallHeight,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
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
                offset: const Offset(0, 3),
              )
            ]),
        child: stateData.ias == null || stateData.ias == 0
            ? TextButton.icon(
                icon: const Icon(Icons.speed),
                onPressed: () {
                  showIas = !showIas;
                },
                label: Text(
                  'Stationary / No data!  ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 2,
                      color: textColor,
                      fontWeight: FontWeight.bold),
                ),
              )
            : indicatorData.mach != null &&
                    indicatorData.mach >= 1 &&
                    stateData.ias != null
                ? TextButton.icon(
                    icon: const Icon(Icons.speed),
                    onPressed: () {
                      showIas = !showIas;
                    },
                    label: Text(
                      'IAS = ${stateData.ias!} km/h (Above Mach) ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          letterSpacing: 2,
                          color: textColor,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                : TextButton.icon(
                    icon: const Icon(Icons.speed),
                    onPressed: () {
                      showIas = !showIas;
                    },
                    label: Text(
                      'IAS = ${stateData.ias!} km/h ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          letterSpacing: 2,
                          color: textColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ));
  }

  Widget compassText() {
    return AnimatedContainer(
        duration: const Duration(seconds: 2),
        height: MediaQuery.of(context).size.height >= 235
            ? normalHeight
            : smallHeight,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
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
                offset: const Offset(0, 3),
              )
            ]),
        child: indicatorData.compass == '0' || indicatorData.compass == null
            ? TextButton.icon(
                icon: const Icon(Icons.gps_fixed),
                onPressed: () {
                  showCompass = !showCompass;
                },
                label: Text(
                  'No data.  ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 2,
                      color: textColor,
                      fontWeight: FontWeight.bold),
                ),
              )
            : TextButton.icon(
                icon: const Icon(Icons.gps_fixed),
                onPressed: () {
                  showCompass = !showCompass;
                },
                label: Text(
                  'Compass = ${indicatorData.compass?.toStringAsFixed(0)} degrees ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 2,
                      color: textColor,
                      fontWeight: FontWeight.bold),
                ),
              ));
  }

  Widget engineTempText() {
    return ValueListenableBuilder(
        valueListenable: idData,
        builder: (BuildContext context, value, Widget? child) {
          return AnimatedContainer(
              duration: const Duration(seconds: 2),
              height: MediaQuery.of(context).size.height >= 235
                  ? normalHeight
                  : smallHeight,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
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
                      offset: const Offset(0, 3),
                    )
                  ]),
              child: TextButton.icon(
                icon: const Icon(Icons.airplanemode_active),
                label: _isFullNotifOn &&
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
                            color: textColor,
                            fontWeight: FontWeight.bold),
                        endColor: Colors.red,
                        times: 13,
                        duration: const Duration(milliseconds: 300),
                      )
                    : indicatorData.engine != null
                        ? Text(
                            'Engine Temp= ${(indicatorData.engine.toStringAsFixed(0))} degrees  ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                letterSpacing: 2,
                                color: textColor,
                                fontWeight: FontWeight.bold))
                        : Text('No data.  ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                letterSpacing: 2,
                                color: textColor,
                                fontWeight: FontWeight.bold)),
                onPressed: () {
                  showEngineTemp = !showEngineTemp;
                },
              ));
        });
  }

  Widget engineThrottleText() {
    return ValueListenableBuilder(
      valueListenable: idData,
      builder: (BuildContext context, value, Widget? child) {
        return AnimatedContainer(
            duration: const Duration(seconds: 2),
            height: MediaQuery.of(context).size.height >= 235
                ? normalHeight
                : smallHeight,
            decoration: BoxDecoration(
                gradient: const LinearGradient(
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
                    offset: const Offset(0, 3),
                  )
                ]),
            child: TextButton.icon(
              icon: const Icon(Icons.airplanemode_active),
              label: MediaQuery.of(context).size.height >= 235
                  ? indicatorData.throttle != 'null' &&
                          indicatorData.throttle != 'nul'
                      ? Text(
                          'Throttle= ${(double.parse(indicatorData.throttle) * 100).toStringAsFixed(0)}%  ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              letterSpacing: 2,
                              color: textColor,
                              fontWeight: FontWeight.bold))
                      : Text('No data.  ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              letterSpacing: 2,
                              color: textColor,
                              fontWeight: FontWeight.bold))
                  : indicatorData.throttle != 'null' &&
                          indicatorData.throttle != 'nul'
                      ? Text(
                          'Throttle= ${(double.parse(indicatorData.throttle) * 100).toStringAsFixed(0)}%  ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              letterSpacing: 2,
                              color: textColor,
                              fontWeight: FontWeight.bold))
                      : Text('No data.  ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13,
                              letterSpacing: 2,
                              color: textColor,
                              fontWeight: FontWeight.bold)),
              onPressed: () {
                showThrottle = !showThrottle;
              },
            ));
      },
    );
  }

  Widget oilTempText() {
    return ValueListenableBuilder(
      valueListenable: idData,
      builder: (BuildContext context, value, Widget? child) {
        return AnimatedContainer(
            duration: const Duration(seconds: 2),
            height: MediaQuery.of(context).size.height >= 235
                ? normalHeight
                : smallHeight,
            decoration: BoxDecoration(
                gradient: const LinearGradient(
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
                    offset: const Offset(0, 3),
                  )
                ]),
            child: TextButton.icon(
              icon: const Icon(Icons.airplanemode_active),
              label: (stateData.oil != null && stateData.oil != 15) &&
                      _isFullNotifOn &&
                      msgData == "Oil overheated" &&
                      run
                  ? BlinkText(
                      'Oil Temp= ${stateData.oil} degrees  ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          letterSpacing: 2,
                          color: textColor,
                          fontWeight: FontWeight.bold),
                      endColor: Colors.red,
                      times: 13,
                      duration: const Duration(milliseconds: 200),
                    )
                  : stateData.oil != null && stateData.oil != 15
                      ? Text('Oil Temp= ${stateData.oil} degrees  ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              letterSpacing: 2,
                              color: textColor,
                              fontWeight: FontWeight.bold))
                      : Text('No data.  ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              letterSpacing: 2,
                              color: textColor,
                              fontWeight: FontWeight.bold)),
              onPressed: () {
                showOilTemp = !showOilTemp;
              },
            ));
      },
    );
  }

  Widget chatBuilder(String? chatSender, String? chatMsg, String? chatPrefix) {
    return ValueListenableBuilder(
        valueListenable: chatIdFirst,
        builder: (BuildContext context, value, Widget? child) {
          return Column(
            children: [
              Container(
                  alignment: Alignment.topCenter,
                  height: 30,
                  child: chatMsg != 'No Data'
                      ? Text(
                          '$chatSender says:',
                          style: TextStyle(color: chatColorFirst),
                        )
                      : null),
              Container(
                  alignment: Alignment.topLeft,
                  height: 40,
                  child: chatMsg != 'No Data'
                      ? ListView(children: [
                          Text(
                            '$chatPrefix $chatMsg',
                            style: TextStyle(color: chatColorFirst),
                          )
                        ])
                      : null),
            ],
          );
        });
  }

  chatSettingsManager() {
    if (!mounted) return;
    setState(() {
      if (chatModeFirst == 'All') {
        chatPrefixFirst = '[ALL]';
      }
      if (chatModeFirst == 'Team') {
        chatPrefixFirst = '[Team]';
      }
      if (chatModeFirst == 'Squad') {
        chatPrefixFirst = '[Squad]';
      }
      if (chatModeFirst == null) {
        chatPrefixFirst = null;
      }
      if (chatSenderFirst == null) {
        chatSenderFirst == emptyString;
      }
      if (chatEnemyFirst == true) {
        chatColorFirst = Colors.red;
      } else {
        chatColorFirst = Colors.lightBlueAccent;
      }
    });
    setState(() {
      if (chatModeSecond == 'All') {
        chatPrefixSecond = '[ALL]';
      }
      if (chatModeSecond == 'Team') {
        chatPrefixSecond = '[Team]';
      }
      if (chatModeSecond == 'Squad') {
        chatPrefixSecond = '[Squad]';
      }
      if (chatModeSecond == null) {
        chatPrefixSecond = null;
      }
      if (chatSenderSecond == null) {
        chatSenderSecond == emptyString;
      }
      if (chatEnemyFirst == true) {
        chatColorSecond = Colors.red;
      } else {
        chatColorSecond = Colors.lightBlueAccent;
      }
    });
  }

  Widget drawerBuilder() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(color: Colors.deepPurple),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              curve: Curves.bounceIn,
              duration: Duration(seconds: 12),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Icon(
                Icons.settings,
                size: 100,
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
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
                      ? const Text(
                          'Notifications: On',
                          style: TextStyle(color: Colors.green),
                        )
                      : const Text(
                          'Notifications: Off',
                          style: TextStyle(color: Colors.red),
                        ),
                  icon: _isFullNotifOn
                      ? const Icon(Icons.notifications)
                      : const Icon(Icons.notifications_off)),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                  onPressed: () async {
                    final SharedPreferences prefs = await _prefs;
                    bool isEngineDeathNotifOn =
                        (prefs.getBool('isEngineDeathNotifOn') ?? true);
                    isEngineDeathNotifOn = !isEngineDeathNotifOn;
                    setState(() {
                      _isEngineDeathNotifOn = isEngineDeathNotifOn;
                    });
                    prefs.setBool("isEngineDeathNotifOn", isEngineDeathNotifOn);
                  },
                  label: _isEngineDeathNotifOn
                      ? const Text(
                          'Engine Notification: On',
                          style: TextStyle(color: Colors.green),
                        )
                      : const Text(
                          'Engine Notification: Off',
                          style: TextStyle(color: Colors.red),
                        ),
                  icon: _isEngineDeathNotifOn
                      ? const Icon(MaterialCommunityIcons.engine)
                      : const Icon(Icons.notifications_off)),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
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
                      ? const Text(
                          'Oil Notification: On',
                          style: TextStyle(color: Colors.green),
                        )
                      : const Text(
                          'Oil Notification: Off',
                          style: TextStyle(color: Colors.red),
                        ),
                  icon: _isOilNotifOn
                      ? const Icon(MaterialCommunityIcons.oil_temperature)
                      : const Icon(Icons.notifications_off)),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
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
                      ? const Text(
                          'Water Notification: On',
                          style: TextStyle(color: Colors.green),
                        )
                      : const Text(
                          'Water Notification: Off',
                          style: TextStyle(color: Colors.red),
                        ),
                  icon: _isWaterNotifOn
                      ? const Icon(MaterialCommunityIcons.water)
                      : const Icon(Icons.notifications_off)),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
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
                      ? const Text(
                          'Minimize to tray: On',
                          style: TextStyle(color: Colors.green),
                        )
                      : const Text(
                          'Minimize to tray: Off',
                          style: TextStyle(color: Colors.red),
                        ),
                  icon: const Icon(MaterialCommunityIcons.tray)),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                label: const Text('Go to information page'),
                icon: const Icon(
                  Icons.info,
                  color: Colors.cyanAccent,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/info');
                },
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                label: Text(
                    'Current red line IAS for flaps: ${_textForIasFlap.value}Km/h'),
                icon: const Icon(
                  MaterialCommunityIcons.airplane_takeoff,
                  color: Colors.red,
                ),
                onPressed: () async {
                  final SharedPreferences prefs = await _prefs;
                  _textForIasFlap.value = await Navigator.of(context)
                      .push(dialogBuilderIasFlap(context));
                  int textForIasFlap = (prefs.getInt('textForIasFlap') ?? 2000);
                  setState(() {
                    textForIasFlap = _textForIasFlap.value!;
                  });
                  prefs.setInt("textForIasFlap", textForIasFlap);
                },
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                label: Text(
                    'Current red line IAS for gears: ${_textForIasGear.value}Km/h'),
                onPressed: () async {
                  final SharedPreferences prefs = await _prefs;
                  _textForIasGear.value = await Navigator.of(context)
                      .push(dialogBuilderIasGear(context));
                  int textForIasGear = (prefs.getInt('textForIasGear') ?? 2000);

                  setState(() {
                    textForIasGear = _textForIasGear.value!;
                  });
                  prefs.setInt("textForIasGear", textForIasGear);
                },
                icon: const Icon(
                  EvilIcons.gear,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                  label:
                      Text('Current red line G load: ${_textForGLoad.value}G'),
                  onPressed: () async {
                    final SharedPreferences prefs = await _prefs;
                    _textForGLoad.value = await Navigator.of(context)
                        .push(dialogBuilderOverG(context));
                    int textForGLoad = (prefs.getInt('textForGLoad') ?? 12);

                    setState(() {
                      textForGLoad = _textForGLoad.value!;
                    });
                    prefs.setInt("textForGLoad", textForGLoad);
                  },
                  icon: const Icon(
                    MaterialCommunityIcons.airplane_landing,
                    color: Colors.amber,
                  )),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                  label: const Text('Enter transparent mode'),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/transparent');
                  },
                  icon: const Icon(MaterialCommunityIcons.dock_window)),
            ),
            Container(
              alignment: Alignment.topCenter,
              decoration: const BoxDecoration(color: Colors.black87),
              child: chatBuilder(
                  chatSenderSecond, chatMsgSecond, chatPrefixSecond),
            ),
            Container(
              alignment: Alignment.topCenter,
              decoration: const BoxDecoration(color: Colors.black87),
              child:
                  chatBuilder(chatSenderFirst, chatMsgFirst, chatPrefixFirst),
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

  Widget homeWidgetColumn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AnimatedSwitcher(
              duration: const Duration(seconds: 3),
              child: showThrottle ? engineThrottleText() : null),
          AnimatedSwitcher(
              duration: const Duration(seconds: 3),
              child: showEngineTemp ? engineTempText() : null),
          AnimatedSwitcher(
              duration: const Duration(seconds: 3),
              child: showFuel ? fuelIndicator() : null),
          AnimatedSwitcher(
              duration: const Duration(seconds: 3),
              child: showAlt ? altitudeText() : null),
          AnimatedSwitcher(
              duration: const Duration(seconds: 3),
              child: showCompass ? compassText() : null),
          AnimatedSwitcher(
              duration: const Duration(seconds: 3),
              child: showIas ? iasText() : null),
          AnimatedSwitcher(
              duration: const Duration(seconds: 3),
              child: showClimb ? climbRate() : null),
          AnimatedSwitcher(
              duration: const Duration(seconds: 3),
              child: showOilTemp ? oilTempText() : null),
          AnimatedSwitcher(
              duration: const Duration(seconds: 3),
              child: showWaterTemp ? waterTempText() : null)
        ],
      ),
    );
  }

  Widget homeWidgetRow() {
    return ListView(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: AnimatedSwitcher(
                  duration: const Duration(seconds: 3),
                  child: showThrottle ? engineThrottleText() : null),
            ),
            Expanded(
              child: AnimatedSwitcher(
                  duration: const Duration(seconds: 3),
                  child: showEngineTemp ? engineTempText() : null),
            ),
            Expanded(
              child: AnimatedSwitcher(
                  duration: const Duration(seconds: 3),
                  child: showFuel ? fuelIndicator() : null),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: AnimatedSwitcher(
                  duration: const Duration(seconds: 3),
                  child: showAlt ? altitudeText() : null),
            ),
            Expanded(
              child: AnimatedSwitcher(
                  duration: const Duration(seconds: 3),
                  child: showCompass ? compassText() : null),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: AnimatedSwitcher(
                  duration: const Duration(seconds: 3),
                  child: showIas ? iasText() : null),
            ),
            Expanded(
              child: AnimatedSwitcher(
                  duration: const Duration(seconds: 3),
                  child: showClimb ? climbRate() : null),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: AnimatedSwitcher(
                  duration: const Duration(seconds: 3),
                  child: showOilTemp ? oilTempText() : null),
            ),
            Expanded(
              child: AnimatedSwitcher(
                  duration: const Duration(seconds: 3),
                  child: showWaterTemp ? waterTempText() : null),
            )
          ],
        )
      ],
    );
  }

  Widget homeWidgetNoData() {
    return Center(
      child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: const LinearGradient(
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
                  offset: const Offset(0, 3),
                )
              ]),
          child: TextButton.icon(
            icon:
                const Icon(Icons.signal_wifi_statusbar_connected_no_internet_4),
            onPressed: () {},
            label: const Text(
              'No Data.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 50,
                  letterSpacing: 2,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold),
            ),
          )),
    );
  }

  // final buttonColors = WindowButtonColors(
  //     iconNormal: const Color(0xFF805306),
  //     mouseOver: const Color(0xFFF6A00C),
  //     mouseDown: const Color(0xFF805306),
  //     iconMouseOver: const Color(0xFF805306),
  //     iconMouseDown: const Color(0xFFFFD500));

  Color? chatColorFirst;
  Color? chatColorSecond;

  Player pullUpPlayer = Player(id: 3);
  Player gearUpPlayer = Player(id: 2);
  Player overGPlayer = Player(id: 1);
  Player player = Player(id: 0);

  dynamic stateData;
  dynamic indicatorData;
  String? msgData;
  String? chatMsgFirst;
  String? chatModeFirst;
  String? chatSenderFirst;
  String? chatSenderSecond;
  String? chatMsgSecond;
  String? chatModeSecond;
  String? chatPrefixFirst;
  String? chatPrefixSecond;
  String logoPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    '/logoWTbgA.jpg'
  ]);
  String warningLogo = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'WARNING.png'
  ]);
  String csvPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'fm_data_db.csv'
  ]);
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  ValueNotifier<int?> chatIdSecond = ValueNotifier(null);
  ValueNotifier<int?> chatIdFirst = ValueNotifier(null);
  ValueNotifier<String?> msgDataNotifier = ValueNotifier('2000');
  final ValueNotifier<int?> _textForIasFlap = ValueNotifier(2000);
  final ValueNotifier<int?> _textForIasGear = ValueNotifier(2000);
  final ValueNotifier<int?> _textForGLoad = ValueNotifier(12);
  bool _isTrayEnabled = true;
  final bool _removeIconAfterRestored = true;
  final bool _showWindowBelowTrayIcon = false;
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
  bool showIas = true;
  bool showAlt = true;
  bool showCompass = true;
  bool showEngineTemp = true;
  bool showOilTemp = true;
  bool showWaterTemp = true;
  bool showThrottle = true;
  bool showClimb = true;
  bool showFuel = true;
  bool wakeLock = false;
  bool? chatEnemySecond;
  bool? chatEnemyFirst;
  bool critAoaBool = false;
  double? fuelPercent;
  double? avgTAS;
  double? critAoa;
  double boxShadowOpacity = 0.07;
  double widget1Opacity = 0.0;
  double normalHeight = 60;
  double smallHeight = 45;
  double normalFont = 20;
  double smallFont = 17;
  int counter = 0;
  int? firstSpeed;
  int? secondSpeed;
  Color borderColor = const Color(0xFF805306);
  Color textColor = Colors.white;
  final windowManager = WindowManager.instance;
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
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
                  actions: [
                      IconButton(
                          onPressed: () async {
                            wakeLock = !wakeLock;
                            setState(() {
                              Wakelock.toggle(enable: wakeLock);
                            });
                            bool wakeLockEnabled = await Wakelock.enabled;
                            if (!wakeLockEnabled) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Screen timeout enabled"),
                                duration: Duration(seconds: 3),
                              ));
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Screen timeout disabled"),
                                duration: Duration(seconds: 3),
                              ));
                            }
                          },
                          icon: wakeLock
                              ? const Icon(
                                  Icons.timelapse_outlined,
                                  color: Colors.green,
                                )
                              : const Icon(
                                  Icons.timelapse_outlined,
                                  color: Colors.red,
                                ))
                    ],
                  leading: Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                        icon: const Icon(Icons.list),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      );
                    },
                  ),
                  automaticallyImplyLeading: false,
                  elevation: 0.75,
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  title: indicatorData.name != 'NULL'
                      ? Text("You're flying ${indicatorData.name}")
                      : (stateData.height == 32 &&
                              stateData.minFuel == 0 &&
                              stateData.flap == 0)
                          ? const Text("You're in Hangar...")
                          : const Text(
                              'No vehicle data available / Not flying.'))
              : null,
          body: AnimatedOpacity(
              duration: const Duration(seconds: 3),
              opacity: widget1Opacity,
              child: MediaQuery.of(context).size.height >= 235 &&
                      (indicatorData.valid == true &&
                          indicatorData.valid != null)
                  ? homeWidgetColumn()
                  : MediaQuery.of(context).size.height < 235 &&
                          (indicatorData.valid == true &&
                              indicatorData.valid != null)
                      ? homeWidgetRow()
                      : homeWidgetNoData())
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
          // onPressed: () {
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
    ]);
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
      await Future.delayed(const Duration(milliseconds: 100));
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
    windowManager.hide();
    _trayInit();
  }

  @override
  void onWindowRestore() async {
    if (_removeIconAfterRestored) {
      windowManager.show();
      _trayUnInit();
    }
  }
}
