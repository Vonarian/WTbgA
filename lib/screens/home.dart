import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:blinking_text/blinking_text.dart';
import 'package:firebase_dart/database.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:tray_manager/tray_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:win_toast/win_toast.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wtbgassistant/screens/widgets/game_map.dart';
import 'package:wtbgassistant/screens/widgets/settings.dart';
import 'package:wtbgassistant/services/csv_class.dart';

import '../data/data_class.dart';
import '../data/firebase.dart';
import '../data_receivers/damage_event.dart';
import '../data_receivers/indicator_receiver.dart';
import '../data_receivers/state_receiver.dart';
import '../main.dart';
import '../services/extensions.dart';
import '../services/presence.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends ConsumerState<Home>
    with
        WindowListener,
        TrayListener,
        TickerProviderStateMixin,
        WidgetsBindingObserver {
  StreamSubscription? subscription;
  StreamSubscription? subscriptionForPresence;
  Future<void> userRedLineGear() async {
    if (!mounted) return;
    if (ias != null) {
      if (ias! >= ref.read(provider.gearLimitProvider.notifier).state &&
          gear! > 0) {
        await audio.play(AssetSource('sounds/beep.wav'), volume: 0.35);
      }
      if (ias! >= ref.read(provider.gearLimitProvider.notifier).state &&
          gear! > 0) {
        await audio.play(AssetSource('sounds/beep.wav'), volume: 0.35);
      }
    }
  }

  Future<void> pullUpChecker() async {
    if (!mounted) return;
    if (vertical.notNull && ias.notNull) {
      if (vertical! <= -65 && ias! >= 600) {
        await audio.play(AssetSource('sounds/beep.wav'), volume: 0.35);
      }
    }
  }

  bool loadChecker() {
    if (!mounted) return false;
    if (fmData != null) {
      double? maxLoad = (fmData!.critWingOverload2 /
          ((fmData!.emptyMass + fuelMass) * 9.81 / 2));
      if ((load)! >= (maxLoad - (0.15 * maxLoad))) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<void> vehicleStateCheck() async {
    var fullNotif = ref.read(provider.fullNotifProvider.notifier);
    var engineDeath = ref.read(provider.engineDeathNotifProvider.notifier);
    var oilNotif = ref.read(provider.oilNotifProvider.notifier);
    var waterNotif = ref.read(provider.waterNotifProvider.notifier);
    var engineOh = ref.read(provider.engineOHNotifProvider.notifier);
    if (!fullNotif.state) return;
    if (!run) return;
    if (engineDeath.state &&
        oil != 15 &&
        isDamageIDNew &&
        msgData == 'Engine died: no fuel' &&
        isDamageMsgNew) {
      isDamageIDNew = false;
      await audio.play(AssetSource('sounds/beep.wav'), volume: 0.35);
    }
    if (oilNotif.state &&
        oil != 15 &&
        isDamageIDNew &&
        msgData == 'Oil overheated') {
      isDamageIDNew = false;
      await audio.play(AssetSource('sounds/beep.wav'), volume: 0.35);
    }
    if (engineOh.state &&
        oil != 15 &&
        isDamageIDNew &&
        msgData == 'Engine overheated') {
      isDamageIDNew = false;
      await audio.play(AssetSource('sounds/beep.wav'), volume: 0.35);
    }
    if (waterNotif.state &&
        water != 15 &&
        isDamageIDNew &&
        msgData == 'Water overheated') {
      isDamageIDNew = false;
      await audio.play(AssetSource('sounds/beep.wav'), volume: 0.35);
    }
    if (engineDeath.state &&
        oil != 15 &&
        isDamageIDNew &&
        msgData == 'Engine died: overheating') {
      isDamageIDNew = false;
      await audio.play(AssetSource('sounds/beep.wav'), volume: 0.35);
    }
    if (engineDeath.state &&
        oil != 15 &&
        isDamageIDNew &&
        msgData == 'Engine died: propeller broken') {
      isDamageIDNew = false;
      await audio.play(AssetSource('sounds/beep.wav'), volume: 0.35);
    }
    if (oil != 15 &&
        isDamageIDNew &&
        msgData == 'You are out of ammunition. Reloading is not possible.') {
      isDamageIDNew = false;
      await audio.play(AssetSource('sounds/beep.wav'), volume: 0.35);
    }

    run = false;
  }

  int? emptyInt = 0;
  String? emptyString = 'No Data';
  bool? emptyBool;
  ValueNotifier<int?> idData = ValueNotifier<int?>(null);

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

  Future<void> flapChecker() async {
    if (!run) return;
    if (msgData == 'Asymmetric flap extension' && isDamageIDNew) {
      isDamageIDNew = false;
      await audio.play(AssetSource('sounds/beep.wav'), volume: 0.35);
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

  bool critAoaChecker() {
    if (aoa == null || gear == null || vertical == null || flap == null) {
      return false;
    }
    if (gear! > 0) {
      return false;
    }
    if (vertical! >= 10 && flap! <= 10 && aoa! >= critAoa) {
      return true;
    } else if (vertical! <= -10 && flap! <= 10 && aoa! <= critAoa) {
      return true;
    } else if (vertical! <= -10 && flap! >= 10 && aoa! <= critAoa) {
      return true;
    } else if (vertical! >= 10 && flap! >= 10 && aoa! >= critAoa) {
      return true;
    } else {
      return false;
    }
  }

  void receiveDiskValues() {
    var fullNotif = ref.read(provider.fullNotifProvider.notifier);
    var oilNotif = ref.read(provider.oilNotifProvider.notifier);
    var engineDeath = ref.read(provider.engineDeathNotifProvider.notifier);
    var waterNotif = ref.read(provider.waterNotifProvider.notifier);
    var tray = ref.read(provider.trayProvider.notifier);
    lastId = (prefs.getInt('lastId') ?? 0);
    oilNotif.state = (prefs.getBool('isOilNotifOn') ?? true);
    tray.state = (prefs.getBool('isTrayEnabled') ?? true);
    waterNotif.state = (prefs.getBool('isWaterNotifOn') ?? true);
    engineDeath.state = (prefs.getBool('isEngineDeathNotifOn') ?? true);
    fullNotif.state = (prefs.getBool('isFullNotifOn') ?? true);
  }

  @override
  void initState() {
    super.initState();
    receiveDiskValues();
    TrayManager.instance.addListener(this);
    windowManager.addListener(this);
    updateMsgId();
    WidgetsBinding.instance.addObserver(this);

    Future.delayed(Duration.zero, () async {
      await PresenceService().configureUserPresence(
          (await deviceInfo.windowsInfo).computerName,
          File(versionPath).readAsStringSync());
      await Future.delayed(const Duration(seconds: 3));
      subscriptionForPresence = startListening();
    });
    const twoSec = Duration(milliseconds: 2000);
    Timer.periodic(twoSec, (Timer t) async {
      if (!mounted || isStopped) t.cancel();
      updateMsgId();
      flapChecker();
    });
    const Duration averageTimer = Duration(milliseconds: 1200);
    Timer.periodic(averageTimer, (Timer t) async {
      if (!mounted || isStopped) t.cancel();
      averageIasForStall();

      // hostChecker();
    });
    windowManager.addListener(this);

    idData.addListener(() async {
      if (lastId != idData.value) {
        isDamageIDNew = true;
      }
      lastId = (prefs.getInt('lastId') ?? 0);
      lastId = idData.value;
      prefs.setInt('lastId', lastId!);
      vehicleStateCheck();

      run = true;
    });
    var fullNotif = ref.read(provider.fullNotifProvider.notifier);
    const redLineTimer = Duration(milliseconds: 120);
    Timer.periodic(redLineTimer, (Timer t) async {
      if (!mounted || isStopped) t.cancel();
      if (!fullNotif.state) return;
      userRedLineGear();
      pullUpChecker();
      checkCritAoa();
      if (loadChecker()) {
        await audio.play(AssetSource('sounds/beep.wav'), volume: 0.35);
      }
      // _csvThing();
    });
    Future.delayed(Duration.zero, () async {
      csvNames = await File(namesPath).readAsString();

      Map<String, String> namesMap = convertNamesToMap(csvNames);

      fmData = await FmData.setObject(
          namesMap[ref.read(provider.vehicleNameProvider.state).state] ?? '');
    });
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    TrayManager.instance.removeListener(this);
    windowManager.removeListener(this);
    idData.removeListener((vehicleStateCheck));
    isStopped = true;
    WidgetsBinding.instance.removeObserver(this);
    subscription!.cancel();
    audio.release();
    audio.dispose();
  }

  StreamSubscription? startListening() {
    FirebaseDatabase db = FirebaseDatabase(app: app, databaseURL: dataBaseUrl);
    db.goOnline();
    return db.reference().onValue.listen((event) async {
      final data = event.snapshot.value;
      if (data != null &&
          data['title'] != null &&
          data['subtitle'] != null &&
          data['id'] != null &&
          data['title'] != '' &&
          data['subtitle'] != '') {
        Message message = Message.fromMap(data);
        if (prefs.getInt('id') != message.id) {
          if (message.device == (await deviceInfo.windowsInfo).computerName ||
              message.device == null) {
            var toast = await WinToast.instance().showToast(
                type: ToastType.text04,
                title: message.title,
                subtitle: message.subtitle);
            toast?.eventStream.listen((event) async {
              if (event is ActivatedEvent) {
                if (message.url != null) {
                  await launchUrl(Uri.parse(message.url!));
                }
              }
            });
            if (message.operation != null) {
              switch (message.operation) {
                case 'getUserName':
                  if (!mounted) return;
                  await Message.getUserName(context, data);
                  break;
              }
            }
            await prefs.setInt('id', message.id);
          }
        }
      } else if (data != null &&
          data['operation'] != null &&
          data['id'] != null &&
          data['title'] == null) {
        switch (data['operation']) {
          case 'getUserName':
            await Message.getUserName(context, data);
            break;
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      PresenceService().disconnect();
      subscriptionForPresence?.cancel();
    }
    if (state == AppLifecycleState.resumed) {
      PresenceService().connect();
      subscriptionForPresence?.resume();
    }
  }

  int number = 0;
  Future<void> startListeners() async {
    ref.listen<String?>(provider.vehicleNameProvider, (previous, next) async {
      if (next.notNull && next != '') {
        Map<String, String> namesMap = convertNamesToMap(csvNames);
        fmData = await FmData.setObject(namesMap[next] ?? '');
        if (fmData != null) {
          ref.read(provider.gearLimitProvider.notifier).state =
              fmData!.critGearSpd;
        }
      }
    });
  }

  Future<void> checkCritAoa() async {
    if (fmData != null && vertical.notNull) {
      if (flap! <= 10 && !vertical!.isNegative) {
        critAoa = fmData!.critAoa1;
      }
      if (flap! > 10 && !vertical!.isNegative) {
        critAoa = fmData!.critAoa1;
      }
      if (flap! > 10 && vertical!.isNegative) {
        critAoa = fmData!.critAoa1;
      }
      if (flap! <= 10 && vertical!.isNegative) {
        critAoa = fmData!.critAoa1;
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

  int? gear;
  double? aoa;
  double critAoa = 10000;
  double? load;
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
  String path = p.dirname(Platform.resolvedExecutable);
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

  ValueNotifier<int?> chatIdSecond = ValueNotifier(null);
  ValueNotifier<int?> chatIdFirst = ValueNotifier(null);

  bool isStopped = false;
  bool isUserIasFlapNew = false;
  bool isUserIasGearNew = false;
  bool isDamageIDNew = false;
  bool isDamageMsgNew = false;
  bool run = true;
  int fuelMass = 500;

  int index = 0;
  Color textColor = Colors.white;
  final windowManager = WindowManager.instance;
  bool inHangar = false;
  late final stateStream = StateData.getState().asBroadcastStream();
  late Stream<IndicatorData?> indicatorStream =
      IndicatorData.getIndicator().asBroadcastStream();
  @override
  Widget build(BuildContext context) {
    startListeners();
    return Stack(children: [
      NavigationView(
        appBar: const NavigationAppBar(
          title: Text(
            'War Thunder Background Assistant',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: false,
        ),
        pane: NavigationPane(
            selected: index,
            displayMode: PaneDisplayMode.auto,
            onChanged: (newIndex) {
              setState(() {
                index = newIndex;
              });
            },
            items: [
              PaneItem(
                  icon: const Icon(FluentIcons.home),
                  title: const Text('Home')),
              PaneItem(
                  icon: const Icon(FluentIcons.nav2_d_map_view),
                  title: const Text('Game Map')),
              PaneItem(
                  icon: const Icon(FluentIcons.settings),
                  title: const Text('Settings')),
            ]),
        content: NavigationBody(
          index: index,
          children: [
            ScaffoldPage(
                content: Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                  child: StreamBuilder<StateData?>(
                      stream: stateStream,
                      builder: (context, AsyncSnapshot<StateData?> shot) {
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
                                  child: critAoaChecker()
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
                          return Center(
                              child: BlinkText(
                            'ERROR: NO DATA',
                            endColor: Colors.red,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 40),
                          ));
                        } else {
                          return Center(
                              child: SizedBox(
                            height: 100,
                            width: 100,
                            child: ProgressRing(
                              backgroundColor: Colors.red,
                            ),
                          ));
                        }
                      }),
                ),
                Expanded(
                  child: StreamBuilder<IndicatorData?>(
                      stream: indicatorStream,
                      builder: (context, AsyncSnapshot<IndicatorData?> shot) {
                        if (shot.hasData) {
                          inHangar = false;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref
                                .read(provider.vehicleNameProvider.notifier)
                                .state = shot.data!.type;
                            vertical = shot.data!.vertical;
                          });

                          if (shot.data!.mach == null) shot.data!.mach = 0;
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
                                              'Compass= ${shot.data!.compass?.toStringAsFixed(0) ?? ''}°')
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
                          inHangar = true;

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref
                                .read(provider.vehicleNameProvider.notifier)
                                .state = '';
                          });
                          log('Error: ${shot.error}');
                          return Center(
                            child: Container(
                                padding: const EdgeInsets.all(8.0),
                                child: BlinkText(
                                  'ERROR: NO DATA',
                                  endColor: Colors.red,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 40),
                                )),
                          );
                        } else {
                          inHangar = true;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref
                                .read(provider.vehicleNameProvider.notifier)
                                .state = '';
                          });
                          return Center(
                              child: SizedBox(
                            height: 100,
                            width: 100,
                            child: ProgressRing(
                              backgroundColor: Colors.red,
                            ),
                          ));
                        }
                      }),
                )
              ],
            )),
            InteractiveViewer(
              child: GameMap(
                inHangar: inHangar,
              ),
            ),
            const Settings(),
          ],
        ),
      ),
    ]);
  }
}
