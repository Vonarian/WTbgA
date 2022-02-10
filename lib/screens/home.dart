import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:archive/archive.dart';
import 'package:blinking_text/blinking_text.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:desktoasts/desktoasts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libwinmedia/libwinmedia.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wtbgassistant/screens/downloader.dart';
import 'package:wtbgassistant/screens/widgets/game_map.dart';
import 'package:wtbgassistant/screens/widgets/top_bar.dart';
import 'package:wtbgassistant/services/csv_class.dart';
import 'package:wtbgassistant/services/providers.dart';

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
  void userRedLineFlap() {
    var flapIas = ref.read(flapLimitProvider.notifier);
    if (flap == null) return;
    if (ias != null) {
      if (ias! >= flapIas.state && flap! >= 10) {
        player.play();
      }
    }
  }

  void userRedLineGear() {
    if (!mounted) return;
    if (ias != null) {
      if (ias! >= ref.read(gearLimitProvider.notifier).state && gear! > 0) {
        gearUpPlayer.play();
      }
      if (ias! >= ref.read(gearLimitProvider.notifier).state && gear! > 0) {
        gearUpPlayer.play();
      }
      if (ias! < ref.read(gearLimitProvider.notifier).state) {
        isUserIasGearNew = true;
      }
    }
  }

  Future<void> pullUpChecker() async {
    var pullUpNotif = ref.read(pullUpNotifProvider.notifier);

    if (!mounted || !pullUpNotif.state) return;
    if (vertical != null && ias != null) {
      if (vertical! <= -65 && ias! >= 600) {
        pullUpPlayer.play();
      }
    }
  }

  void loadChecker() {
    var fullNotif = ref.read(fullNotifProvider.notifier);
    if (!mounted) return;
    if (!fullNotif.state) return;
    if (fmData != null) {
      double maxLoad = (fmData!.critWingOverload2 /
          ((fmData!.emptyMass + fuelMass) * 9.81 / 2));

      if ((load!) >= (maxLoad - 0.4)) {
        overGPlayer.play();
      }
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
          subtitle: 'Your icons is possibly destroyed / Not repairable😒',
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
  late Future<ToolDataState> stateFuture = updateState();
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

    if (!mounted) return;
    chatIdFirst.value = dataForChatId.isNotEmpty
        ? dataForChatId[dataForChatId.length - 1].id
        : emptyInt;

    chatIdSecond.value = dataForChatId.isNotEmpty
        ? dataForChatId[dataForChatId.length - 2].id
        : emptyInt;
  }

  void flapChecker() {
    if (!run) return;
    if (msgData == 'Asymmetric flap extension' && isDamageIDNew) {
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
    if (aoa == null || critAoa == 10000) return;
    if (!stallNotif.state) return;
    if (gear! > 0) {
      critAoaBool = false;
      return;
    }
    if (vertical! >= 10 && flap! <= 10 && aoa! >= critAoa) {
      // pullUpPlayer.play();
      critAoaBool = true;
    } else if (vertical! <= -10 && flap! <= 10 && aoa! <= critAoa) {
      // pullUpPlayer.play();
      critAoaBool = true;
    } else if (vertical! <= -10 && flap! >= 10 && aoa! <= critAoa) {
      critAoa = fmData!.critAoa4;
      // pullUpPlayer.play();
      critAoaBool = true;
    } else if (vertical! >= 10 && flap! >= 10 && aoa! >= critAoa) {
      // pullUpPlayer.play();
      critAoaBool = true;
    } else {
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
    var streamState = ref.read(streamStateProvider.notifier);
    var phoneState = ref.read(phoneStateProvider.notifier);

    int check = 0;
    Future.delayed(const Duration(milliseconds: 800), () {
      HttpServer.bind(InternetAddress.anyIPv4, 55200).then((HttpServer server) {
        if (kDebugMode) {
          print('[+]WebSocket listening at -- ws://${ipAddress.state}:55200');
        }
        server.listen((HttpRequest request) {
          WebSocketTransformer.upgrade(request).then((WebSocket ws) {
            ws.listen(
              (data) {
                phoneConnected.state = true;
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
                  'maxFuel': fuelMass,
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
                phoneState.state = (internalData['state']);
                streamState.state = internalData['startStream'];
                Timer(const Duration(milliseconds: 300), () {
                  if (ws.readyState == WebSocket.open) {
                    ws.add(json.encode(serverData));
                  }
                });
              },
              onDone: () {
                if (kDebugMode) {
                  print('[+]Done :)');
                }
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
            if (kDebugMode) {
              print('[!]Error -- ${err.toString()}');
            }
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
  }

  void listener() {
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
  }

  Future<void> giveIps() async {
    var ipAddress = ref.read(ipAddressProvider.notifier);
    final info = NetworkInfo();

    var wifiIP = await info.getWifiIP();
    if (wifiIP != null) {
      ipAddress.state = wifiIP;
    }
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
      var phoneConnected = ref.watch(phoneConnectedProvider);
      if (!mounted || isStopped) t.cancel();
      rpc.updatePresence(
        DiscordPresence(
          state: phoneConnected ? 'Using WTbgA - Mobile!' : 'Using WTbgA',
          details: phoneConnected
              ? 'Enjoying both desktop and mobile WTbgA!'
              : phoneConnected &&
                      ref.read(phoneStateProvider.notifier).state == 'image'
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
      // critAoaChecker();
    });
    const Duration setStateTimer = Duration(milliseconds: 50);
    Timer.periodic(setStateTimer, (Timer t) async {
      if (!mounted || isStopped) return;
      stateFuture = updateState();
      setState(() {});
    });
    // Timer.periodic(const Duration(seconds: 5), (timer) {
    //   if (!mounted || isStopped) return;
    //
    //   if (inTray) {
    //     setState(() {});
    //   }
    // });
    const Duration averageTimer = Duration(milliseconds: 1200);
    Timer.periodic(averageTimer, (Timer t) async {
      if (!mounted || isStopped) t.cancel();
      averageIasForStall();
      critAoaChecker();

      // hostChecker();
    });
    windowManager.addListener(this);

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
    ref.read(streamStateProvider.notifier).addListener((state) async {
      if (state == true) displayCapture();
      if (state == false) await Process.run(terminatePath, []);
    });

    var fullNotif = ref.read(fullNotifProvider.notifier);
    const redLineTimer = Duration(milliseconds: 350);
    Timer.periodic(redLineTimer, (Timer t) async {
      if (!mounted || isStopped) t.cancel();
      if (!fullNotif.state) return;
      userRedLineFlap();
      userRedLineGear();
      loadChecker();
      pullUpChecker();
      checkCritAoa();
      // _csvThing();
    });
    Future.delayed(const Duration(milliseconds: 250), () async {
      // Navigator.of(context)
      //     .pushReplacement(MaterialPageRoute(builder: (context) {
      //   return const MyCanvas();
      // }));
      await windowManager.setMaximumSize(const Size(2000, 2000));
      csvNames = await File(namesPath).readAsString();

      Map<String, String> namesMap = convertNamesToMap(csvNames);
      fmData = await FmData.setObject(namesMap[vehicleName.state] ?? '');
    });
    vehicleName.addListener((state) async {
      Map<String, String> namesMap = convertNamesToMap(csvNames);
      fmData = await FmData.setObject(namesMap[state] ?? '');
      if (fmData != null) {
        ref.read(gearLimitProvider.notifier).state = fmData!.critGearSpd;
      }
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

  Future<void> checkCritAoa() async {
    if (fmData != null) {
      if (vertical! >= 10 && flap! <= 10) {
        critAoa = fmData!.critAoa1;
      }
      if (vertical! <= -10 && flap! <= 10) {
        critAoa = fmData!.critAoa2;
      }
      if (vertical! <= -10 && flap! >= 10) {
        critAoa = fmData!.critAoa4;
      }
      if (vertical! >= 10 && flap! >= 10) {
        critAoa = fmData!.critAoa3;
      }
    }
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
    inTray = true;
  }

  void _trayUnInit() async {
    await TrayManager.instance.destroy();
    inTray = false;
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

  void displayCapture() async {
    if (await File(ffmpegPath).exists()) {
      try {
        bool ffmpegExeBool = await File(ffmpegExePath).exists();
        if (!ffmpegExeBool) {
          File(ffmpegPath).readAsBytes().then((value) async {
            final archive = ZipDecoder().decodeBytes(value);

            for (final file in archive) {
              final filename = file.name;
              if (file.isFile) {
                final data = file.content as List<int>;
                File(p.dirname(ffmpegPath) + '\\$filename')
                  ..createSync(recursive: true)
                  ..writeAsBytesSync(data);
              } else {
                Directory(p.dirname(ffmpegPath) + '\\$filename')
                    .create(recursive: true);
              }
            }
          });
        } else {
          await Process.run(delPath, [], runInShell: true);
        }
      } catch (e, st) {
        log('ERROR: $e', stackTrace: st);
      }
    } else {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: const Text(
            'FFMPEG not found, for the stream to work, you will need it, download?',
          ),
          action: SnackBarAction(
              label: 'Download',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (c, a1, a2) =>
                        const Downloader(isFfmpeg: true),
                    transitionsBuilder: (c, anim, a2, child) =>
                        FadeTransition(opacity: anim, child: child),
                    transitionDuration: const Duration(milliseconds: 2000),
                  ),
                );
              }),
        ));
    }
  }

  String ffmpegPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data\\flutter_assets\\assets',
    'ffmpeg.zip'
  ]);
  String ffmpegExePath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data\\flutter_assets\\assets',
    'ffmpeg.exe'
  ]);
  Player pullUpPlayer = Player(id: 3);
  Player gearUpPlayer = Player(id: 2);
  Player overGPlayer = Player(id: 1);
  Player player = Player(id: 0);
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
  double? load, throttle;
  double? mach;
  double? vertical;
  int counter = 0;
  int? lastId;
  int? firstSpeed;
  int? secondSpeed;
  int? ias;
  int? flap;
  int? altitude;
  int? oil;
  int? water;
  FmData? fmData;
  String? msgData;
  String csvNames = '';
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

  ValueNotifier<int?> chatIdSecond = ValueNotifier(null);
  ValueNotifier<int?> chatIdFirst = ValueNotifier(null);

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
  int fuelMass = 500;
  bool sendScreen = false;
  bool inTray = false;
  bool critAoaBool = false;

  int index = 0;
  Color textColor = Colors.white;
  final windowManager = WindowManager.instance;
  bool inHangar = false;
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    listener();
    return InteractiveViewer(
      child: Stack(children: [
        !inHangar
            ? GameMap(
                inHangar: inHangar,
              )
            : ImageFiltered(
                child: Image.asset(
                  'assets/bg.jpg',
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                ),
                imageFilter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0)),
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
                      future: stateFuture,
                      builder: (context, AsyncSnapshot<ToolDataState> shot) {
                        if (shot.hasData) {
                          ias = shot.data!.ias;
                          gear = shot.data!.gear;
                          flap = shot.data!.flaps;
                          altitude = shot.data!.altitude;
                          oil = shot.data!.oilTemp1C;
                          water = shot.data!.waterTemp1C;
                          aoa = shot.data!.aoa;
                          load = shot.data!.load;
                          fuelMass = shot.data!.fuel;
                          if ((shot.data!.altitude == 32 ||
                                  shot.data!.altitude == 31) &&
                              shot.data!.gear == 100 &&
                              shot.data!.ias == 0) {
                            inHangar = true;
                          } else {
                            inHangar = false;
                          }
                          double fuel =
                              shot.data!.fuel / shot.data!.maxFuel * 100;
                          if (inHangar) {
                            return Flex(
                              direction: Axis.vertical,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 20),
                                    // decoration: BoxDecoration(
                                    //     color:
                                    //         Colors.blueGrey.withOpacity(0.3)),
                                    alignment: Alignment.center,
                                    child: RichText(
                                      text: const TextSpan(
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 40),
                                          text: 'In Hangar'),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
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
                                  child: Text(
                                    'Altitude= ${shot.data!.altitude} m',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 40),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(left: 20),
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'Climb= ${shot.data!.climb} m/s',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 40),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                    padding: const EdgeInsets.only(left: 20),
                                    alignment: Alignment.topLeft,
                                    child: fuel <= 13
                                        ? BlinkText(
                                            'Fuel= ${fuel.toStringAsFixed(1)} % (LOW)',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 40),
                                            endColor: Colors.red,
                                          )
                                        : Text(
                                            'Fuel= ${fuel.toStringAsFixed(1)} %',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 40),
                                          )),
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
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(left: 20),
                                  alignment: Alignment.topLeft,
                                  child: !critAoaBool
                                      ? Text(
                                          'AoA= ${shot.data!.aoa}°',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 40),
                                        )
                                      : BlinkText(
                                          'AoA= ${shot.data!.aoa}°',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 40),
                                        ),
                                ),
                              ),
                            ],
                          );
                        } else if (shot.hasError) {
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
                Expanded(
                  child: FutureBuilder<ToolDataIndicator?>(
                      future: ToolDataIndicator.getIndicator(),
                      builder:
                          (context, AsyncSnapshot<ToolDataIndicator?> shot) {
                        if (shot.hasData) {
                          inHangar = false;
                          WidgetsBinding.instance?.addPostFrameCallback((_) {
                            ref.read(vehicleNameProvider.notifier).state =
                                shot.data!.type;
                            vertical = shot.data!.vertical;
                          });

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
                          WidgetsBinding.instance?.addPostFrameCallback((_) {
                            ref.read(vehicleNameProvider.notifier).state =
                                'Vehicle Name not available';
                          });
                          return Center(
                            child: Container(
                                padding: const EdgeInsets.all(8.0),
                                child: const BlinkText(
                                  'ERROR: NO DATA',
                                  endColor: Colors.red,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 40),
                                )),
                          );
                        } else {
                          WidgetsBinding.instance?.addPostFrameCallback((_) {
                            ref.read(vehicleNameProvider.notifier).state =
                                'Vehicle Name not available';
                          });
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
                )
              ],
            ))
      ]),
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
      await Future.delayed(const Duration(milliseconds: 100));
    }
    _handleClickRestore();
    _trayUnInit();
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

  @override
  void onWindowFocus() {
    inTray = false;
  }

  @override
  void onWindowBlur() {
    inTray = true;
  }
}
