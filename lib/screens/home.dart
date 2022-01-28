import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:blinking_text/blinking_text.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:desktoasts/desktoasts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libwinmedia/libwinmedia.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wtbgassistant/screens/widgets/providers.dart';
import 'package:wtbgassistant/screens/widgets/top_bar.dart';

import '../data_receivers/chat.dart';
import '../data_receivers/damage_event.dart';
import '../data_receivers/indicator_receiver.dart';
import '../data_receivers/state_receiver.dart';
import '../main.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home>
    with WindowListener, TrayListener, TickerProviderStateMixin {
  // Route<double> sliderFontSize(BuildContext context, double initialValue) {
  //   TextEditingController userInputIP =
  //       TextEditingController(text: initialValue.toString());
  //   return DialogRoute(
  //       context: context,
  //       builder: (BuildContext context) => AlertDialog(
  //             content: Slider(
  //               min: 20,
  //               max: 100,
  //               divisions: 8,
  //               label: userInputIP.text,
  //               value: initialValue,
  //               onChanged: (double value) {
  //                 userInputIP.text = value.toString();
  //                 setState(() {});
  //               },
  //             ),
  //             title: const Text('Change font size of transparent page:'),
  //             actions: [
  //               ElevatedButton(
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                   child: const Text('Cancel')),
  //               ElevatedButton(
  //                   onPressed: () {
  //                     WidgetsBinding.instance!.addPostFrameCallback((_) {
  //                       Navigator.of(context)
  //                           .pop(double.parse(userInputIP.text));
  //                     });
  //                   },
  //                   child: const Text('Update'))
  //             ],
  //           ));
  // }

  void userRedLineFlap() {
    var flapIas = ref.read(flapIasProvider.notifier);
    if (flap == null) return;
    if (ias != null) {
      if (ias! >= flapIas.state && isUserIasFlapNew && flap! > 0) {
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
      if (ias! < flapIas.state) {
        if (!mounted) return;
        isUserIasFlapNew = true;
      }
    }
  }

  void userRedLineGear() {
    var gearIas = ref.read(gearIasProvider.notifier);

    if (!mounted) return;
    if (ias != null) {
      if (ias! >= gearIas.state && isUserIasGearNew && gear! > 0) {
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
      if (ias! >= gearIas.state && gear! > 0) {
        gearUpPlayer.play();
      }
      if (ias! < gearIas.state) {
        isUserIasGearNew = true;
      }
    }
  }

  Future<void> pullUpChecker() async {
    var pullUpNotif = ref.read(pullUpNotifProvider.notifier);

    if (!mounted || !pullUpNotif.state) return;
    if (vertical != null &&
        (ias! > 400 &&
            climb != null &&
            climb! < -60 &&
            vertical! <= 135 &&
            vertical! >= 50) &&
        altitude! < 2200) {
      pullUpPlayer.play();
    }
  }

  Future<void> loadChecker() async {
    var gLoad = ref.read(gLoadProvider.notifier);
    var fullNotif = ref.read(fullNotifProvider.notifier);

    if (!mounted) return;
    if (!fullNotif.state) return;

    if (isUserGLoadNew && load != null && load! >= gLoad.state) {
      overGPlayer.play();
    }
  }

  Future<void> vehicleStateCheck() async {
    var fullNotif = ref.read(fullNotifProvider.notifier);
    var engineDeath = ref.read(engineDeathNotifProvider.notifier);

    var oilNotif = ref.read(oilNotifProvider.notifier);
    var waterNotif = ref.read(waterNotifProvider.notifier);
    var engineOh = ref.read(engineOhNotifProvider.notifier);
    if (!fullNotif.state) return;
    if (!run) return;
    if (engineDeath.state &&
        oil != 15 &&
        isDamageIDNew &&
        msgData == 'Engine died: no fuel' &&
        isDamageMsgNew) {
      Toast toast = Toast(
          type: ToastType.imageAndText02,
          title: '😳Engine WARNING!',
          subtitle: 'Engine ran out of fuel and died!',
          image: File(warningLogo));
      service!.show(toast);
      toast.dispose();

      isDamageIDNew = false;
      player.play();
    }
    if (oilNotif.state &&
        oil != 15 &&
        isDamageIDNew &&
        msgData == 'Oil overheated') {
      Toast toast = Toast(
          type: ToastType.imageAndText02,
          title: '😳OIL WARNING!',
          subtitle: 'Oil is overheating!',
          image: File(warningLogo));
      service!.show(toast);
      toast.dispose();

      isDamageIDNew = false;
      player.play();
    }
    if (engineOh.state &&
        oil != 15 &&
        isDamageIDNew &&
        msgData == 'Engine overheated') {
      Toast toast = Toast(
          type: ToastType.imageAndText02,
          title: '😳ENGINE WARNING!',
          subtitle: 'Engine is overheating!',
          image: File(warningLogo));
      service!.show(toast);
      toast.dispose();

      isDamageIDNew = false;
      player.play();
    }
    if (waterNotif.state &&
        water != 15 &&
        isDamageIDNew &&
        msgData == 'Water overheated') {
      Toast toast = Toast(
          type: ToastType.imageAndText02,
          title: '😳ENGINE WARNING!',
          subtitle: 'Engine is overheating!',
          image: File(warningLogo));
      service!.show(toast);

      toast.dispose();
      isDamageIDNew = false;
      player.play();
    }
    if (engineDeath.state &&
        oil != 15 &&
        isDamageIDNew &&
        msgData == 'Engine died: overheating') {
      Toast toast = Toast(
          type: ToastType.imageAndText02,
          title: '😳ENGINE WARNING!',
          subtitle: 'Engine died!! ',
          image: File(warningLogo));
      service!.show(toast);
      toast.dispose();

      isDamageIDNew = false;
      player.play();
    }
    if (engineDeath.state &&
        oil != 15 &&
        isDamageIDNew &&
        msgData == 'Engine died: propeller broken') {
      Toast toast = Toast(
          type: ToastType.imageAndText02,
          title: '😳ENGINE WARNING!',
          subtitle: 'Engine died!! ',
          image: File(warningLogo));
      service!.show(toast);
      toast.dispose();

      isDamageIDNew = false;
      player.play();
    }
    if (oil != 15 &&
        isDamageIDNew &&
        msgData == 'You are out of ammunition. Reloading is not possible.') {
      Toast toast = Toast(
          type: ToastType.imageAndText02,
          title: '😳WARNING!!',
          subtitle: 'Your vehicle is possibly destroyed / Not repairable😒',
          image: File(warningLogo));
      service!.show(toast);
      toast.dispose();

      isDamageIDNew = false;
      player.play();
    }

    run = false;
  }

  int? emptyInt = 0;
  String? emptyString = 'No Data';
  bool? emptyBool;
  ValueNotifier<int?> idData = ValueNotifier<int?>(null);

  Future<ToolDataState> updateState() async {
    try {
      ToolDataState state = await ToolDataState.getState();
      return state;
    } catch (e) {
      // log(e.toString(), stackTrace: st);
      rethrow;
    }
  }

  Future<void> updateMsgId() async {
    List<Damage> dataForId = await Damage.getDamage();
    List<Damage> dataForMsg = await Damage.getDamage();
    if (!mounted) return;
    idData.value =
        dataForId.isNotEmpty ? dataForId[dataForId.length - 1].id : emptyInt;
    msgData = dataForMsg.isNotEmpty
        ? dataForMsg[dataForMsg.length - 1].msg
        : emptyString;
  }

  Future<void> updateChat() async {
    List<ChatEvents> dataForChatId = await ChatEvents.getChat();
    // List<ChatEvents> dataForChatMsg = await ChatEvents.getChat();
    // List<ChatEvents> dataForChatSender = await ChatEvents.getChat();
    // List<ChatEvents> dataForChatMode = await ChatEvents.getChat();
    if (!mounted) return;
    chatIdFirst.value = dataForChatId.isNotEmpty
        ? dataForChatId[dataForChatId.length - 1].id
        : emptyInt;
    // chatMsgFirst = dataForChatMsg.isNotEmpty
    //     ? dataForChatMsg[dataForChatMsg.length - 1].msg
    //     : emptyString;
    // chatModeFirst = dataForChatMode.isNotEmpty
    //     ? dataForChatMode[dataForChatMode.length - 1].mode
    //     : emptyString;
    // chatEnemyFirst = dataForChatEnemy.isNotEmpty
    //     ? dataForChatEnemy[dataForChatEnemy.length - 1].enemy
    //     : emptyBool;
    // chatSenderFirst = dataForChatSender.isNotEmpty
    //     ? dataForChatSender[dataForChatSender.length - 1].sender
    //     : emptyString;
    chatIdSecond.value = dataForChatId.isNotEmpty
        ? dataForChatId[dataForChatId.length - 2].id
        : emptyInt;
    // chatMsgSecond = dataForChatMsg.isNotEmpty
    //     ? dataForChatMsg[dataForChatMsg.length - 2].msg
    //     : emptyString;
    // chatModeSecond = dataForChatMode.isNotEmpty
    //     ? dataForChatMode[dataForChatMode.length - 2].mode
    //     : emptyString;
    // chatEnemySecond = dataForChatEnemy.isNotEmpty
    //     ? dataForChatEnemy[dataForChatEnemy.length - 2].enemy
    //     : emptyBool;
    // chatSenderSecond = dataForChatSender.isNotEmpty
    //     ? dataForChatSender[dataForChatSender.length - 2].sender
    //     : emptyString;
  }

  void flapChecker() {
    if (flap1 == null) return;
    if (!run) return;
    if (((flap1 != flap2) ||
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

  Future<void> averageIasForStall() async {
    if (!mounted) return;
    if (secondSpeed == null) return;
    if (ias != null) {
      firstSpeed = ias;
      Future.delayed(const Duration(seconds: 2), () {
        secondSpeed = ias;
      });
    }
  }

  Future<void> critAoaChecker() async {
    var stallNotif = ref.read(stallNotifProvider.notifier);
    if (aoa == null || critAoa == 10000 || gear == null) return;

    if (gear! > 0) return;
    if (secondSpeed == null || firstSpeed == null) return;
    int averageIas = secondSpeed! - firstSpeed!;
    if (averageIas <= 10) return;

    if (critAoa != 10000 && (aoa! >= (critAoa * -1)) && stallNotif.state) {
      pullUpPlayer.play();
      critAoaBool = true;
    }
    if (!(critAoa != 10000 && (aoa! >= (critAoa * -1)))) {
      critAoaBool = false;
    }
  }

  Future<void> _handleClickRestore() async {
    windowManager.restore();
    windowManager.show();
  }

  Future<void> startServer() async {
    var nonePost = ref.read(nonePostProvider.notifier);
    var phoneConnected = ref.read(phoneConnectedProvider.notifier);
    var vehicleName = ref.read(vehicleNameProvider.notifier);
    var ipAddress = ref.read(ipAddressProvider.notifier);
    int check = 0;
    Future.delayed(const Duration(milliseconds: 800), () {
      HttpServer.bind(InternetAddress.anyIPv4, 55200).then((HttpServer server) {
        print('[+]WebSocket listening at -- ws://${ipAddress.state}:55200');
        server.listen((HttpRequest request) {
          WebSocketTransformer.upgrade(request).then((WebSocket ws) {
            ws.listen(
              (data) {
                nonePost.state = false;
                headerColor = Colors.deepPurple;
                drawerIcon = Icons.settings;
                Map<String, dynamic> serverData = {
                  'vehicleName': vehicleName.state,
                  'ias': ias,
                  'climb': climb,
                  'damageId': idData.value,
                  'damageMsg': msgData,
                  'critAoa': critAoa,
                  'aoa': aoa,
                  'throttle': throttle,
                  'engineTemp': engine,
                  'oil': oil,
                  'water': water,
                  'altitude': altitude,
                  'minFuel': minFuel,
                  'maxFuel': maxFuel,
                  'gear': gear,
                  // 'chat1': chatMsgFirst,
                  'chatId1': chatIdFirst.value,
                  // 'chat2': chatMsgSecond,
                  'chatId2': chatIdSecond.value,
                  // 'chatMode1': chatModeFirst,
                  // 'chatMode2': chatModeSecond,
                  // 'chatSender1': chatSenderFirst,
                  // 'chatSender2': chatSenderSecond,
                  // 'chatEnemy1': chatEnemyFirst,
                  // 'chatEnemy2': chatEnemySecond,
                  'check': check++
                };
                var internalData = jsonDecode(data);
                if (internalData == null) {
                  nonePost.state = true;
                  headerColor = Colors.red;
                  drawerIcon = Icons.warning;
                  ws.close();
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar
                    ..showSnackBar(const SnackBar(
                        content: Text('Abnormal connection request detected')));
                }
                phoneConnected.state = (internalData['WTbgA']);
                phoneState.value = (internalData['state']);
                streamState.value = internalData['startStream'];
                Timer(const Duration(milliseconds: 300), () {
                  if (ws.readyState == WebSocket.open) {
                    ws.add(json.encode(serverData));
                  }
                });
              },
              onDone: () {
                print('[+]Done :)');
                phoneConnected.state = false;
              },
              onError: (err) => print('[!]Error -- ${err.toString()}'),
              cancelOnError: false,
            );
          }, onError: (err) {
            nonePost.state = true;
            headerColor = Colors.red;
            drawerIcon = Icons.warning;
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar
              ..showSnackBar(const SnackBar(
                  content: BlinkText(
                'Abnormal connection request detected',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.cyan),
                endColor: Colors.red,
              )));
            print('[!]Error -- ${err.toString()}');
          });
        }, onError: (err) => print('[!]Error -- ${err.toString()}'));
      }, onError: (err) => print('[!]Error -- ${err.toString()}'));
    });
  }

  void receiveDiskValues() {
    var fullNotif = ref.read(fullNotifProvider.notifier);
    var oilNotif = ref.read(oilNotifProvider.notifier);
    var engineDeath = ref.read(engineDeathNotifProvider.notifier);
    var pullUpNotif = ref.read(pullUpNotifProvider.notifier);
    var waterNotif = ref.read(waterNotifProvider.notifier);
    var tray = ref.read(trayProvider.notifier);
    var flapIas = ref.read(flapIasProvider.notifier);
    var gearIas = ref.read(gearIasProvider.notifier);
    var gLoad = ref.read(gLoadProvider.notifier);
    var stallNotif = ref.read(stallNotifProvider.notifier);

    var transparentFont = ref.read(transparentFontProvider.notifier);
    _prefs.then((SharedPreferences prefs) {
      lastId = (prefs.getInt('lastId') ?? 0);
    });
    _prefs.then((SharedPreferences prefs) {
      transparentFont.state = (prefs.getDouble('fontSize') ?? 40);
    });
    _prefs.then((SharedPreferences prefs) {
      pullUpNotif.state = (prefs.getBool('isPullUpEnabled') ?? true);
    });
    _prefs.then((SharedPreferences prefs) {
      oilNotif.state = (prefs.getBool('isOilNotifOn') ?? true);
    });
    _prefs.then((SharedPreferences prefs) {
      stallNotif.state = (prefs.getBool('playStallWarning') ?? true);
    });
    _prefs.then((SharedPreferences prefs) {
      tray.state = (prefs.getBool('isTrayEnabled') ?? true);
    });
    _prefs.then((SharedPreferences prefs) {
      waterNotif.state = (prefs.getBool('isWaterNotifOn') ?? true);
    });
    _prefs.then((SharedPreferences prefs) {
      engineDeath.state = (prefs.getBool('isEngineDeathNotifOn') ?? true);
    });
    _prefs.then((SharedPreferences prefs) {
      fullNotif.state = (prefs.getBool('isFullNotifOn') ?? true);
    });
    _prefs.then((SharedPreferences prefs) {
      flapIas.state = (prefs.getInt('textForIasFlap') ?? 2000);
      if (flapIas.state != 2000) {
        isUserIasFlapNew = true;
      }
    });
    _prefs.then((SharedPreferences prefs) {
      gearIas.state = (prefs.getInt('textForIasGear') ?? 2000);
      if (gearIas.state != 2000) {
        isUserIasGearNew = true;
      }
    });
    _prefs.then((SharedPreferences prefs) {
      gLoad.state = (prefs.getInt('textForGLoad') ?? 12);
      if (gLoad.state != 2000) {
        isUserGLoadNew = true;
      }
    });
  }

  Future<void> giveIps() async {
    var ipAddress = ref.read(ipAddressProvider.notifier);
    final info = NetworkInfo();

    var wifiIP = await info.getWifiIP();
    ipAddress.state = wifiIP!;
  }

  @override
  void initState() {
    super.initState();
    var vehicleName = ref.read(vehicleNameProvider.notifier);
    var dateTimeNow = DateTime.now().millisecondsSinceEpoch;
    rpc.updatePresence(
      DiscordPresence(
        state: 'War Thunder Background Assistance',
        details: 'Enjoying WTbgA',
        startTimeStamp: dateTimeNow,
        largeImageKey: 'largelogo',
        largeImageText: 'War Thunder Background Assistance',
        // smallImageKey: 'small_image',
        // smallImageText: 'This text describes the small image.',
      ),
    );
    service?.stream.listen((event) {
      if (event is ToastActivated) {
        windowManager.show();
      }
    });
    giveIps();
    startServer();
    receiveDiskValues();
    // updatePhone();
    exitFS();
    TrayManager.instance.addListener(this);
    windowManager.addListener(this);
    updateMsgId();
    updateChat();
    // chatSettingsManager();
    const twoSec = Duration(milliseconds: 2000);
    Timer.periodic(twoSec, (Timer t) async {
      var phoneConnected = ref.read(phoneConnectedProvider.notifier);
      if (!mounted || isStopped) t.cancel();
      rpc.updatePresence(
        DiscordPresence(
          state: phoneConnected.state ? 'Using WTbgA - Mobile!' : 'Using WTbgA',
          details: phoneConnected.state
              ? 'Enjoying both desktop and mobile WTbgA!'
              : phoneConnected.state && phoneState.value == 'image'
                  ? 'Streaming using WTbgA'
                  : 'Enjoying WTbgA!',
          startTimeStamp: dateTimeNow,
          largeImageKey: 'largelogo',
          largeImageText: 'War Thunder Background Assistance',
          // smallImageKey: 'small',
          // smallImageText: 'WTbgA',
        ),
      );
      giveIps();
      updateMsgId();
      flapChecker();
      updateChat();
      // chatSettingsManager();
      critAoaChecker();
    });
    const Duration oneSec = Duration(milliseconds: 200);
    Timer.periodic(oneSec, (Timer t) async {
      if (!mounted || isStopped) return;

      setState(() {});
    });
    const Duration averageTimer = Duration(milliseconds: 2000);
    Timer.periodic(averageTimer, (Timer t) async {
      if (!mounted || isStopped) t.cancel();
      if (!mounted || isStopped) t.cancel();
      averageIasForStall();
      // hostChecker();
    });
    windowManager.addListener(this);

    phoneState.addListener(() {
      if (phoneState.value == 'home') {
        sendScreen = false;
      }
    });
    vehicleName.addListener((state) {
      _csvThing();
    });

    idData.addListener(() async {
      if (lastId != idData.value) {
        isDamageIDNew = true;
      }
      SharedPreferences prefs = await _prefs;
      lastId = (prefs.getInt('lastId') ?? 0);
      lastId = idData.value;
      prefs.setInt('lastId', lastId!);
      vehicleStateCheck();

      run = true;
    });
    streamState.addListener(() async {
      if (streamState.value == true) displayCapture();
      if (streamState.value == false) await Process.run(terminatePath, []);
    });

    var fullNotif = ref.read(fullNotifProvider.notifier);
    const redLineTimer = Duration(milliseconds: 1500);
    Timer.periodic(redLineTimer, (Timer t) async {
      if (!mounted || isStopped) t.cancel();
      if (!fullNotif.state) return;
      {
        userRedLineFlap();
        userRedLineGear();
        loadChecker();
        pullUpChecker();
      }
      // _csvThing();
    });
    Future.delayed(const Duration(milliseconds: 250), () async {
      widget1Opacity = 1;
      await windowManager.setMaximumSize(const Size(2000, 2000));

      _csvThing();
    });
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    rpc.clearPresence();
    TrayManager.instance.removeListener(this);
    windowManager.removeListener(this);
    idData.removeListener((vehicleStateCheck));

    chatIdFirst.removeListener(() {});
    chatIdSecond.removeListener(() {});

    isStopped = true;
  }

  Future<void> _csvThing() async {
    var vehicleName = ref.read(vehicleNameProvider.notifier);
    String csvFm = await File(fmPath).readAsString();
    final String csvNames = await File(namesPath).readAsString();
    Map<String, String> namesMap = convertNamesToMap(csvNames);
    csvFm = csvFm.replaceAll(',', ';');
    critAoa = convertFmToMap(csvFm)[namesMap[vehicleName.state]]!['critAoA'];
  }

  Map<String, Map<String, dynamic>> convertFmToMap(String csvString) {
    Map<String, Map<String, dynamic>> map = {};

    for (final rows in LineSplitter.split(csvString)
        .skip(1)
        .map((line) => line.split(';'))) {
      map[rows.first] = {
        'length': double.parse(rows[1]),
        'wingSpan': double.parse(rows[2]),
        'wingArea': rows[3],
        'emptyMass': rows[4],
        'maxFuelMass': rows[5],
        'critAirSpd': rows[6],
        'critAirSpdMach': rows[7],
        'critGearSpd': rows[8],
        'combatFlaps': rows[9],
        'takeoffFlaps': rows[10],
        'critFlapsSpd': rows[11],
        'critWingOverload': rows[12],
        'numEngines': rows[13],
        'maxNitro': rows[14],
        'nitroConsum': rows[15],
        'critAoA': double.parse(rows.last),
      };
    }

    return map;
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

  Future<void> _trayInit() async {
    await TrayManager.instance.setIcon(
      'assets/app_icon.ico',
    );
    List<MenuItem> menuItems = [MenuItem(key: 'show-app', title: 'Show')];
    await TrayManager.instance.setContextMenu(menuItems);
  }

  void _trayUnInit() async {
    await TrayManager.instance.destroy();
  }

  Future<void> exitFS() async {
    await Window.exitFullscreen();
    await hotKey.unregisterAll();
  }

  // chatSettingsManager() {
  //   if (!mounted) return;
  //   if (chatModeFirst == 'All') {
  //     chatPrefixFirst = '[ALL]';
  //   }
  //   if (chatModeFirst == 'Team') {
  //     chatPrefixFirst = '[Team]';
  //   }
  //   if (chatModeFirst == 'Squad') {
  //     chatPrefixFirst = '[Squad]';
  //   }
  //   if (chatModeFirst == null) {
  //     chatPrefixFirst = null;
  //   }
  //   if (chatSenderFirst == null) {
  //     chatSenderFirst == emptyString;
  //   }
  //   // if (chatEnemyFirst == true) {
  //   //   chatColorFirst = Colors.red;
  //   // } else {
  //   //   chatColorFirst = Colors.lightBlueAccent;
  //   // }
  //   if (chatModeSecond == 'All') {
  //     chatPrefixSecond = '[ALL]';
  //   }
  //   if (chatModeSecond == 'Team') {
  //     chatPrefixSecond = '[Team]';
  //   }
  //   if (chatModeSecond == 'Squad') {
  //     chatPrefixSecond = '[Squad]';
  //   }
  //   if (chatModeSecond == null) {
  //     chatPrefixSecond = null;
  //   }
  //   if (chatSenderSecond == null) {
  //     chatSenderSecond == emptyString;
  //   }
  //   // if (chatEnemyFirst == true) {
  //   //   chatColorSecond = Colors.red;
  //   // } else {
  //   //   chatColorSecond = Colors.lightBlueAccent;
  //   // }
  // }

  Color headerColor = Colors.teal;
  IconData drawerIcon = Icons.settings;

  // PreferredSizeWidget? homeAppBar(BuildContext context) {
  //   return AppBar(
  //       actions: [
  //         phoneConnected.value
  //             ? RotationTransition(
  //                 turns: _controller,
  //                 child: IconButton(
  //                   onPressed: () async {
  //                     displayCapture();
  //                   },
  //                   icon: const Icon(
  //                     Icons.wifi_rounded,
  //                     color: Colors.green,
  //                   ),
  //                   tooltip: 'Phone Connected = ${phoneConnected.value}',
  //                 ),
  //               )
  //             : IconButton(
  //                 onPressed: () {
  //                   displayCapture();
  //                 },
  //                 icon: const Icon(
  //                   Icons.wifi_rounded,
  //                   color: Colors.red,
  //                 ),
  //                 tooltip: 'Toggle Stream Mode',
  //               ),
  //       ],
  //       leading: Builder(
  //         builder: (BuildContext context) {
  //           return IconButton(
  //             icon: const Icon(Icons.list),
  //             onPressed: () {
  //               Scaffold.of(context).openDrawer();
  //             },
  //           );
  //         },
  //       ),
  //       automaticallyImplyLeading: false,
  //       elevation: 0.75,
  //       backgroundColor: Colors.transparent,
  //       centerTitle: true,
  //       title: vehicleName.value != 'NULL' && vehicleName != null
  //           ? Text("You're flying ${vehicleName}")
  //           : (altitude == 32 && minFuel == 0 && flap == 0)
  //               ? const Text("You're in Hangar...")
  //               : const Text('No vehicle data available / Not flying.'));
  // }

  void displayCapture() async {
    await launch(delPath);
  }

  Player pullUpPlayer = Player(id: 3);
  Player gearUpPlayer = Player(id: 2);
  Player overGPlayer = Player(id: 1);
  Player player = Player(id: 0);
  int? maxFuel;
  int? minFuel;
  int? gear;
  double? aoa;
  double? climb;
  double? engine;
  double? fuelPercent;
  double? avgTAS;
  double critAoa = 10000;
  double boxShadowOpacity = 0.07;
  double widget1Opacity = 0.0;
  double normalHeight = 60;
  double smallHeight = 45;
  double normalFont = 20;
  double smallFont = 17;
  double? compass;
  double? flap1, flap2, vertical;
  double? load, throttle;
  double? mach;

  int counter = 0;
  int? lastId;
  int? firstSpeed;
  int? secondSpeed;
  int? ias;
  int? flap;
  int? altitude;
  int? oil;
  int? water;

  String? msgData;
  // String? chatMsgFirst;
  // String? chatModeFirst;
  // String? chatSenderFirst;
  // String? chatSenderSecond;
  // String? chatMsgSecond;
  // String? chatModeSecond;
  // String? chatPrefixFirst;
  // String? chatPrefixSecond;
  String pathScript = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets/AutoHotkeyU64.ahk'
  ]);
  String pathAHK = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets/AutoHotkeyU64.exe'
  ]);
  String path = p.dirname(Platform.resolvedExecutable);
  String delPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'del.bat'
  ]);
  String terminatePath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'terminate.bat'
  ]);
  String somePath = p.joinAll(
      [p.dirname(Platform.resolvedExecutable), 'data/flutter_assets/assets']);
  String warningLogo = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'WARNING.png'
  ]);
  String fmPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'fm_data_db.csv'
  ]);
  String namesPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'fm_names_db.csv'
  ]);

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // ValueNotifier<String> phoneIP = ValueNotifier('');
  ValueNotifier<int?> chatIdSecond = ValueNotifier(null);
  ValueNotifier<int?> chatIdFirst = ValueNotifier(null);

  // ValueNotifier<String?> msgDataNotifier = ValueNotifier('2000');

  final ValueNotifier<bool> streamState = ValueNotifier(false);

  ValueNotifier<String?> phoneState = ValueNotifier('');
  bool isStopped = false;
  final bool _removeIconAfterRestored = true;
  final bool _showWindowBelowTrayIcon = false;
  bool? valid;
  bool isUserIasFlapNew = false;
  bool isUserIasGearNew = false;
  bool isUserGLoadNew = false;
  bool isDamageIDNew = false;
  bool isDamageMsgNew = false;
  bool run = true;

  bool sendScreen = false;

  bool critAoaBool = false;

  Color borderColor = const Color(0xFF805306);
  Color textColor = Colors.white;
  final windowManager = WindowManager.instance;

  // late final AnimationController _controller = AnimationController(
  //   duration: const Duration(seconds: 2),
  //   vsync: this,
  // )..repeat(reverse: false, period: const Duration(seconds: 1));

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    ref.listen(phoneConnectedProvider, (previous, next) {
      if (next as bool) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(const SnackBar(
              duration: Duration(seconds: 3),
              content: BlinkText(
                'Phone connected!',
                style: TextStyle(color: Colors.blue),
                endColor: Colors.red,
              )));
        Toast toast = Toast(
          type: ToastType.text02,
          title: '✅Connection Detected!',
          subtitle: 'WTbgA Mobile connected',
        );
        service!.show(toast);
        toast.dispose();
      } else {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(const SnackBar(
              duration: Duration(seconds: 3),
              content: BlinkText(
                'Phone disconnected!',
                style: TextStyle(color: Colors.blue),
                endColor: Colors.red,
              )));
        Toast toast = Toast(
          type: ToastType.text02,
          title: '✅Connection ended!',
          subtitle: 'WTbgA Mobile disconnected',
        );
        service!.show(toast);
        toast.dispose();
      }
    });
    return Stack(children: [
      ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Image.asset(
          'assets/bg.jpg',
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
      ),
      Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          appBar: PreferredSize(
            preferredSize: Size(screenSize.width, 1000),
            child: const TopBar(),
          ),
          body: Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(
                child: FutureBuilder<ToolDataState>(
                    future: updateState(),
                    builder: (context, AsyncSnapshot<ToolDataState> shot) {
                      if (shot.hasData) {
                        ias = shot.data!.ias;
                        gear = shot.data!.gear;
                        flap = shot.data!.flaps;
                        altitude = shot.data!.altitude;
                        oil = shot.data!.oilTemp1C;
                        water = shot.data!.waterTemp1C;
                        double fuel =
                            shot.data!.fuel / shot.data!.maxFuel * 100;
                        return Flex(
                          direction: Axis.vertical,
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(left: 20),
                                alignment: Alignment.topLeft,
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40),
                                        text:
                                            'Throttle= ${shot.data!.throttle1} %')
                                  ]),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(left: 20),
                                alignment: Alignment.topLeft,
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40),
                                        text: 'IAS= ${shot.data!.ias} km/h')
                                  ]),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(left: 20),
                                alignment: Alignment.topLeft,
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40),
                                        text:
                                            'Altitude= ${shot.data!.altitude} m')
                                  ]),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(left: 20),
                                alignment: Alignment.topLeft,
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40),
                                        text: 'Climb= ${shot.data!.climb} m/s')
                                  ]),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(left: 20),
                                alignment: Alignment.topLeft,
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40),
                                        text:
                                            'Fuel= ${fuel.toStringAsFixed(1)} %')
                                  ]),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(left: 20),
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40),
                                        text:
                                            'Oil Temp= ${shot.data!.oilTemp1C}°c')
                                  ]),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(left: 20),
                                alignment: Alignment.topLeft,
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40),
                                        text:
                                            'Water Temp= ${shot.data!.waterTemp1C}°c')
                                  ]),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else if (shot.hasError) {
                        // print(shot.error);
                        return const Center(
                            child: BlinkText(
                          'ERROR: NO DATA',
                          endColor: Colors.red,
                          style: TextStyle(color: Colors.white, fontSize: 40),
                        ));
                      } else {
                        return const Center(
                            child: SizedBox(
                          height: 100,
                          width: 100,
                          child: CircularProgressIndicator(
                            color: Colors.red,
                          ),
                        ));
                      }
                    }),
              ),
              FutureBuilder<ToolDataIndicator>(
                  future: ToolDataIndicator.getIndicator(),
                  builder: (context, AsyncSnapshot<ToolDataIndicator> shot) {
                    if (shot.hasData) {
                      ref.read(vehicleNameProvider.notifier).state =
                          shot.data!.type;

                      if (shot.data!.mach == null) shot.data!.mach = -0;
                      return Flex(
                        direction: Axis.vertical,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(right: 20),
                              alignment: Alignment.center,
                              child: RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 40),
                                      text:
                                          'Compass= ${shot.data!.compass.toStringAsFixed(0)}°')
                                ]),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(right: 20),
                              alignment: Alignment.center,
                              child: RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 40),
                                      text:
                                          'Mach= ${shot.data!.mach!.toStringAsFixed(1)} M')
                                ]),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    if (shot.hasError) {
                      return const Center(
                          child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: BlinkText(
                                'ERROR: NO DATA',
                                endColor: Colors.red,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 40),
                              )));
                    } else {
                      return const Center(
                          child: SizedBox(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator(
                          color: Colors.red,
                        ),
                      ));
                    }
                  })
            ],
          ))
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
    switch (menuItem.key) {
      case 'show-app':
        windowManager.show();
        break;
    }
  }

  @override
  void onWindowMinimize() {
    var tray = ref.read(trayProvider.notifier);

    if (tray.state) {
      windowManager.hide();
      _trayInit();
    }
  }

  @override
  void onWindowRestore() {
    if (_removeIconAfterRestored) {
      windowManager.show();
      _trayUnInit();
    }
  }
}
