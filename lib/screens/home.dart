import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:blinking_text/blinking_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libwinmedia/libwinmedia.dart';
import 'package:path/path.dart' as p;
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wtbgassistant/providers.dart';
import 'package:wtbgassistant/screens/widgets/game_map.dart';
import 'package:wtbgassistant/services/csv_class.dart';
import 'package:wtbgassistant/services/utility.dart';

import '../data_receivers/chat.dart';
import '../data_receivers/damage_event.dart';
import '../data_receivers/indicator_receiver.dart';
import '../data_receivers/state_receiver.dart';
import '../main.dart';
import '../services/extensions.dart';
import 'downloader.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends ConsumerState<Home>
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
      isDamageIDNew = false;
      player.play();
    }
    if (oilNotif.state &&
        oil != 15 &&
        isDamageIDNew &&
        msgData == 'Oil overheated') {
      isDamageIDNew = false;
      player.play();
    }
    if (engineOh.state &&
        oil != 15 &&
        isDamageIDNew &&
        msgData == 'Engine overheated') {
      isDamageIDNew = false;
      player.play();
    }
    if (waterNotif.state &&
        water != 15 &&
        isDamageIDNew &&
        msgData == 'Water overheated') {
      isDamageIDNew = false;
      player.play();
    }
    if (engineDeath.state &&
        oil != 15 &&
        isDamageIDNew &&
        msgData == 'Engine died: overheating') {
      isDamageIDNew = false;
      player.play();
    }
    if (engineDeath.state &&
        oil != 15 &&
        isDamageIDNew &&
        msgData == 'Engine died: propeller broken') {
      isDamageIDNew = false;
      player.play();
    }
    if (oil != 15 &&
        isDamageIDNew &&
        msgData == 'You are out of ammunition. Reloading is not possible.') {
      isDamageIDNew = false;
      player.play();
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

  bool critAoaChecker() {
    if (aoa == null) return false;
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
    var fullNotif = ref.read(fullNotifProvider.notifier);
    var oilNotif = ref.read(oilNotifProvider.notifier);
    var engineDeath = ref.read(engineDeathNotifProvider.notifier);
    var pullUpNotif = ref.read(pullUpNotifProvider.notifier);
    var waterNotif = ref.read(waterNotifProvider.notifier);
    var tray = ref.read(trayProvider.notifier);
    var stallNotif = ref.read(stallNotifProvider.notifier);
    lastId = (prefs.getInt('lastId') ?? 0);
    pullUpNotif.state = (prefs.getBool('isPullUpEnabled') ?? true);
    oilNotif.state = (prefs.getBool('isOilNotifOn') ?? true);
    stallNotif.state = (prefs.getBool('playStallWarning') ?? true);
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
    updateChat();

    const twoSec = Duration(milliseconds: 2000);
    Timer.periodic(twoSec, (Timer t) async {
      if (!mounted || isStopped) t.cancel();
      updateMsgId();
      flapChecker();
      updateChat();
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
      if (critAoaChecker()) {
        ref.read(rgbProvider.notifier).state = HexColor(Colors.purple).toHex();
      }
      // _csvThing();
    });
    Future.delayed(Duration.zero, () async {
      // Navigator.of(context)
      //     .pushReplacement(MaterialPageRoute(builder: (context) {
      //   return const MyCanvas();
      // }));
      csvNames = await File(namesPath).readAsString();

      Map<String, String> namesMap = convertNamesToMap(csvNames);

      fmData = await FmData.setObject(
          namesMap[ref.read(vehicleNameProvider.state).state] ?? '');
    });
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    TrayManager.instance.removeListener(this);
    windowManager.removeListener(this);
    idData.removeListener((vehicleStateCheck));
    chatIdFirst.removeListener(() {});
    chatIdSecond.removeListener(() {});

    isStopped = true;
  }

  startListeners() {
    ref.listen<String>(rgbProvider, (previous, next) async {
      if (previous != next && next != Colors.white.toHex() && openRGB != null) {
        Process.run(openRGB!.path, ['--mode', 'static', '--color', next],
            runInShell: true);
        await Future.delayed(const Duration(milliseconds: 200));
        Process.run(openRGB!.path, ['--mode', 'static', '--color', previous!],
            runInShell: true);
        await Future.delayed(const Duration(milliseconds: 200));

        Process.run(openRGB!.path, ['--mode', 'static', '--color', next],
            runInShell: true);
        await Future.delayed(const Duration(milliseconds: 200));

        Process.run(openRGB!.path, ['--mode', 'static', '--color', previous],
            runInShell: true);
        await Future.delayed(const Duration(milliseconds: 200));

        Process.run(openRGB!.path, ['--mode', 'static', '--color', next],
            runInShell: true);
        await Future.delayed(const Duration(milliseconds: 200));

        Process.run(openRGB!.path, ['--mode', 'static', '--color', previous],
            runInShell: true);
        ref.read(rgbProvider.notifier).state = Colors.white.toHex();
        await Future.delayed(const Duration(milliseconds: 200));
      }
    });
    ref.listen<String?>(vehicleNameProvider, (previous, next) async {
      Map<String, String> namesMap = convertNamesToMap(csvNames);
      fmData = await FmData.setObject(namesMap[next] ?? '');
      if (fmData != null) {
        ref.read(gearLimitProvider.notifier).state = fmData!.critGearSpd;
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

  Color headerColor = Colors.teal;
  IconData drawerIcon = FluentIcons.settings;

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
  OpenRGB? openRGB;
  @override
  Widget build(BuildContext context) {
    startListeners();
    return Stack(children: [
      NavigationView(
        appBar: NavigationAppBar(
          title: const Text(
            'War Thunder Background Assistant',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: false,
          actions: IconButton(
            icon: Image.asset('assets/OpenRGB.png'),
            onPressed: () async {
              final innerOpenRGB = await AppUtil.checkOpenRGb();
              setState(() {
                openRGB = innerOpenRGB;
              });
              if (innerOpenRGB.exists) {
                await Process.start(
                    innerOpenRGB.path, ['--server', '--server-port', '1200']);
                dio.get('http://localhost:1200');
              } else {
                if (!mounted) return;
                Navigator.pushReplacement(
                    context,
                    FluentPageRoute(
                        builder: (c) => const Downloader(isRGB: true)));
              }
            },
          ),
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
                                  child: !critAoaChecker()
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
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref.read(vehicleNameProvider.notifier).state = '';
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
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref.read(vehicleNameProvider.notifier).state =
                                'Vehicle Name not available';
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
            )
          ],
        ),
      ),
    ]);
  }
}
