import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:blinking_text/blinking_text.dart';
import 'package:firebase_dart/database.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openrgb/client/client.dart';
import 'package:openrgb/data/rgb_controller.dart';
import 'package:openrgb/helpers/extensions.dart';
import 'package:path/path.dart' as p;
import 'package:tray_manager/tray_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:win_toast/win_toast.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wtbgassistant/data/orgb_data_class.dart';
import 'package:wtbgassistant/screens/widgets/game_map.dart';
import 'package:wtbgassistant/screens/widgets/loading_widget.dart';
import 'package:wtbgassistant/screens/widgets/rgb_settings.dart';
import 'package:wtbgassistant/screens/widgets/settings.dart';
import 'package:wtbgassistant/services/csv_class.dart';
import 'package:wtbgassistant/services/utility.dart';

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
    with WindowListener, TrayListener, TickerProviderStateMixin, WidgetsBindingObserver {
  StreamSubscription? subscription;
  StreamSubscription? subscriptionForPresence;
  int times = 0;

  Future<void> userRedLineGear() async {
    if (!isInGame.value) return;

    if (!mounted) return;
    if (ias != null) {
      if (ias! >= ref.read(provider.gearLimitProvider.notifier).state && gear! > 30) {
        await audio.play(AssetSource('sounds/beep.wav'), volume: 0.22, mode: PlayerMode.lowLatency);
      }
    }
  }

  bool loadChecker() {
    if (!isInGame.value) return false;

    if (!mounted) return false;
    if (fmData != null) {
      double? maxLoad = (fmData!.critWingOverload2 / ((fmData!.emptyMass + fuelMass) * 9.81 / 2));
      if (load == null) return false;
      if ((load)! >= (maxLoad - (0.15 * maxLoad))) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  final isInGame = ValueNotifier<bool>(false);

  bool notInGame() {
    String name = windowName.toLowerCase();
    return (name.contains('loading') || name.contains('waiting')) || name == 'war thunder';
  }

  Future<void> vehicleStateCheck() async {
    if (!isInGame.value) return;
    var fullNotif = ref.read(provider.fullNotifProvider.notifier);
    var engineDeath = ref.read(provider.engineDeathNotifProvider.notifier);
    var oilNotif = ref.read(provider.oilNotifProvider.notifier);
    var waterNotif = ref.read(provider.waterNotifProvider.notifier);
    var engineOh = ref.read(provider.engineOHNotifProvider.notifier);
    if (!fullNotif.state) return;
    if (!run) return;
    if (!damages.hasValue) return;
    for (var damage in damages!) {
      if (engineDeath.state && oil != 15 && isDamageIDNew && damage.msg == 'Engine died: no fuel') {
        isDamageIDNew = false;
        tripleWarning();
      }
    }
    for (var damage in damages!) {
      if (engineDeath.state && oil != 15 && isDamageIDNew && damage.msg == 'Engine died: no fuel') {
        isDamageIDNew = false;
        tripleWarning();
      }
      if (engineOh.state && oil != 15 && isDamageIDNew && damage.msg == 'Engine overheated') {
        isDamageIDNew = false;
        var client = ref.read(provider.orgbClientProvider);
        tripleWarning();
        if (client.hasValue) {
          final controllersProvider = ref.watch(provider.orgbControllersProvider);
          await flashNTimes(client!, controllersProvider!, Modes.overHeat);
        }
      }
      if (oilNotif.state && oil != 15 && isDamageIDNew && damage.msg == 'Oil overheated') {
        isDamageIDNew = false;
        var client = ref.read(provider.orgbClientProvider);
        tripleWarning();
        if (client.hasValue) {
          final controllersProvider = ref.watch(provider.orgbControllersProvider);
          await flashNTimes(client!, controllersProvider!, Modes.overHeat);
        }
      }
      if (waterNotif.state && water != 15 && isDamageIDNew && damage.msg == 'Water overheated') {
        isDamageIDNew = false;

        var client = ref.read(provider.orgbClientProvider);
        tripleWarning();
        if (client.hasValue) {
          final controllersProvider = ref.watch(provider.orgbControllersProvider);
          await flashNTimes(client!, controllersProvider!, Modes.overHeat);
        }
      }

      if (engineDeath.state && oil != 15 && isDamageIDNew && damage.msg == 'Engine died: overheating') {
        isDamageIDNew = false;
        tripleWarning();
      }
      if (engineDeath.state && oil != 15 && isDamageIDNew && damage.msg == 'Engine died: propeller broken') {
        isDamageIDNew = false;
        tripleWarning();
      }
      if (oil != 15 && isDamageIDNew && damage.msg!.contains('set afire')) {
        List<String> split = damage.msg!.split('set afire');
        if (split[1].contains(prefs.getString('userName') ?? 'Unknown')) {
          isDamageIDNew = false;
          var client = ref.read(provider.orgbClientProvider);
          tripleWarning();
          if (client.hasValue) {
            final controllersProvider = ref.watch(provider.orgbControllersProvider);
            await flashNTimes(client!, controllersProvider!, Modes.overHeat);
          }
        }
      }
      if (oil != 15 && isDamageIDNew && damage.msg!.contains('shot down')) {
        List<String> split = damage.msg!.split('shot down');
        if (split[1].contains(prefs.getString('userName') ?? 'Unknown')) {
          isDamageIDNew = false;
          var client = ref.read(provider.orgbClientProvider);
          tripleWarning();
          if (client.hasValue) {
            final controllersProvider = ref.watch(provider.orgbControllersProvider);
            await flashNTimes(client!, controllersProvider!, Modes.overHeat);
          }
        }
      } else if (oil != 15 && isDamageIDNew && damage.msg!.contains('destroyed')) {
        List<String> split = damage.msg!.split('destroyed');
        if (split[1].contains(prefs.getString('userName') ?? 'Unknown')) {
          isDamageIDNew = false;
          var client = ref.read(provider.orgbClientProvider);
          tripleWarning();
          if (client.hasValue) {
            final controllersProvider = ref.watch(provider.orgbControllersProvider);
            await flashNTimes(client!, controllersProvider!, Modes.overHeat);
          }
        }
      }
    }
    run = false;
  }

  Future<void> flashNTimes(OpenRGBClient client, List<RGBController> data, Modes mode, {int times = 4}) async {
    if (prefs.getString('openrgb') != null) {
      OpenRGBSettings settings = ref.read(provider.rgbSettingProvider.notifier).state;

      if (mode == Modes.fire) {
        for (int i = 0; i < times; i++) {
          await settings.setAllFire(client, data);
          await Future.delayed(const Duration(milliseconds: 500));
          await OpenRGBSettings.setAllOff(client, data);
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
      if (mode == Modes.overHeat) {
        for (int i = 0; i < times; i++) {
          await settings.setAllOverHeat(client, data);
          await Future.delayed(const Duration(milliseconds: 500));
          await OpenRGBSettings.setAllOff(client, data);
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
    } else {
      OpenRGBSettings settings = OpenRGBSettings(
          overHeat: OverHeatSettings(color: const Color.fromRGBO(247, 73, 4, 1.0).toRGB()),
          fireSettings: FireSettings(color: const Color.fromARGB(255, 0, 0, 1).toRGB()));
      if (mode == Modes.fire) {
        await settings.setAllFire(client, data);
        await Future.delayed(const Duration(milliseconds: 500));
        await OpenRGBSettings.setAllOff(client, data);
        await Future.delayed(const Duration(milliseconds: 200));
        await settings.setAllFire(client, data);
        await Future.delayed(const Duration(milliseconds: 500));
        await OpenRGBSettings.setAllOff(client, data);
        await Future.delayed(const Duration(milliseconds: 200));
        await settings.setAllFire(client, data);
        await Future.delayed(const Duration(milliseconds: 500));
        await OpenRGBSettings.setAllOff(client, data);
        await Future.delayed(const Duration(milliseconds: 200));
      }
      if (mode == Modes.overHeat) {
        await settings.setAllOverHeat(client, data);
        await Future.delayed(const Duration(milliseconds: 500));
        await OpenRGBSettings.setAllOff(client, data);
        await Future.delayed(const Duration(milliseconds: 200));
        await settings.setAllOverHeat(client, data);
        await Future.delayed(const Duration(milliseconds: 500));
        await OpenRGBSettings.setAllOff(client, data);
        await Future.delayed(const Duration(milliseconds: 200));
        await settings.setAllOverHeat(client, data);
        await Future.delayed(const Duration(milliseconds: 500));
        await OpenRGBSettings.setAllOff(client, data);
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }

  int? emptyInt = 0;
  String? emptyString = 'No Data';
  bool? emptyBool;
  ValueNotifier<int?> idData = ValueNotifier<int?>(null);

  Future<void> updateMsgId() async {
    if (!isInGame.value) return;
    damages = (await Damage.getDamage()).reversed.take(4).toList();
    if (!mounted) return;
    if (damages.hasValue) {
      idData.value = damages!.isNotEmpty ? damages![damages!.length - 1].id : emptyInt;
    }
  }

  Future<void> flapChecker() async {
    if (!isInGame.value) return;
    if (!run) return;
    if (!damages.hasValue) return;
    for (var damage in damages!) {
      if (damage.msg == 'Asymmetric flap extension' && isDamageIDNew) {
        isDamageIDNew = false;
        await audio.play(AssetSource('sounds/beep.wav'), volume: 0.22);
      }
    }
  }

  bool critAoaChecker() {
    if (!isInGame.value) return false;
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

  Future<void> tripleWarning() async {
    if (!mounted) return;
    if (times == 0) {
      await audio.play(AssetSource('sounds/beep.wav'), volume: 0.22, mode: PlayerMode.lowLatency);
      times++;
    } else if (times == 1) {
      await audio.play(AssetSource('sounds/beep.wav'), volume: 0.22, mode: PlayerMode.lowLatency);
      times++;
    } else if (times == 2) {
      await audio.play(AssetSource('sounds/beep.wav'), volume: 0.22, mode: PlayerMode.lowLatency);
      times = 0;
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
      await PresenceService()
          .configureUserPresence((await deviceInfo.windowsInfo).computerName, File(versionPath).readAsStringSync());
      await Future.delayed(const Duration(seconds: 50));
      subscriptionForPresence = startListening();
    });
    const twoSec = Duration(milliseconds: 2000);
    Timer.periodic(twoSec, (Timer t) async {
      if (!mounted || isStopped) t.cancel();
      await updateMsgId();
      flapChecker();
    });
    const Duration averageTimer = Duration(milliseconds: 1200);
    Timer.periodic(averageTimer, (Timer t) async {
      if (!mounted || isStopped) t.cancel();

      // hostChecker();
    });
    idData.addListener(() async {
      if (lastId != idData.value) {
        isDamageIDNew = true;
        vehicleStateCheck();
      }
      run = true;
      lastId = (prefs.getInt('lastId') ?? 0);
      lastId = idData.value;
      prefs.setInt('lastId', lastId!);
    });
    AppUtil.getWindow().listen((stringValue) {
      windowName = stringValue ?? '';
      if (windowName != '') {
        if (isInGame.value != !notInGame()) {
          isInGame.value = !notInGame();
        }
      }
    });
    isInGame.addListener(() async {
      final client = ref.watch(provider.orgbClientProvider);
      final data = await client?.getAllControllers();
      if (isInGame.value) {
        if (client != null && data != null) {
          await OpenRGBSettings.setAllOff(client, data);
        }
      } else {
        if (client != null && data != null) {
          OpenRGBSettings settings = ref.read(provider.rgbSettingProvider);
          await OpenRGBSettings.setLoadingEffect(client, data, settings.loadingColor);
        }
      }
    });

    var fullNotif = ref.read(provider.fullNotifProvider);
    const redLineTimer = Duration(milliseconds: 1);
    Timer.periodic(redLineTimer, (Timer t) async {
      if (!mounted || isStopped) t.cancel();
      if (!fullNotif) return;
      userRedLineGear();
      checkCritAoa();
      if (loadChecker()) {
        await audio.play(AssetSource('sounds/beep.wav'), volume: 0.22);
      }
    });
    Future.delayed(Duration.zero, () async {
      csvNames = await File(namesPath).readAsString();

      Map<String, String> namesMap = convertNamesToMap(csvNames);
      fmData = await FmData.setObject(namesMap[ref.read(provider.vehicleNameProvider.state).state] ?? '');
      final fromDisk = await OpenRGBSettings.loadFromDisc();
      if (fromDisk != const OpenRGBSettings()) {
        ref.read(provider.rgbSettingProvider.notifier).state = fromDisk;
      }
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
          if (message.device == (await deviceInfo.windowsInfo).computerName || message.device == null) {
            var toast = await WinToast.instance()
                .showToast(type: ToastType.text04, title: message.title, subtitle: message.subtitle);
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
      } else if (data != null && data['operation'] != null && data['id'] != null && data['title'] == null) {
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
          ref.read(provider.gearLimitProvider.notifier).state = fmData!.critGearSpd;
        }
      }
    });
  }

  Future<void> checkCritAoa() async {
    if (!isInGame.value) return;
    if (fmData != null && vertical.notNull) {
      if (flap == null) return;
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

    for (final rows in LineSplitter.split(csvStringNames).skip(1).map((line) => line.split(';'))) {
      map[rows.first] = rows[1];
    }

    return map;
  }

  bool wasLoading = false;
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
  List<Damage>? damages;
  String csvNames = '';
  String namesPath =
      p.joinAll([p.dirname(Platform.resolvedExecutable), 'data/flutter_assets/assets', 'fm_names_db.csv']);

  ValueNotifier<int?> chatIdSecond = ValueNotifier(null);
  ValueNotifier<int?> chatIdFirst = ValueNotifier(null);

  bool isStopped = false;
  bool isUserIasFlapNew = false;
  bool isUserIasGearNew = false;
  bool isDamageIDNew = false;
  bool isDamageMsgNew = false;
  bool run = true;
  int fuelMass = 500;
  String windowName = '';
  int index = 0;
  Color textColor = Colors.white;
  final windowManager = WindowManager.instance;
  bool inHangar = false;
  late final stateStream = StateData.getState().asBroadcastStream();
  late Stream<IndicatorData?> indicatorStream = IndicatorData.getIndicator().asBroadcastStream();

  @override
  Widget build(BuildContext context) {
    startListeners();
    final theme = FluentTheme.of(context);
    final fireBaseVersion = ref.watch(provider.versionFBProvider);
    return NavigationView(
      appBar: NavigationAppBar(
          title: Row(
            children: [
              Text(
                'War Thunder background Assistant',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.accentColor.lighter),
              ),
              const SizedBox(
                width: 5,
              ),
              fireBaseVersion.when(data: (data) {
                bool isNew = false;
                if (int.parse(data.replaceAll('.', '')) >
                    int.parse(File(versionPath).readAsStringSync().replaceAll('.', ''))) {
                  isNew = true;
                }
                if (isNew) {
                  return HoverButton(
                    builder: (context, set) => Text(
                      '$data available',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.accentColor.lighter),
                    ),
                  );
                } else {
                  return Text(
                    'v$data',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.accentColor.lighter),
                  );
                }
              }, error: (e, st) {
                return const SizedBox();
              }, loading: () {
                return const SizedBox();
              }),
            ],
          ),
          automaticallyImplyLeading: false,
          actions: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (ref.watch(provider.orgbClientProvider).hasValue)
                IconButton(
                    icon: const Icon(
                      FluentIcons.test_add,
                      color: Color.fromRGBO(255, 222, 111, 1.0),
                    ),
                    onPressed: () async {
                      var client = ref.read(provider.orgbClientProvider);
                      if (client.hasValue) {
                        final data = ref.watch(provider.orgbControllersProvider);
                        if (data.hasValue) {
                          showSnackbar(context, const Snackbar(content: Text('Running tests')));
                          OpenRGBSettings settings = ref.read(provider.rgbSettingProvider.notifier).state;
                          await OpenRGBSettings.setDeathEffect(client!, data!);
                          await settings.setAllOverHeat(client, data);
                          await Future.delayed(const Duration(seconds: 1));
                          await settings.setAllFire(client, data);
                          await Future.delayed(const Duration(seconds: 1));
                          await OpenRGBSettings.setLoadingEffect(client, data, settings.loadingColor);
                          await Future.delayed(const Duration(seconds: 3));
                          await OpenRGBSettings.setAllOff(client, data);
                        }
                      }
                    }),
              IconButton(
                icon: Image.asset('assets/OpenRGB.png'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ContentDialog(
                        content: const Text(
                            'OpenRGB is a free software that allows WTbgA to control the RGB LED lights of your machine depending on in-game events'),
                        actions: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: const Text('Stop'),
                            onPressed: () async {
                              await ref.read(provider.orgbClientProvider)?.disconnect();
                              await Process.run('taskkill', ['/IM', 'OpenRGB.exe']);
                              ref.read(provider.orgbClientProvider.notifier).state = null;
                              if (!mounted) return;
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: const Text('Start'),
                            onPressed: () async {
                              String openRGBExe = await AppUtil.getOpenRGBExecutablePath(context);
                              await Process.start(openRGBExe, ['--server', '--noautoconnect'],
                                  workingDirectory: p.dirname(openRGBExe));
                              await showLoading(
                                  context: context,
                                  future: Future.delayed(const Duration(milliseconds: 400)),
                                  message: 'Starting...');
                              if (!mounted) return;
                              try {
                                ref.read(provider.orgbClientProvider.notifier).state = await showLoading(
                                    context: context, future: OpenRGBClient.connect(), message: 'Connecting...');
                                await showLoading(
                                    context: context,
                                    future: Future.delayed(const Duration(milliseconds: 600)),
                                    message: 'Receiving data...');
                                ref.read(provider.orgbControllersProvider.notifier).state =
                                    await ref.read(provider.orgbClientProvider.notifier).state!.getAllControllers();
                              } catch (e, st) {
                                showSnackbar(
                                    context,
                                    Snackbar(
                                      content: Text('Error: $e'),
                                      extended: true,
                                    ),
                                    duration: const Duration(seconds: 5));
                                await Future.delayed(const Duration(seconds: 5));
                                if (!mounted) return;
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ContentDialog(
                                      title: const Text('Error'),
                                      content: Text('$st'),
                                      actions: [
                                        TextButton(
                                          child: const Text('Ok'),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ],
                                    );
                                  },
                                  barrierDismissible: true,
                                );
                              }

                              if (!mounted) return;
                              Navigator.pop(context);
                              showSnackbar(
                                  context,
                                  const Snackbar(
                                    content: Text('OpenRGB connected'),
                                    extended: true,
                                  ));
                              setState(() {});
                            },
                          ),
                        ],
                      );
                    },
                    barrierDismissible: true,
                  );
                },
              ),
            ],
          )),
      pane: NavigationPane(
          selected: index,
          displayMode: PaneDisplayMode.auto,
          onChanged: (newIndex) {
            setState(() {
              index = newIndex;
            });
          },
          items: [
            PaneItem(icon: const Icon(FluentIcons.home), title: const Text('Home')),
            PaneItem(icon: const Icon(FluentIcons.nav2_d_map_view), title: const Text('Game Map')),
            PaneItem(icon: const Icon(FluentIcons.settings), title: const Text('Settings')),
            if (ref.watch(provider.orgbClientProvider).notNull)
              PaneItem(
                  icon: Icon(
                    FluentIcons.settings,
                    color: Colors.red,
                  ),
                  title: const Text('OpenRGB Settings')),
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
                        if ((shot.data!.altitude == 32 || shot.data!.altitude == 31) &&
                            shot.data!.gear == 100 &&
                            shot.data!.ias == 0) {
                          inHangar = true;
                        } else {
                          inHangar = false;
                        }
                        double fuel = shot.data!.fuel / shot.data!.maxFuel * 100;
                        if (inHangar) {
                          return Flex(
                            direction: Axis.vertical,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(left: 20),
                                  alignment: Alignment.center,
                                  child: RichText(
                                    text: const TextSpan(
                                        style:
                                            TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40),
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
                                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40),
                                        text: 'Throttle= ${shot.data!.throttle1} %')
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
                                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40),
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
                                  style:
                                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(left: 20),
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Climb= ${shot.data!.climb} m/s',
                                  style:
                                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40),
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
                                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40),
                                          endColor: Colors.red,
                                        )
                                      : Text(
                                          'Fuel= ${fuel.toStringAsFixed(1)} %',
                                          style: const TextStyle(
                                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40),
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
                                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40),
                                        text: 'Oil Temp= ${shot.data!.oilTemp1C}°c')
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
                                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40),
                                        text: 'Water Temp= ${shot.data!.waterTemp1C}°c')
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
                                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40),
                                      )
                                    : BlinkText(
                                        'AoA= ${shot.data!.aoa}°',
                                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 40),
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
                          style: const TextStyle(color: Colors.white, fontSize: 40),
                        ));
                      } else {
                        return const Center(
                            child: SizedBox(
                          height: 100,
                          width: 100,
                          child: ProgressRing(),
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
                          ref.read(provider.vehicleNameProvider.notifier).state = shot.data!.type;
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
                                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40),
                                        text: 'Compass= ${shot.data!.compass?.toStringAsFixed(0) ?? ''}°')
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
                                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40),
                                        text: 'Mach= ${shot.data!.mach!.toStringAsFixed(1)} M')
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
                          ref.read(provider.vehicleNameProvider.notifier).state = '';
                        });
                        log('Error: ${shot.error}');
                        return Center(
                          child: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: BlinkText(
                                'ERROR: NO DATA',
                                endColor: Colors.red,
                                style: const TextStyle(color: Colors.white, fontSize: 40),
                              )),
                        );
                      } else {
                        inHangar = true;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ref.read(provider.vehicleNameProvider.notifier).state = '';
                        });
                        return const Center(
                            child: SizedBox(
                          height: 100,
                          width: 100,
                          child: ProgressRing(),
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
          if (ref.watch(provider.orgbClientProvider).notNull) const RGBSettings(),
        ],
      ),
    );
  }
}
