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
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:libwinmedia/libwinmedia.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wtbgassistant/data_receivers/github.dart';
import 'package:wtbgassistant/screens/downloader.dart';
import 'package:wtbgassistant/screens/transparent.dart';

import '../data_receivers/chat.dart';
import '../data_receivers/damage_event.dart';
import '../data_receivers/indicator_receiver.dart';
import '../data_receivers/state_receiver.dart';
import '../main.dart';

final windowManager = WindowManager.instance;

//Home

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>
    with WindowListener, TrayListener, TickerProviderStateMixin {
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
          onChanged: (value) {},
          controller: userInputIasFlap,
          decoration: const InputDecoration(hintText: 'Enter the IAS in km/h'),
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
    if (flap == null) return;
    if (ias != null) {
      if (ias! >= _textForIasFlap.value && isUserIasFlapNew && flap! > 0) {
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
      if (ias! < _textForIasFlap.value) {
        if (!mounted) return;
        setState(() {
          isUserIasFlapNew = true;
        });
      }
    }
  }

  void userRedLineGear() {
    if (!mounted) return;
    if (ias != null) {
      if (ias! >= _textForIasGear.value && isUserIasGearNew && gear! > 0) {
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
      if (ias! >= _textForIasGear.value && gear! > 0) {
        gearUpPlayer.play();
      }
      if (ias! < _textForIasGear.value) {
        setState(() {
          isUserIasGearNew = true;
        });
      }
    }
  }

  Future<void> pullUpChecker() async {
    if (!mounted || !isPullUpEnabled) return;
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
    if (!mounted) return;
    if (!_isFullNotifOn) return;

    if (isUserGLoadNew && load != null && load! >= _textForGLoad.value) {
      overGPlayer.play();
    }
  }

  Future<void> vehicleStateCheck() async {
    if (!_isFullNotifOn) return;
    if (!run) return;
    if (_isOilNotifOn &&
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
    if (_isOilNotifOn &&
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
    if (isEngineNotifOn &&
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
    if (_isWaterNotifOn &&
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
    if (_isEngineDeathNotifOn &&
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
    if (_isEngineDeathNotifOn &&
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

  // Future<void> updatePhone() async {
  //   Timer.periodic(const Duration(milliseconds: 4000), (_) async {
  //     PhoneData dataForPhone = await PhoneData.getPhoneData(phoneIP.value);
  //     phoneConnected.value = dataForPhone.active!;
  //     phoneState.value = dataForPhone.state;
  //   });
  // }

  Future<ToolDataState> updateState() async {
    try {
      ToolDataState state = await ToolDataState.getState();
      return state;
    } catch (e) {
      // log(e.toString(), stackTrace: st);
      rethrow;
    }
  }

  Future<ToolDataIndicator> updateIndicator() async {
    try {
      ToolDataIndicator indicator = await ToolDataIndicator.getIndicator();
      return indicator;
    } catch (e) {
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
    List<ChatEvents> dataForChatMsg = await ChatEvents.getChat();
    List<ChatEvents> dataForChatEnemy = await ChatEvents.getChat();
    List<ChatEvents> dataForChatSender = await ChatEvents.getChat();
    List<ChatEvents> dataForChatMode = await ChatEvents.getChat();
    if (!mounted) return;
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
      setState(() {
        firstSpeed = ias;
      });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          secondSpeed = ias;
        });
      });
    }
  }

  Future<void> checkVersion() async {
    Data data = await Data.getData();
    final File file = File(
        '${p.dirname(Platform.resolvedExecutable)}/data/flutter_assets/assets/Version/version.txt');
    final String version = await file.readAsString();
    if (int.parse(data.tagName.replaceAll('.', '')) >
        int.parse(version.replaceAll('.', ''))) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text(
                'Version: $version. Status:Proceeding to update, closing app in 4 seconds!')));

      Future.delayed(Duration(seconds: 4), () async {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return Downloader();
        }));
      });
    } else {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
            duration: Duration(seconds: 10),
            content: Text('Version: $version ___ Status: Up-to-date!')));
    }
  }

  Future<void> critAoaChecker() async {
    if (aoa == null || critAoa == null || gear == null) return;

    if (gear! > 0) return;
    if (secondSpeed == null || firstSpeed == null) return;
    int averageIas = secondSpeed! - firstSpeed!;
    if (averageIas <= 10) return;

    if (critAoa != null && (aoa! >= (critAoa! * -1)) && playStallWarning) {
      pullUpPlayer.play();
      critAoaBool = true;
    }
    if (!(critAoa != null && (aoa! >= (critAoa! * -1)))) {
      critAoaBool = false;
    }
  }

  Future<void> _handleClickRestore() async {
    windowManager.restore();
    windowManager.show();
  }

  // Future<void> hostChecker() async {
  //   if (!await canLaunch('http://localhost:8111')) {
  //     ScaffoldMessenger.of(context)
  //       ..removeCurrentSnackBar()
  //       ..showSnackBar(const SnackBar(
  //         content: BlinkText(
  //           'Unable to connect to game server.',
  //           endColor: Colors.red,
  //         ),
  //         duration: Duration(seconds: 10),
  //       ));
  //   }
  // }

  Future<void> startServer() async {
    int check = 0;
    Future.delayed(Duration(milliseconds: 800), () {
      HttpServer.bind(InternetAddress.anyIPv4, 55200).then((HttpServer server) {
        print('[+]WebSocket listening at -- ws://$ipAddress:55200');
        server.listen((HttpRequest request) {
          WebSocketTransformer.upgrade(request).then((WebSocket ws) {
            ws.listen(
              (data) {
                nonePost = false;
                headerColor = Colors.deepPurple;
                drawerIcon = Icons.settings;
                Map<String, dynamic> serverData = {
                  'vehicleName': vehicleName,
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
                  'chat1': chatMsgFirst,
                  'chatId1': chatIdFirst.value,
                  'chat2': chatMsgSecond,
                  'chatId2': chatIdSecond.value,
                  'chatMode1': chatModeFirst,
                  'chatMode2': chatModeSecond,
                  'chatSender1': chatSenderFirst,
                  'chatSender2': chatSenderSecond,
                  'chatEnemy1': chatEnemyFirst,
                  'chatEnemy2': chatEnemySecond,
                  'check': check++
                };
                var internalData = jsonDecode(data);
                if (internalData == null) {
                  nonePost = true;
                  headerColor = Colors.red;
                  drawerIcon = Icons.warning;
                  ws.close();
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar
                    ..showSnackBar(SnackBar(
                        content: Text('Abnormal connection request detected')));
                }
                phoneConnected.value = (internalData['WTbgA']);
                phoneState.value = (internalData['state']);
                streamState.value = internalData['startStream'];
                Timer(Duration(milliseconds: 300), () {
                  if (ws.readyState == WebSocket.open)
                    ws.add(json.encode(serverData));
                });
              },
              onDone: () {
                print('[+]Done :)');
                phoneConnected.value = false;
              },
              onError: (err) => print('[!]Error -- ${err.toString()}'),
              cancelOnError: false,
            );
          }, onError: (err) {
            nonePost = true;
            headerColor = Colors.red;
            drawerIcon = Icons.warning;
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar
              ..showSnackBar(SnackBar(
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
    // _prefs.then((SharedPreferences prefs) {
    //   phoneIP.value = (prefs.getString('phoneIP') ?? '');
    // });
    _prefs.then((SharedPreferences prefs) {
      lastId = (prefs.getInt('lastId') ?? 0);
    });
    _prefs.then((SharedPreferences prefs) {
      transparentFont = (prefs.getDouble('fontSize') ?? 40);
    });
    _prefs.then((SharedPreferences prefs) {
      isPullUpEnabled = (prefs.getBool('isPullUpEnabled') ?? true);
    });
    _prefs.then((SharedPreferences prefs) {
      _isOilNotifOn = (prefs.getBool('isOilNotifOn') ?? true);
    });
    _prefs.then((SharedPreferences prefs) {
      playStallWarning = (prefs.getBool('playStallWarning') ?? true);
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
      if (_textForGLoad.value != 200) {
        isUserGLoadNew = true;
      }
    });
  }

  Future<void> giveIps() async {
    final info = NetworkInfo();

    var wifiIP = await info.getWifiIP();
    ipAddress = wifiIP;
  }

  @override
  void initState() {
    super.initState();
    checkVersion();
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
    chatSettingsManager();
    const twoSec = Duration(milliseconds: 2000);
    Timer.periodic(twoSec, (Timer t) async {
      if (!mounted || isStopped) t.cancel();
      rpc.updatePresence(
        DiscordPresence(
          state: phoneConnected.value ? 'Using WTbgA - Mobile!' : 'Using WTbgA',
          details: phoneConnected.value
              ? 'Enjoying both desktop and mobile WTbgA!'
              : phoneConnected.value && phoneState.value == 'image'
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
      chatSettingsManager();
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
      averageIasForStall();
      // hostChecker();
    });
    windowManager.addListener(this);

    phoneState.addListener(() {
      if (phoneState.value == 'home') {
        sendScreen = false;
      }
    });
    phoneConnected.addListener(() async {
      if (phoneConnected.value) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(
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
          ..showSnackBar(SnackBar(
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
    _textForIasFlap.addListener(() {
      isUserIasFlapNew = true;
    });
    // msgDataNotifier.addListener(() {
    //   isDamageMsgNew = true;
    // });
    _textForIasGear.addListener(() {
      isUserIasGearNew = true;
    });
    _textForGLoad.addListener(() {
      isUserGLoadNew = true;
    });
    chatIdFirst.addListener(() {
      chatSettingsManager();
    });
    const redLineTimer = Duration(milliseconds: 1500);
    Timer.periodic(redLineTimer, (Timer t) async {
      if (!mounted || isStopped) t.cancel();
      if (!_isFullNotifOn) return;
      {
        userRedLineFlap();
        userRedLineGear();
        loadChecker();
        pullUpChecker();
      }
      _csvThing();
    });
    Future.delayed(const Duration(milliseconds: 250), () async {
      widget1Opacity = 1;
    });
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    rpc.clearPresence();
    TrayManager.instance.removeListener(this);
    windowManager.removeListener(this);
    idData.removeListener((vehicleStateCheck));
    _textForIasFlap.removeListener((userRedLineFlap));
    _textForIasGear.removeListener((userRedLineGear));
    _textForGLoad.removeListener((loadChecker));
    chatIdFirst.removeListener(() {});
    chatIdSecond.removeListener(() {});
    phoneConnected.removeListener(() {});
    isStopped = true;
  }

  Future<void> _csvThing() async {
    final csvString = File(csvPath).readAsStringSync();
    Future.delayed(const Duration(milliseconds: 250), () {
      critAoa =
          convertCsvFileToMap(csvString)[vehicleName.toString().toLowerCase()];
    });
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
  }

  Color headerColor = Colors.teal;
  IconData drawerIcon = Icons.settings;

  Widget drawerBuilder() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(color: Colors.black),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              curve: Curves.bounceIn,
              duration: Duration(seconds: 4),
              decoration: BoxDecoration(
                color: headerColor,
              ),
              child: Icon(
                drawerIcon,
                size: 100,
              ),
            ),
            Container(
                padding: EdgeInsets.only(left: 12),
                alignment: Alignment.topLeft,
                decoration: const BoxDecoration(color: Colors.black87),
                child: phoneConnected.value
                    ? BlinkText(
                        'PC IP: ${ipAddress.toString()}',
                        endColor: Colors.green,
                      )
                    : nonePost
                        ? BlinkText(
                            'PC IP: ${ipAddress.toString()}',
                            endColor: Colors.red,
                          )
                        : Text(
                            'PC IP: ${ipAddress.toString()}',
                            style: const TextStyle(
                                color: Colors.redAccent, fontSize: 20),
                          )),
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
                    prefs.setBool('isFullNotifOn', isFullNotifOn);
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
                    bool _playStallWarning =
                        (prefs.getBool('playStallWarning') ?? true);
                    _playStallWarning = !_playStallWarning;
                    setState(() {
                      playStallWarning = _playStallWarning;
                    });
                    prefs.setBool('playStallWarning', _playStallWarning);
                  },
                  label: playStallWarning
                      ? const Text(
                          'Play stall warning sound: On',
                          style: TextStyle(color: Colors.green),
                        )
                      : const Text(
                          'Play stall warning sound: Off',
                          style: TextStyle(color: Colors.red),
                        ),
                  icon: const Icon(MaterialCommunityIcons.shield_airplane)),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                  onPressed: () async {
                    final SharedPreferences prefs = await _prefs;
                    bool _isPullUpEnabled =
                        (prefs.getBool('isPullUpEnabled') ?? true);
                    _isPullUpEnabled = !_isPullUpEnabled;
                    setState(() {
                      isPullUpEnabled = _isPullUpEnabled;
                    });
                    prefs.setBool('isPullUpEnabled', _isPullUpEnabled);
                  },
                  label: isPullUpEnabled
                      ? const Text(
                          'Play dive warning sound: On',
                          style: TextStyle(color: Colors.green),
                        )
                      : const Text(
                          'Play dive warning sound: Off',
                          style: TextStyle(color: Colors.red),
                        ),
                  icon: const Icon(FontAwesome.plane)),
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
                    prefs.setBool('isEngineDeathNotifOn', isEngineDeathNotifOn);
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
                    prefs.setBool('isOilNotifOn', isOilNotifOn);
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
                    prefs.setBool('isWaterNotifOn', isWaterNotifOn);
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
                    prefs.setBool('isTrayEnabled', isTrayEnabled);
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
                label: const Text('More Info'),
                icon: const Icon(
                  Icons.info,
                  color: Colors.cyanAccent,
                ),
                onPressed: () async {
                  await launch(
                      'https://forum.warthunder.com/index.php?/topic/533554-war-thunder-background-assistant-wtbga/');
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
                  _textForIasFlap.value = (await Navigator.of(context)
                      .push(dialogBuilderIasFlap(context)))!;
                  int textForIasFlap = (prefs.getInt('textForIasFlap') ?? 2000);
                  setState(() {
                    textForIasFlap = _textForIasFlap.value;
                  });
                  prefs.setInt('textForIasFlap', textForIasFlap);
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
                  _textForIasGear.value = (await Navigator.of(context)
                      .push(dialogBuilderIasGear(context)))!;
                  int textForIasGear = (prefs.getInt('textForIasGear') ?? 2000);

                  setState(() {
                    textForIasGear = _textForIasGear.value;
                  });
                  prefs.setInt('textForIasGear', textForIasGear);
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
                    _textForGLoad.value = (await Navigator.of(context)
                        .push(dialogBuilderOverG(context)))!;
                    int textForGLoad = (prefs.getInt('textForGLoad') ?? 12);
                    setState(() {
                      textForGLoad = _textForGLoad.value;
                    });
                    prefs.setInt('textForGLoad', textForGLoad);
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
                  label: Text(
                    'In-game Overlay (Hold for font size)',
                  ),
                  onLongPress: () async {
                    showGeneralDialog(
                        context: context,
                        pageBuilder: (context, an, an2) {
                          return SliderClass(
                              defaultText: transparentFont,
                              callback: (double value) {
                                setState(() {
                                  transparentFont = value;
                                });
                              });
                        });
                  },
                  onPressed: () async {
                    await Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => TransparentPage(
                          flapLimit: _textForIasFlap.value,
                          gearLimit: _textForIasGear.value,
                          gLoad: _textForGLoad.value,
                          fontSize: transparentFont,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    MaterialCommunityIcons.window_open,
                    color: Colors.amber,
                  )),
            ),
            chatSenderFirst != null
                ? Container(
                    alignment: Alignment.topCenter,
                    decoration: const BoxDecoration(color: Colors.black87),
                    child: chatBuilder(
                        chatSenderSecond, chatMsgSecond, chatPrefixSecond),
                  )
                : Container(),
            chatSenderFirst != null
                ? Container(
                    alignment: Alignment.topCenter,
                    decoration: const BoxDecoration(color: Colors.black87),
                    child: chatBuilder(
                        chatSenderFirst, chatMsgFirst, chatPrefixFirst),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget? homeAppBar(BuildContext context) {
    return AppBar(
        actions: [
          phoneConnected.value
              ? RotationTransition(
                  turns: _controller,
                  child: IconButton(
                    onPressed: () async {
                      displayCapture();
                    },
                    icon: Icon(
                      Icons.wifi_rounded,
                      color: Colors.green,
                    ),
                    tooltip: 'Phone Connected = ${phoneConnected.value}',
                  ),
                )
              : IconButton(
                  onPressed: () {
                    displayCapture();
                  },
                  icon: Icon(
                    Icons.wifi_rounded,
                    color: Colors.red,
                  ),
                  tooltip: 'Toggle Stream Mode',
                ),
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
        title: vehicleName != 'NULL' && vehicleName != null
            ? Text("You're flying ${vehicleName}")
            : (altitude == 32 && minFuel == 0 && flap == 0)
                ? const Text("You're in Hangar...")
                : const Text('No vehicle data available / Not flying.'));
  }

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
  double? critAoa;
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

  String? vehicleName;
  String? msgData;
  String? chatMsgFirst;
  String? chatModeFirst;
  String? chatSenderFirst;
  String? chatSenderSecond;
  String? chatMsgSecond;
  String? chatModeSecond;
  String? chatPrefixFirst;
  String? chatPrefixSecond;
  String? imageData;
  String? ipAddress;
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
  String csvPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'fm_data_db.csv'
  ]);

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // ValueNotifier<String> phoneIP = ValueNotifier('');
  ValueNotifier<int?> chatIdSecond = ValueNotifier(null);
  ValueNotifier<int?> chatIdFirst = ValueNotifier(null);

  // ValueNotifier<String?> msgDataNotifier = ValueNotifier('2000');
  final ValueNotifier<int> _textForIasFlap = ValueNotifier(2000);
  final ValueNotifier<int> _textForIasGear = ValueNotifier(2000);
  final ValueNotifier<int> _textForGLoad = ValueNotifier(200);
  final ValueNotifier<bool> streamState = ValueNotifier(false);

  ValueNotifier<bool> phoneConnected = ValueNotifier(false);
  ValueNotifier<String?> phoneState = ValueNotifier('');
  bool isStopped = false;
  bool _isTrayEnabled = true;
  final bool _removeIconAfterRestored = true;
  final bool _showWindowBelowTrayIcon = false;
  bool? valid;
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
  bool sendScreen = false;
  bool playStallWarning = true;
  bool? chatEnemySecond;
  bool? chatEnemyFirst;
  bool critAoaBool = false;
  bool nonePost = false;
  bool isPullUpEnabled = true;
  double transparentFont = 30.0;
  Color? chatColorFirst;
  Color? chatColorSecond;
  Color borderColor = const Color(0xFF805306);
  Color textColor = Colors.white;
  final windowManager = WindowManager.instance;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: false, period: Duration(seconds: 1));

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
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
              ? homeAppBar(context)
              : null,
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
                                decoration: BoxDecoration(
                                    gradient: const LinearGradient(
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
                                        color: Colors.red
                                            .withOpacity(boxShadowOpacity),
                                        spreadRadius: 4,
                                        blurRadius: 7,
                                        offset: const Offset(0, 3),
                                      )
                                    ]),
                                alignment: Alignment.center,
                                child: RichText(
                                  text: TextSpan(children: [
                                    WidgetSpan(child: Icon(Icons.airplay)),
                                    TextSpan(
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40),
                                        text:
                                            '  Throttle= ${shot.data!.throttle1} %')
                                  ]),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    gradient: const LinearGradient(
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
                                        color: Colors.red
                                            .withOpacity(boxShadowOpacity),
                                        spreadRadius: 4,
                                        blurRadius: 7,
                                        offset: const Offset(0, 3),
                                      )
                                    ]),
                                child: RichText(
                                  text: TextSpan(children: [
                                    WidgetSpan(child: Icon(Icons.airplay)),
                                    TextSpan(
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40),
                                        text: '  IAS= ${shot.data!.ias} km/h')
                                  ]),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    gradient: const LinearGradient(
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
                                        color: Colors.red
                                            .withOpacity(boxShadowOpacity),
                                        spreadRadius: 4,
                                        blurRadius: 7,
                                        offset: const Offset(0, 3),
                                      )
                                    ]),
                                child: RichText(
                                  text: TextSpan(children: [
                                    WidgetSpan(child: Icon(Icons.airplay)),
                                    TextSpan(
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40),
                                        text:
                                            '  Altitude= ${shot.data!.altitude} m')
                                  ]),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    gradient: const LinearGradient(
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
                                        color: Colors.red
                                            .withOpacity(boxShadowOpacity),
                                        spreadRadius: 4,
                                        blurRadius: 7,
                                        offset: const Offset(0, 3),
                                      )
                                    ]),
                                child: RichText(
                                  text: TextSpan(children: [
                                    WidgetSpan(child: Icon(Icons.airplay)),
                                    TextSpan(
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40),
                                        text:
                                            '  Climb= ${shot.data!.climb} m/s')
                                  ]),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    gradient: const LinearGradient(
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
                                        color: Colors.red
                                            .withOpacity(boxShadowOpacity),
                                        spreadRadius: 4,
                                        blurRadius: 7,
                                        offset: const Offset(0, 3),
                                      )
                                    ]),
                                child: RichText(
                                  text: TextSpan(children: [
                                    WidgetSpan(child: Icon(Icons.airplay)),
                                    TextSpan(
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40),
                                        text:
                                            '  Fuel= ${fuel.toStringAsFixed(1)} %')
                                  ]),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    gradient: const LinearGradient(
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
                                        color: Colors.red
                                            .withOpacity(boxShadowOpacity),
                                        spreadRadius: 4,
                                        blurRadius: 7,
                                        offset: const Offset(0, 3),
                                      )
                                    ]),
                                child: RichText(
                                  text: TextSpan(children: [
                                    WidgetSpan(child: Icon(Icons.airplay)),
                                    TextSpan(
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40),
                                        text:
                                            '  Oil Temp= ${shot.data!.oilTemp1C}°c')
                                  ]),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    gradient: const LinearGradient(
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
                                        color: Colors.red
                                            .withOpacity(boxShadowOpacity),
                                        spreadRadius: 4,
                                        blurRadius: 7,
                                        offset: const Offset(0, 3),
                                      )
                                    ]),
                                child: RichText(
                                  text: TextSpan(children: [
                                    WidgetSpan(
                                      child: Icon(Icons.airplay),
                                    ),
                                    TextSpan(
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40),
                                        text:
                                            '  Water Temp= ${shot.data!.waterTemp1C}°c')
                                  ]),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else if (shot.hasError) {
                        // print(shot.error);
                        return Center(
                            child: BlinkText(
                          'ERROR: NO DATA',
                          endColor: Colors.red,
                        ));
                      } else {
                        return Center(
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
                      vehicleName = shot.data!.type;
                      if (shot.data!.mach == null) shot.data!.mach = -0;
                      return Flex(
                        direction: Axis.vertical,
                        children: [
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  gradient: const LinearGradient(
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
                                      color: Colors.red
                                          .withOpacity(boxShadowOpacity),
                                      spreadRadius: 4,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3),
                                    )
                                  ]),
                              child: RichText(
                                text: TextSpan(children: [
                                  WidgetSpan(
                                    child: Icon(Icons.airplay),
                                  ),
                                  TextSpan(
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 40),
                                      text:
                                          '  Compass= ${shot.data!.compass.toStringAsFixed(0)}°')
                                ]),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  gradient: const LinearGradient(
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
                                      color: Colors.red
                                          .withOpacity(boxShadowOpacity),
                                      spreadRadius: 4,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3),
                                    )
                                  ]),
                              child: RichText(
                                text: TextSpan(children: [
                                  WidgetSpan(
                                    child: Icon(Icons.airplay),
                                  ),
                                  TextSpan(
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 40),
                                      text: '  Mach= ${shot.data!.mach} M')
                                ]),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    if (shot.hasError) {
                      // print(shot.error);
                      return Center(
                          child: BlinkText(
                        'ERROR: NO DATA',
                        endColor: Colors.red,
                      ));
                    } else {
                      return Center(
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
    if (_isTrayEnabled) {
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

class SliderClass extends StatefulWidget {
  double defaultText;
  final DoubleCallBack callback;

  SliderClass({Key? key, required this.defaultText, required this.callback})
      : super(key: key);

  @override
  _SliderClassState createState() => _SliderClassState();
}

typedef DoubleCallBack(double value);

class _SliderClassState extends State<SliderClass> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> loadPrefs() async {
    prefs.then((SharedPreferences prefs) {
      widget.defaultText = (prefs.getDouble('fontSize') ?? 40);
    });
  }

  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Set font size'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: 100)),
          Center(
            child: Slider(
              min: 20,
              max: 80,
              divisions: 60,
              label: widget.defaultText.round().toString(),
              value: widget.defaultText,
              onChanged: (double value) async {
                widget.callback(value);
                widget.defaultText = value;
                setState(() {});
                final SharedPreferences _prefs = await prefs;

                double _defaultText = (_prefs.getDouble('fontSize') ?? 40);
                setState(() {
                  _defaultText = widget.defaultText;
                });
                _prefs.setDouble('fontSize', _defaultText);
              },
            ),
          ),
          Center(
              child: Text(
            'Example:',
            style: TextStyle(fontSize: widget.defaultText),
          ))
        ],
      ),
    );
  }
}
