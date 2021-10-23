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
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:libwinmedia/libwinmedia.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

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

  // static Route<String> dialogBuilderIP(BuildContext context) {
  //   TextEditingController userInputIP = TextEditingController();
  //   return DialogRoute(
  //       context: context,
  //       builder: (BuildContext context) => AlertDialog(
  //             content: TextField(
  //               onChanged: (value) {},
  //               controller: userInputIP,
  //               decoration: const InputDecoration(hintText: '192.168.X.Y'),
  //             ),
  //             title:
  //                 const Text('Red line notifier (Enter red line gear speed). '),
  //             actions: [
  //               ElevatedButton(
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                   child: const Text('Cancel')),
  //               ElevatedButton(
  //                   onPressed: () {
  //                     ScaffoldMessenger.of(context)
  //                       ..removeCurrentSnackBar()
  //                       ..showSnackBar(SnackBar(
  //                           content: Text('Phone IP address has been update')));
  //                     Navigator.of(context).pop(userInputIP.text);
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
    if (!mounted) return;
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
    if (isUserGLoadNew && load != null && load! >= _textForGLoad.value) {
      overGPlayer.play();
    }
  }

  Future<void> vehicleStateCheck() async {
    await Damage.getDamage();
    if (_isOilNotifOn &&
        oil != 15 &&
        _isFullNotifOn &&
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
      service?.stream.listen((event) {
        if (event is ToastActivated) {
          windowManager.show();
        }
      });
      isDamageIDNew = false;
      player.play();
    }
    if (_isOilNotifOn &&
        oil != 15 &&
        _isFullNotifOn &&
        isDamageIDNew &&
        msgData == 'Oil overheated') {
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
        oil != 15 &&
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
        water != 15 &&
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
        oil != 15 &&
        _isFullNotifOn &&
        isDamageIDNew &&
        msgData == 'Engine died: overheating') {
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
        oil != 15 &&
        _isFullNotifOn &&
        isDamageIDNew &&
        msgData == 'Engine died: propeller broken') {
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
    if (oil != 15 &&
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

  // Future<void> updatePhone() async {
  //   Timer.periodic(const Duration(milliseconds: 4000), (_) async {
  //     PhoneData dataForPhone = await PhoneData.getPhoneData(phoneIP.value);
  //     phoneConnected.value = dataForPhone.active!;
  //     phoneState.value = dataForPhone.state;
  //   });
  // }

  Future<void> updateStateIndicator() async {
    ToolDataState state = await ToolDataState.getState();
    ToolDataIndicator indicator = await ToolDataIndicator.getIndicator();
    if (!mounted) return;
    maxFuel = state.maxFuel;
    minFuel = state.minFuel;
    ias = state.ias;
    oil = state.oil;
    water = state.water;
    altitude = state.height;
    flap = state.flap;
    gear = state.gear;
    valid = state.valid;
    load = state.load;
    aoa = state.aoa;
    climb = state.climb;
    throttle = indicator.throttle;
    mach = indicator.mach;
    compass = indicator.compass;
    engine = indicator.engine;
    flap1 = indicator.flap1;
    flap2 = indicator.flap2;
    vertical = indicator.vertical;
    vehicleName = indicator.name;
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

  Future<void> critAoaChecker() async {
    if (aoa == null || critAoa == null || gear == null) {
      return;
    }

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

  @override
  void dispose() {
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
    phoneIP.removeListener(() {});
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
    Future.delayed(Duration(milliseconds: 800), () {
      HttpServer.bind(InternetAddress.anyIPv4, 55200).then((HttpServer server) {
        print('[+]WebSocket listening at -- ws://$ipAddress:55200');
        server.listen((HttpRequest request) {
          WebSocketTransformer.upgrade(request).then((WebSocket ws) {
            ws.listen(
              (data) {
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
                };
                var internalData = jsonDecode(data);
                phoneConnected.value = (internalData['WTbgA']);
                phoneState.value = (internalData['state']);
                Timer(Duration(seconds: 1), () {
                  if (ws.readyState == WebSocket.open)
                    // checking connection state helps to avoid unprecedented errors
                    ws.add(json.encode(serverData));
                });
              },
              onDone: () {
                ws.addError('Error');
                print('[+]Done :)');
                phoneConnected.value = false;
              },
              onError: (err) => print('[!]Error -- ${err.toString()}'),
              cancelOnError: false,
            );
          }, onError: (err) => print('[!]Error -- ${err.toString()}'));
        }, onError: (err) => print('[!]Error -- ${err.toString()}'));
      }, onError: (err) => print('[!]Error -- ${err.toString()}'));
    });
    // Future.delayed(Duration(milliseconds: 800), () {
    //   HttpServer.bind(InternetAddress.anyIPv4, 30000).then((server) {
    //     server.listen((HttpRequest request) async {
    //       imageData = await getFileAsBase64String('$path/output.mkv');
    //       Map<String, dynamic> serverData = {
    //         'image': imageData,
    //       };
    //       request.response.write(jsonEncode(serverData));
    //       request.response.close();
    //     });
    //   });
    // });
    //

    // WebSocket.connect('ws://192.168.43.8:55200').then((WebSocket ws) {
    //   // our websocket server runs on ws://localhost:8000
    //   if (ws.readyState == WebSocket.open) {
    //     // as soon as websocket is connected and ready for use, we can start talking to other end
    //     ws.add(
    //         "Received Data"); // this is the JSON data format to be transmitted
    //     ws.listen(
    //       // gives a StreamSubscription
    //       (data) {
    //         data = Map<String, dynamic>.from(json.decode(data));
    //         print(
    //             '\t\t -- ${data}'); // listen for incoming data and show when it arrives
    //         Timer(Duration(seconds: 1), () {
    //           if (ws.readyState ==
    //               WebSocket
    //                   .open) // checking whether connection is open or not, is required before writing anything on socket
    //             ws.add("Received data");
    //         });
    //       },
    //       onDone: () => print('[+]Done :)'),
    //       onError: (err) => print('[!]Error -- ${err.toString()}'),
    //       cancelOnError: false,
    //     );
    //   } else
    //     print('[!]Connection Denied');
    //   // in case, if serer is not running now
    // }, onError: (err) => print('[!]Error -- ${err.toString()}'));
  }

  void receiveDiskValues() {
    _prefs.then((SharedPreferences prefs) {
      phoneIP.value = (prefs.getString('phoneIP') ?? '');
    });
    _prefs.then((SharedPreferences prefs) {
      lastId = (prefs.getInt('lastId') ?? 0);
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

    giveIps();
    startServer();
    final _url = 'http://localhost:8111';
    updateStateIndicator();
    receiveDiskValues();
    // updatePhone();
    keyRegister();
    TrayManager.instance.addListener(this);
    windowManager.addListener(this);
    updateMsgId();
    updateChat();
    chatSettingsManager();
    super.initState();
    const twoSec = Duration(milliseconds: 2000);
    // Timer.periodic(Duration(milliseconds: 4000), (timer) async {
    //   await updatePhone();
    // });
    Timer.periodic(twoSec, (Timer t) async {
      if (!await canLaunch(_url)) return;
      rpc.updatePresence(
        DiscordPresence(
          state: phoneConnected.value ? 'Using WTbgA - Mobile!' : 'Using WTbgA',
          details: phoneConnected.value
              ? 'Enjoying both desktop and mobile WTbgA!'
              : 'Enjoying WTbgA!',
          startTimeStamp: dateTimeNow,
          largeImageKey: 'largelogo',
          largeImageText: 'War Thunder Background Assistance',
          // smallImageKey: 'small_image',
          // smallImageText: 'This text describes the small image.',
        ),
      );
      giveIps();
      updateMsgId();
      flapChecker();
      updateChat();
      chatSettingsManager();
      critAoaChecker();
    });
    const oneSec = Duration(milliseconds: 200);
    Timer.periodic(oneSec, (Timer t) async {
      updateStateIndicator();
      if (!mounted) return;
      setState(() {});
    });
    const averageTimer = Duration(milliseconds: 2000);
    Timer.periodic(averageTimer, (Timer t) async {
      if (!await canLaunch(_url)) return;
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
            type: ToastType.imageAndText02,
            title: '⚠Connection detected!',
            subtitle: 'WTbgA Mobile connection detected',
            image: File(warningLogo));
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
            type: ToastType.imageAndText02,
            title: '⚠Connection ended!',
            subtitle: 'WTbgA Mobile connection ended',
            image: File(warningLogo));
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
      chatSettingsManager();
    });
    const redLineTimer = Duration(milliseconds: 1500);
    Timer.periodic(redLineTimer, (Timer t) async {
      if (!await canLaunch(_url)) return;
      userRedLineFlap();
      userRedLineGear();
      loadChecker();
      pullUpChecker();
      _csvThing();
    });
    Future.delayed(const Duration(milliseconds: 250), () {
      widget1Opacity = 1;
    });
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
    List<MenuItem> menuItems = [
      MenuItem(
        key: 'exit-app',
        title: 'Exit',
      ),
      MenuItem(key: 'show-app', title: 'Show')
    ];
    await TrayManager.instance.setContextMenu(menuItems);
  }

  void _trayUnInit() async {
    await TrayManager.instance.destroy();
  }

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

    HotKeyManager.instance
        .register(HotKey(KeyCode.backspace, modifiers: [KeyModifier.alt]),
            keyDownHandler: (_) {
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
  }

  Widget fuelIndicator() {
    if (minFuel != null) {
      fuelPercent = (minFuel! / maxFuel!) * 100;
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
        child: minFuel != null && fuelPercent! >= 15.00
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
            : minFuel != null &&
                    fuelPercent! < 15.00 &&
                    (altitude != 32 && minFuel != 0)
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
        child: water == null || water == 15
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
                  'Water Temp = ${water!} degrees  ',
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
          label: altitude != null
              ? Text(
                  'Altitude: ${altitude} meters ',
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
                  (vertical != null &&
                          ias != null &&
                          climb != null &&
                          (ias! < 250 &&
                              climb != null &&
                              climb! < 60 &&
                              vertical! >= -135 &&
                              vertical! <= -50) ||
                      (ias != null &&
                              ias! < 180 &&
                              climb != null &&
                              climb! < 10) &&
                          ias != 0 &&
                          altitude! > 250)
              ? BlinkText(
                  'Absolute Climb rate = ${climb} m/s (Possible stall!)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 2,
                      color: textColor,
                      fontWeight: FontWeight.bold),
                  endColor: Colors.red,
                )
              : climb != null && climb != 0.0
                  ? Text(
                      'Absolute Climb rate = ${climb} m/s',
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
        child: ias == null || ias == 0
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
            : mach != null && mach! >= 1 && ias != null
                ? TextButton.icon(
                    icon: const Icon(Icons.speed),
                    onPressed: () {
                      showIas = !showIas;
                    },
                    label: Text(
                      'IAS = ${ias!} km/h (Above Mach) ',
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
                      'IAS = ${ias!} km/h ',
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
        child: compass == '0' || compass == null
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
                  'Compass = ${compass?.toStringAsFixed(0)} degrees ',
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
                        engine != 'nul' &&
                        engine != null
                    ? BlinkText(
                        'Engine Temp= ${(engine!.toStringAsFixed(0))} degrees  ',
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
                    : engine != null
                        ? Text(
                            'Engine Temp= ${(engine!.toStringAsFixed(0))} degrees  ',
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
                  ? throttle != null && throttle != 'nul'
                      ? Text(
                          'Throttle= ${(throttle! * 100).toStringAsFixed(0)}%  ',
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
                  : throttle != null && throttle != 'nul'
                      ? Text(
                          'Throttle= ${((throttle)! * 100).toStringAsFixed(0)}%  ',
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
              label: (oil != null && oil != 15) &&
                      _isFullNotifOn &&
                      msgData == 'Oil overheated' &&
                      run
                  ? BlinkText(
                      'Oil Temp= ${oil} degrees  ',
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
                  : oil != null && oil != 15
                      ? Text('Oil Temp= ${oil} degrees  ',
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

  Color headerColor = Colors.deepPurple;
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
                child: !phoneConnected.value
                    ? Text(
                        'PC IP: ${ipAddress.toString()}',
                        style: const TextStyle(color: Colors.redAccent),
                      )
                    : BlinkText(
                        'PC IP: ${ipAddress.toString()}',
                        endColor: Colors.green,
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
            // Container(
            //   alignment: Alignment.topLeft,
            //   decoration: const BoxDecoration(color: Colors.black87),
            //   child: TextButton.icon(
            //     label: const Text('Go to transparent page'),
            //     icon: const Icon(
            //       Icons.info,
            //       color: Colors.cyanAccent,
            //     ),
            //     onPressed: () {
            //       Navigator.pushReplacementNamed(context, '/transparent');
            //     },
            //   ),
            // ),
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

  PreferredSizeWidget? homeAppBar(BuildContext context) {
    return AppBar(
        actions: [
          // IconButton(
          //     onPressed: () {
          //       channel.sink.add('Hello!');
          //     },
          //     icon: Icon(Icons.add)),
          phoneConnected.value
              ? RotationTransition(
                  turns: _controller,
                  child: IconButton(
                    onPressed: () async {
                      displayCapture();

                      // if (phoneState.value == 'image') {
                      //   print(phoneState.value);
                      //   sendScreen = !sendScreen;
                      // } else {
                      //   ScaffoldMessenger.of(context)
                      //     ..removeCurrentSnackBar()
                      //     ..showSnackBar(SnackBar(
                      //         content: BlinkText(
                      //       'Phone is not in image mode',
                      //       endColor: Colors.red,
                      //       style: TextStyle(color: Colors.cyan),
                      //     )));
                      // }
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
                    // ScaffoldMessenger.of(context)
                    //   ..removeCurrentSnackBar()
                    //   ..showSnackBar(SnackBar(
                    //       content: BlinkText(
                    //     'Phone is not in image mode',
                    //     endColor: Colors.red,
                    //     style: TextStyle(color: Colors.cyan),
                    //   )));
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
    await launch(shotPath);

    // var parser = ArgParser();
    // parser.addOption('files', abbr: 'f');
    // parser.addCommand('dshow');
    // parser.addOption('input', abbr: 'i');
    // parser.addCommand('video');
    // parser.addCommand('output.mkv');
    // var results = parser.parse([
    //   '-f',
    //   'dshow',
    //   '-i',
    //   'video=screen-capture-recorder',
    //   '$path/output.mkv'
    // ]);
    // print(results.arguments);
    // var test = await Process.run(shotPath, results.arguments);
    // print(test.stderr);
    // await Process.run(shotPath, []).catchError((error, stackTrace) async {
    //   print(error);
    //   var a = await (Process.run(shotPath, []));
    //   return a;
    // });
  }

  Color? chatColorFirst;
  Color? chatColorSecond;
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
  int counter = 0;
  int? lastId;
  int? firstSpeed;
  int? secondSpeed;
  int? ias;
  int? flap;
  double? flap1, flap2, vertical;
  int? altitude;
  double? load, throttle;
  int? oil;
  int? water;
  double? mach;
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
  String path = p.dirname(Platform.resolvedExecutable);
  String shotPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'del.bat'
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
  ValueNotifier<String> phoneIP = ValueNotifier('');
  ValueNotifier<int?> chatIdSecond = ValueNotifier(null);
  ValueNotifier<int?> chatIdFirst = ValueNotifier(null);
  ValueNotifier<String?> msgDataNotifier = ValueNotifier('2000');
  final ValueNotifier<int> _textForIasFlap = ValueNotifier(2000);
  final ValueNotifier<int> _textForIasGear = ValueNotifier(2000);
  final ValueNotifier<int> _textForGLoad = ValueNotifier(200);
  bool _isTrayEnabled = true;
  final bool _removeIconAfterRestored = true;
  final bool _showWindowBelowTrayIcon = false;
  ValueNotifier<bool> phoneConnected = ValueNotifier(false);
  ValueNotifier<String?> phoneState = ValueNotifier('');
  String? imageData;
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
  bool showIas = true;
  bool showAlt = true;
  bool showCompass = true;
  bool showEngineTemp = true;
  bool showOilTemp = true;
  bool showWaterTemp = true;
  bool showThrottle = true;
  bool showClimb = true;
  bool showFuel = true;
  bool sendScreen = false;
  bool playStallWarning = true;
  bool? chatEnemySecond;
  bool? chatEnemyFirst;
  bool critAoaBool = false;
  bool nonePost = false;

  Color borderColor = const Color(0xFF805306);
  Color textColor = Colors.white;
  dynamic ipAddress;
  final windowManager = WindowManager.instance;
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: false);
  int i = 0;
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
          body: AnimatedOpacity(
              duration: const Duration(seconds: 3),
              opacity: widget1Opacity,
              child: MediaQuery.of(context).size.height >= 235 &&
                      (valid == true && valid != null)
                  ? homeWidgetColumn()
                  : MediaQuery.of(context).size.height < 235 &&
                          (valid == true && valid != null)
                      ? homeWidgetRow()
                      : homeWidgetNoData())),
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
      case 'exit-app':
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
