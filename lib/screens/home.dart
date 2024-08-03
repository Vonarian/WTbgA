import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_dart/database.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:openrgb/client/client.dart';
import 'package:openrgb/data/rgb_controller.dart';
import 'package:openrgb/helpers/extensions.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import '../data_receivers/damage_event.dart';
import '../data_receivers/indicator_receiver.dart';
import '../data_receivers/state_receiver.dart';
import '../main.dart';
import '../models/app_settings.dart';
import '../models/data_class.dart';
import '../models/fm/fm_csv.dart';
import '../models/orgb_data_class.dart';
import '../models/pullup_data.dart';
import '../services/extensions.dart';
import '../services/presence.dart';
import '../services/utility.dart';
import 'settings.dart';
import 'widgets/chat.dart';
import 'widgets/game_map.dart';
import 'widgets/loading_widget.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends ConsumerState<Home> with WidgetsBindingObserver {
  StreamSubscription? subscriptionForPresence;
  StreamSubscription? subscriptionForIndicators;
  StreamSubscription? subscriptionForState;
  int times = 0;

  Future<void> userRedLineGear() async {
    if (!ref.read(provider.inMatchProvider)) return;

    if (!context.mounted) return;
    if (ias != null) {
      if (ias! >= ref.read(provider.gearLimitProvider) && gear! > 20) {
        await audio.play(AssetSource('sounds/beep.wav'),
            volume: 0.22, mode: PlayerMode.lowLatency);
      }
    }
  }

  bool loadChecker() {
    if (!ref.read(provider.inMatchProvider)) return false;

    if (!mounted) return false;
    if (fmData != null) {
      final double maxLoad = (!fmData!.isSweptWing
          ? fmData!.critWingOverload.positive
          : -fmData!.critWingOverload.positive /
              ((fmData!.emptyMass + fuelMass) * 9.81 / 2));
      if (load == null) return false;
      if ((load)! >= (maxLoad - (0.09 * maxLoad))) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<void> vehicleStateCheck() async {
    if (!ref.read(provider.inMatchProvider)) return;
    if (!context.mounted) return;
    final appSettings = ref.read(provider.appSettingsProvider);
    final rgbSettings = ref.read(provider.rgbSettingProvider);
    final inMatch = ref.read(provider.inMatchProvider);
    final client = ref.read(provider.orgbClientProvider);
    if (!appSettings.fullNotif) return;
    if (damage == defaultDamage) return;
    if (appSettings.engineWarning.enabled &&
        inMatch &&
        damage.msg == 'Engine died: no fuel') {
      tripleWarning(AppSettingsEnum.engineSetting);
    }
    if (appSettings.overHeatWarning.enabled &&
        inMatch &&
        damage.msg == 'Engine overheated') {
      tripleWarning(AppSettingsEnum.overHeatSetting);
      if (client.hasValue) {
        final controllersProvider = ref.read(provider.orgbControllersProvider);
        await flashNTimes(
            client!, controllersProvider, Modes.overHeat, rgbSettings);
      }
    }
    if (appSettings.overHeatWarning.enabled &&
        inMatch &&
        damage.msg == 'Oil overheated') {
      tripleWarning(AppSettingsEnum.overHeatSetting);
      if (client.hasValue) {
        final controllersProvider = ref.read(provider.orgbControllersProvider);
        await flashNTimes(
            client!, controllersProvider, Modes.overHeat, rgbSettings);
      }
    }
    if (appSettings.overHeatWarning.enabled &&
        inMatch &&
        damage.msg == 'Water overheated') {
      tripleWarning(AppSettingsEnum.overHeatSetting);
      if (client.hasValue) {
        final controllersProvider = ref.read(provider.orgbControllersProvider);
        await flashNTimes(
            client!, controllersProvider, Modes.overHeat, rgbSettings);
      }
    }
    if (appSettings.engineWarning.enabled &&
        inMatch &&
        damage.msg == 'Engine died: overheating') {
      tripleWarning(AppSettingsEnum.engineSetting);
    }
    if (appSettings.engineWarning.enabled &&
        inMatch &&
        damage.msg == 'Engine died: propeller broken') {
      tripleWarning(AppSettingsEnum.engineSetting);
    }
    if (inMatch && damage.msg.contains('set afire')) {
      final List<String> split = damage.msg.split('set afire');
      if (split[1].contains(prefs.getString('userName') ?? 'Unknown')) {
        tripleWarning(AppSettingsEnum.defaultSetting);
        if (client.hasValue) {
          final controllersProvider =
              ref.read(provider.orgbControllersProvider);
          await flashNTimes(
              client!, controllersProvider, Modes.overHeat, rgbSettings);
        }
      }
    } else if (inMatch && damage.msg.contains('shot down')) {
      final List<String> split = damage.msg.split('shot down');
      if (split[1].contains(prefs.getString('userName') ?? 'Unknown')) {
        tripleWarning(AppSettingsEnum.defaultSetting);
        if (client.hasValue) {
          final data = ref.read(provider.orgbControllersProvider);
          await OpenRGBSettings.setDeathEffect(client!, data, [255, 255]);
        }
      }
    } else if (inMatch && damage.msg.contains('destroyed')) {
      final List<String> split = damage.msg.split('destroyed');
      if (split[1].contains(prefs.getString('userName') ?? 'Unknown')) {
        tripleWarning(AppSettingsEnum.defaultSetting);
        if (client.hasValue) {
          final data = ref.read(provider.orgbControllersProvider);
          await OpenRGBSettings.setDeathEffect(client!, data, [255, 255]);
        }
      }
    }
  }

  Future<void> flashNTimes(OpenRGBClient client, List<RGBController> data,
      Modes mode, OpenRGBSettings settings) async {
    if (mode == Modes.fire) {
      for (int i = 0; i < settings.flashTimes; i++) {
        await settings.setAllFire(client, data);
        await Future.delayed(
            Duration(milliseconds: settings.delayBetweenFlashes));
        await OpenRGBSettings.setAllOff(client, data);
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
    if (mode == Modes.overHeat) {
      for (int i = 0; i < settings.flashTimes; i++) {
        await settings.setAllOverHeat(client, data);
        await Future.delayed(
            Duration(milliseconds: settings.delayBetweenFlashes));
        await OpenRGBSettings.setAllOff(client, data);
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }

  final ValueNotifier<int> idData = ValueNotifier<int>(0);
  final defaultDamage = const Damage(id: 0, msg: '');

  Future<void> updateMsgId() async {
    if (!ref.read(provider.inMatchProvider)) return;
    final value = await Damage.getDamages((idData.value));
    if (damage != value && damage != defaultDamage) {
      damage = value;
    }
    idData.value = damage.id;
  }

  Future<void> flapChecker() async {
    if (!ref.read(provider.inMatchProvider)) return;
    if (damage == defaultDamage) return;
    if (damage.msg == 'Asymmetric flap extension') {
      await audio.play(AssetSource('sounds/beep.wav'), volume: 0.22);
    }
  }

  bool critAoaChecker() {
    if (!ref.read(provider.inMatchProvider)) return false;
    if (aoa == null || gear == null || vertical == null || flap == null) {
      return false;
    }
    if (gear! > 0) return false;

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

  Future<void> tripleWarning(AppSettingsEnum appEnum) async {
    if (!context.mounted) return;
    final appSetting = ref.read(provider.appSettingsProvider);
    if (appEnum == AppSettingsEnum.engineSetting) {
      if (times == 0) {
        await audio.play(DeviceFileSource(appSetting.engineWarning.path),
            volume: appSetting.engineWarning.volume / 100,
            mode: PlayerMode.lowLatency);
        times++;
      } else if (times == 1) {
        await audio.play(DeviceFileSource(appSetting.engineWarning.path),
            volume: appSetting.engineWarning.volume / 100,
            mode: PlayerMode.lowLatency);
        times++;
      } else if (times == 2) {
        await audio.play(DeviceFileSource(appSetting.engineWarning.path),
            volume: appSetting.engineWarning.volume / 100,
            mode: PlayerMode.lowLatency);
        times = 0;
      }
    }
    if (appEnum == AppSettingsEnum.overHeatSetting) {
      if (times == 0) {
        await audio.play(DeviceFileSource(appSetting.overHeatWarning.path),
            volume: appSetting.overHeatWarning.volume / 100,
            mode: PlayerMode.lowLatency);
        times++;
      } else if (times == 1) {
        await audio.play(DeviceFileSource(appSetting.overHeatWarning.path),
            volume: appSetting.overHeatWarning.volume / 100,
            mode: PlayerMode.lowLatency);
        times++;
      } else if (times == 2) {
        await audio.play(DeviceFileSource(appSetting.overHeatWarning.path),
            volume: appSetting.overHeatWarning.volume / 100,
            mode: PlayerMode.lowLatency);
        times = 0;
      }
    }
    if (appEnum == AppSettingsEnum.overGSetting) {
      if (times == 0) {
        await audio.play(DeviceFileSource(appSetting.overGWarning.path),
            volume: appSetting.overGWarning.volume / 100,
            mode: PlayerMode.lowLatency);
        times++;
      } else if (times == 1) {
        await audio.play(DeviceFileSource(appSetting.overGWarning.path),
            volume: appSetting.overGWarning.volume / 100,
            mode: PlayerMode.lowLatency);
        times++;
      } else if (times == 2) {
        await audio.play(DeviceFileSource(appSetting.overGWarning.path),
            volume: appSetting.overGWarning.volume / 100,
            mode: PlayerMode.lowLatency);
        times = 0;
      }
    }
  }

  Future<void> receiveDiskValues() async {
    await ref.read(provider.appSettingsProvider.notifier).load();
  }

  Future<void> pullUp() async {
    if (!ref.read(provider.inMatchProvider) ||
        !ref.read(provider.appSettingsProvider).pullUpSetting.enabled) return;
    if (aoa == null ||
        gear == null ||
        vertical == null ||
        ias == null ||
        altitude == null) {
      return;
    }
    if (climb.isNegative && (vertical! * -1) <= -15) {
      await PullUpData.checkAndPlayWarning(
          altitude!, climb.toDouble(), ref.read(provider.appSettingsProvider));
    }
    return;
  }

  @override
  void initState() {
    super.initState();

    updateMsgId();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await receiveDiskValues();
      final fromDisk = await OpenRGBSettings.loadFromDisc();
      if (!context.mounted) return;

      ref.read(provider.rgbSettingProvider.notifier).state =
          fromDisk ?? const OpenRGBSettings();
      if (ref.read(provider.rgbSettingProvider).autoStart) {
        if (!mounted) return;
        final exePath = await AppUtil.getOpenRGBExecutablePath(context, false);
        await Process.run(exePath, ['--server', '--noautoconnect']);
        ref.read(provider.orgbClientProvider.notifier).state =
            await OpenRGBClient.connect();
        if (ref.read(provider.orgbClientProvider.notifier).state != null) {
          ref.read(provider.orgbControllersProvider.notifier).state =
              await ref.read(provider.orgbClientProvider)!.getAllControllers();
        }
      }
    });

    subscriptionForIndicators = indicatorStream.listen((event) {
      if (event == null) return;
      if (ref.read(provider.vehicleNameProvider) != event.type) {
        ref.read(provider.vehicleNameProvider.notifier).state = event.type;
      }
      vertical = event.vertical;
    });
    subscriptionForState = stateStream.listen((event) {
      if (event == null) return;
      ias = event.ias;
      gear = event.gear;
      flap = event.flaps;
      altitude = event.altitude;
      oil = event.oilTemp1C;
      water = event.waterTemp1C;
      aoa = event.aoa;
      load = event.load;
      fuelMass = event.fuel;
      climb = event.climb.toInt();
    });
    Future.delayed(Duration.zero, () async {
      if (secrets.firebaseInvalid) return;
      await PresenceService().configureUserPresence(
          (await deviceInfo.windowsInfo).computerName,
          File(AppUtil.versionPath).readAsStringSync());
      await Future.delayed(const Duration(seconds: 50));
      if (!mounted) return;
      subscriptionForPresence = startListening(context);
    });
    const dur = Duration(milliseconds: 800);
    Timer.periodic(dur, (Timer t) async {
      if (!mounted || isStopped) t.cancel();
      await updateMsgId();

      if (index != 0) {
        if (subscriptionForIndicators != null &&
            subscriptionForIndicators!.isPaused) {
          subscriptionForIndicators!.resume();
          if (subscriptionForState != null && subscriptionForState!.isPaused) {
            subscriptionForState!.resume();
          }
        }
      } else {
        if (subscriptionForIndicators != null &&
            !subscriptionForIndicators!.isPaused) {
          subscriptionForIndicators!.pause();
          if (subscriptionForState != null && !subscriptionForState!.isPaused) {
            subscriptionForState!.pause();
          }
        }
      }
    });
    idData.addListener(() async {
      if (lastId != idData.value) {
        vehicleStateCheck();
        flapChecker();
      }
      lastId = idData.value;
    });
    var appSettings = ref.read(provider.appSettingsProvider);
    const redLineTimer = Duration(milliseconds: 200);
    Timer.periodic(redLineTimer, (Timer t) async {
      if (!mounted || isStopped) t.cancel();
      if (!appSettings.fullNotif) return;
      userRedLineGear();
      pullUp();
      if (loadChecker()) {
        final settings = ref.read(provider.appSettingsProvider).overGWarning;
        await audio.play(DeviceFileSource(settings.path),
            volume: settings.volume / 100, mode: PlayerMode.lowLatency);
      }
    });
    Future.delayed(Duration.zero, () async {
      final csvNames = await File(namesPath).readAsString();

      if (namesMap.isEmpty) {
        namesMap = convertNamesToMap(csvNames);
      }
      if (ref.read(provider.vehicleNameProvider) != null) {
        fmData = await FmData.getFlightModel(
            namesMap[ref.read(provider.vehicleNameProvider)!]);
      }
    });
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    idData.removeListener((vehicleStateCheck));
    hotKeyManager.unregisterAll();
    isStopped = true;
    WidgetsBinding.instance.removeObserver(this);
    subscriptionForPresence!.cancel();
    subscriptionForState!.cancel();
    subscriptionForIndicators!.cancel();
    audio.dispose();
    audio1.dispose();
    audio2.dispose();
  }

  StreamSubscription? startListening(BuildContext context) {
    if (secrets.firebaseInvalid) return null;
    FirebaseDatabase db = FirebaseDatabase(
        app: app, databaseURL: secrets.firebaseData?.databaseURL);
    db.goOnline();
    return db.reference().onValue.listen((event) async {
      final data = event.snapshot.value;
      final bool valid = data != null &&
          data['title'] != null &&
          data['subtitle'] != null &&
          data['id'] != null &&
          data['title'] != '' &&
          data['subtitle'] != '';
      if (valid) {
        Message message = Message.fromMap(data);
        if (prefs.getInt('id') != message.id) {
          if (message.device == (await deviceInfo.windowsInfo).computerName ||
              message.device == null) {
            final localNotification = LocalNotification(
              title: message.title,
              body: message.subtitle,
            );
            localNotification.onClick = () async {
              if (message.url != null) {
                await launchUrl(Uri.parse(message.url!));
              }
            };
            localNotification.show();
            if (message.operation != null) {
              switch (message.operation) {
                case 'getUserName':
                  if (!context.mounted) return;
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
    if (secrets.firebaseInvalid) return;
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
      if (next.notNull && next != '' && namesMap.isNotEmpty) {
        fmData = await FmData.getFlightModel(namesMap[next]);
        if (fmData != null) {
          ref.read(provider.gearLimitProvider.notifier).state =
              fmData!.critGearSpd;
        }
      }
    });
    ref.listen<bool>(provider.inMatchProvider, (previous, next) async {
      if (previous != next) {
        if (next) {
          final client = ref.watch(provider.orgbClientProvider);
          final data = await client?.getAllControllers();
          OpenRGBSettings settings = ref.read(provider.rgbSettingProvider);
          if (data != null) {
            await OpenRGBSettings.setJoinBattleEffect(
                client!, data, settings.loadingColor);
            await OpenRGBSettings.setAllOff(client, data);
          }
        } else {
          final client = ref.watch(provider.orgbClientProvider);
          final data = await client?.getAllControllers();
          OpenRGBSettings settings = ref.read(provider.rgbSettingProvider);
          if (client != null && data != null) {
            await OpenRGBSettings.setLoadingEffect(
                client, data, settings.loadingColor);
          }
        }
      }
    });
  }

  Map<String, String> namesMap = {};

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
  Damage damage = const Damage(
    id: 0,
    msg: '',
  );
  String namesPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'fm/'
        'fm_names_db.csv'
  ]);

  ValueNotifier<int?> chatIdSecond = ValueNotifier(null);
  ValueNotifier<int?> chatIdFirst = ValueNotifier(null);
  bool isStopped = false;
  bool isUserIasFlapNew = false;
  bool isUserIasGearNew = false;
  bool isDamageMsgNew = false;
  int fuelMass = 500;
  int index = 0;
  int climb = 0;
  late final stateStream = StateData.getState().asBroadcastStream();
  late final Stream<IndicatorData?> indicatorStream =
      IndicatorData.getIndicator().asBroadcastStream();

  @override
  Widget build(BuildContext context) {
    startListeners();
    final theme = FluentTheme.of(context);
    final fireBaseVersion =
        ref.watch(provider.versionFBProvider(secrets.firebaseValid));
    final developerMessage = ref.watch(provider.developerMessageProvider);
    return NavigationView(
      appBar: NavigationAppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      Text(
                        'War Thunder background Assistant',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.accentColor.lighter),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  if (secrets.firebaseValid)
                    fireBaseVersion.when(data: (data) {
                      bool isNew = false;
                      if (data.hasValue &&
                          int.parse(data!.replaceAll('.', '')) >
                              int.parse(appVersion.replaceAll('.', ''))) {
                        isNew = true;
                      }
                      if (isNew) {
                        return HoverButton(
                          builder: (context, set) => Text(
                            '$data available',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.accentColor.lighter),
                          ),
                        );
                      } else {
                        return Text(
                          'v$data',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.accentColor.lighter),
                        );
                      }
                    }, error: (e, st) {
                      return const SizedBox();
                    }, loading: () {
                      return const SizedBox();
                    }),
                ],
              ),
              if (secrets.firebaseValid)
                developerMessage.when(data: (data) {
                  if (data != null) {
                    return Text(
                      'Developer\'s message: $data',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    );
                  } else {
                    return const SizedBox();
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
                      if (client != null) {
                        final data =
                            ref.watch(provider.orgbControllersProvider);
                        if (data.isNotEmpty) {
                          displayInfoBar(context,
                              builder: (context, close) => const InfoBar(
                                    title: Text('Running Tests'),
                                  ),
                              duration: const Duration(seconds: 5));
                          OpenRGBSettings settings = ref
                              .read(provider.rgbSettingProvider.notifier)
                              .state;
                          await OpenRGBSettings.setDeathEffect(
                              client, data, [255, 255]);
                          await settings.setAllOverHeat(client, data);
                          await Future.delayed(const Duration(seconds: 1));
                          await settings.setAllFire(client, data);
                          await Future.delayed(const Duration(seconds: 1));
                          await OpenRGBSettings.setLoadingEffect(
                              client, data, settings.loadingColor);
                          await Future.delayed(const Duration(seconds: 3));
                          await OpenRGBSettings.setJoinBattleEffect(
                              client, data, settings.loadingColor,
                              times: 6);
                        } else {
                          displayInfoBar(context,
                              builder: (context, close) => const InfoBar(
                                    severity: InfoBarSeverity.error,
                                    title: Text('Unable to connect'),
                                    content:
                                        Text('No data found, please try again'),
                                  ),
                              duration: const Duration(seconds: 5));
                        }
                      }
                    }),
              IconButton(
                icon: Image.asset(
                  'assets/OpenRGB.png',
                  height: 38,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(builder: (context, setState) {
                        return ContentDialog(
                          content: const Text(
                              'OpenRGB is a free software that allows WTbgA to control the RGB LED lights of your machine depending on in-game events'),
                          actions: [
                            HyperlinkButton(
                              child: const Text('Cancel'),
                              onPressed: () => Navigator.pop(context),
                            ),
                            HyperlinkButton(
                              child: const Text('Stop'),
                              onPressed: () async {
                                await ref
                                    .read(provider.orgbClientProvider)
                                    ?.disconnect();
                                await Process.run(
                                    'taskkill', ['/IM', 'OpenRGB.exe']);
                                ref
                                    .read(provider.orgbClientProvider.notifier)
                                    .state = null;
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                            HyperlinkButton(
                              child: Text(
                                  'Auto start: ${ref.watch(provider.rgbSettingProvider).autoStart ? 'On' : 'Off'}'),
                              onPressed: () async {
                                ref
                                        .read(provider.rgbSettingProvider.notifier)
                                        .state =
                                    ref
                                        .read(provider.rgbSettingProvider)
                                        .copyWith(
                                            autoStart: !ref
                                                .read(
                                                    provider.rgbSettingProvider)
                                                .autoStart);
                                setState(() {});
                                await ref
                                    .read(provider.rgbSettingProvider.notifier)
                                    .state
                                    .save();
                              },
                            ),
                            HyperlinkButton(
                              child: const Text('Start'),
                              onPressed: () async {
                                String openRGBExe =
                                    await AppUtil.getOpenRGBExecutablePath(
                                        context, true);
                                await Process.start(
                                    openRGBExe, ['--server', '--noautoconnect'],
                                    workingDirectory: p.dirname(openRGBExe));
                                if (!context.mounted) return;
                                await showLoading(
                                    context: context,
                                    future: Future.delayed(
                                        const Duration(milliseconds: 400)),
                                    message: 'Starting...');
                                if (!context.mounted) return;
                                try {
                                  ref
                                          .read(provider
                                              .orgbClientProvider.notifier)
                                          .state =
                                      await showLoading(
                                          context: context,
                                          future: OpenRGBClient.connect(),
                                          message: 'Connecting...');
                                  ref
                                          .read(provider
                                              .orgbControllersProvider.notifier)
                                          .state =
                                      await ref
                                          .read(provider
                                              .orgbClientProvider.notifier)
                                          .state!
                                          .getAllControllers();
                                  if (!context.mounted) return;

                                  await showLoading(
                                      context: context,
                                      future: Future.delayed(
                                          const Duration(milliseconds: 600)),
                                      message: 'Receiving data...');
                                } catch (e, st) {
                                  if (!context.mounted) return;
                                  displayInfoBar(context,
                                      builder: (context, close) => InfoBar(
                                            title: const Text('Error'),
                                            content: Text(e.toString()),
                                          ),
                                      duration: const Duration(seconds: 5));
                                  await Future.delayed(
                                      const Duration(seconds: 5));
                                  if (!context.mounted) return;
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return ContentDialog(
                                        title: const Text('Error'),
                                        content: Text('$st'),
                                        actions: [
                                          HyperlinkButton(
                                            child: const Text('Ok'),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                        ],
                                      );
                                    },
                                    barrierDismissible: true,
                                  );
                                }
                                if (!context.mounted) return;
                                Navigator.pop(context);
                                displayInfoBar(context,
                                    builder: (context, close) => const InfoBar(
                                          title: Text('Connected!'),
                                          content: Text(
                                              'Connection to OpenRGB server succeeded'),
                                        ));
                                setState(() {});
                              },
                            ),
                          ],
                        );
                      });
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
            PaneItem(
              icon: const Icon(FluentIcons.home),
              title: const Text('Home'),
              body: ScaffoldPage(
                  content: Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                    child: StreamBuilder<StateData?>(
                        stream: stateStream,
                        builder: (context, AsyncSnapshot<StateData?> shot) {
                          if (shot.hasData) {
                            if (!ref.watch(provider.inMatchProvider)) {
                              return Flex(
                                direction: Axis.vertical,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 20),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'Not In Match',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            final data = shot.data!;
                            ias = data.ias;
                            gear = data.gear;
                            flap = data.flaps;
                            altitude = data.altitude;
                            oil = data.oilTemp1C;
                            water = data.waterTemp1C;
                            aoa = data.aoa;
                            load = data.load;
                            fuelMass = data.fuel;
                            climb = data.climb.toInt();
                            double fuelPercents =
                                data.fuel / data.maxFuel * 100;
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
                                                'Throttle= ${data.throttle1} %')
                                      ]),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 20),
                                    alignment: Alignment.topLeft,
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 40),
                                              text: 'IAS= ${data.ias} km/h')
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 20),
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      'Altitude= ${data.altitude} m',
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
                                      'Climb= ${data.climb} m/s',
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
                                      child: fuelPercents <= 13
                                          ? AnimatedTextKit(
                                              isRepeatingAnimation: true,
                                              repeatForever: true,
                                              animatedTexts: [
                                                ColorizeAnimatedText(
                                                  'Fuel= ${fuelPercents.toStringAsFixed(1)} %',
                                                  textStyle: const TextStyle(
                                                      fontSize: 40,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                  colors: [
                                                    Colors.red,
                                                    Colors.white,
                                                  ],
                                                ),
                                              ],
                                            )
                                          : Text(
                                              'Fuel= ${fuelPercents.toStringAsFixed(1)} %',
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
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 40),
                                              text:
                                                  'Oil Temp= ${data.oilTemp1C}°c')
                                        ],
                                      ),
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
                                                'Water Temp= ${data.waterTemp1C}°c')
                                      ]),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 20),
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      'AoA= ${data.aoa}°',
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
                                child: AnimatedTextKit(
                              isRepeatingAnimation: true,
                              repeatForever: true,
                              animatedTexts: [
                                ColorizeAnimatedText(
                                  'ERROR: NO DATA',
                                  textStyle: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  colors: [
                                    Colors.red,
                                    Colors.white,
                                  ],
                                ),
                              ],
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
                            final data = shot.data!;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (ref.read(provider.vehicleNameProvider) !=
                                  data.type) {
                                ref
                                    .read(provider.vehicleNameProvider.notifier)
                                    .state = data.type;
                              }
                            });
                            vertical = data.vertical;
                            final double mach = data.mach ?? 0;
                            if (!ref.watch(provider.inMatchProvider)) {
                              return Flex(
                                direction: Axis.vertical,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 20),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'Not In Match',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40),
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
                                                'Compass= ${data.compass?.toStringAsFixed(0) ?? ''}°')
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
                                                'Mach= ${mach.toStringAsFixed(1)} M')
                                      ]),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                          if (shot.hasError) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (ref.read(provider.vehicleNameProvider) ==
                                  null) {
                                ref
                                    .read(provider.vehicleNameProvider.notifier)
                                    .state = null;
                              }
                            });
                            return Center(
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                child: AnimatedTextKit(
                                  isRepeatingAnimation: true,
                                  repeatForever: true,
                                  animatedTexts: [
                                    ColorizeAnimatedText(
                                      'ERROR: NO DATA',
                                      textStyle: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                      colors: [
                                        Colors.red,
                                        Colors.white,
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ref
                                  .read(provider.vehicleNameProvider.notifier)
                                  .state = '';
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
            ),
            PaneItem(
              icon: const Icon(FluentIcons.nav2_d_map_view),
              title: const Text('Game Map'),
              body: InteractiveViewer(
                child: GameMap(
                  isInMatch: ref.read(provider.inMatchProvider),
                ),
              ),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.chat),
              title: const Text('Game Chat'),
              body: const Chat(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.settings),
              title: const Text('Settings'),
              infoBadge: fireBaseVersion.when(
                  data: (data) {
                    bool isNew = false;
                    if (data.hasValue &&
                        int.parse(data!.replaceAll('.', '')) >
                            int.parse(appVersion.replaceAll('.', ''))) {
                      isNew = true;
                    }
                    return isNew ? const InfoBadge(source: Text('!')) : null;
                  },
                  error: (e, st) => null,
                  loading: () => null),
              body: const Settings(),
            ),
            // if (ref.watch(provider.orgbClientProvider).notNull &&
            //     ref.watch(provider.orgbControllersProvider).notNull &&
            //     ref.watch(provider.orgbControllersProvider).isNotEmpty)
            //   PaneItem(
            //     icon: Icon(
            //       FluentIcons.settings,
            //       color: Colors.red,
            //     ),
            //     title: const Text('OpenRGB Settings'),
            //     body: const RGBSettings(),
            //   ),
          ]),
    );
  }
}
