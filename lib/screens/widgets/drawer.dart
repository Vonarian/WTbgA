import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wtbgassistant/screens/widgets/slider.dart';
import 'package:wtbgassistant/services/providers.dart';

import '../transparent.dart';

class TopDrawer extends ConsumerStatefulWidget {
  final Future<SharedPreferences> prefs;
  const TopDrawer({Key? key, required this.prefs}) : super(key: key);

  @override
  _DrawerBuilderHomeState createState() => _DrawerBuilderHomeState();
}

class _DrawerBuilderHomeState extends ConsumerState<TopDrawer> {
  // static Route<int> dialogBuilderIasFlap(BuildContext context) {
  //   TextEditingController userInputIasFlap = TextEditingController();
  //   return DialogRoute(
  //     context: context,
  //     builder: (BuildContext context) => AlertDialog(
  //       actions: [
  //         ElevatedButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: const Text('Cancel')),
  //         ElevatedButton(
  //             onPressed: () {
  //               ScaffoldMessenger.of(context)
  //                 ..removeCurrentSnackBar()
  //                 ..showSnackBar(SnackBar(
  //                     content: Text(
  //                         'You will be notified if IAS reaches red line speed of ${userInputIasFlap.text} km/h (With flaps open). ')));
  //               Navigator.of(context).pop(int.parse(userInputIasFlap.text));
  //             },
  //             child: const Text('Notify')),
  //       ],
  //       title: const Text('Red line notifier (Enter red line flap speed). '),
  //       content: TextField(
  //         onChanged: (value) {},
  //         controller: userInputIasFlap,
  //         decoration: const InputDecoration(hintText: 'Enter the IAS in km/h'),
  //       ),
  //     ),
  //   );
  // }

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

  // static Route<int> dialogBuilderIasGear(BuildContext context) {
  //   TextEditingController userInputIasGear = TextEditingController();
  //   return DialogRoute(
  //       context: context,
  //       builder: (BuildContext context) => AlertDialog(
  //             content: TextField(
  //               onChanged: (value) {},
  //               controller: userInputIasGear,
  //               decoration:
  //                   const InputDecoration(hintText: 'Enter the IAS in km/h'),
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
  //                           content: Text(
  //                               'You will be notified if IAS reaches red line speed of ${userInputIasGear.text} km/h (With gears open). ')));
  //                     Navigator.of(context)
  //                         .pop(int.parse(userInputIasGear.text));
  //                   },
  //                   child: const Text('Notify'))
  //             ],
  //           ));
  // }

  // Color headerColor = Colors.teal;
  // IconData drawerIcon = Icons.settings;

  @override
  Widget build(BuildContext context) {
    var phoneConnected = ref.read(phoneConnectedProvider.notifier);
    var nonePost = ref.read(nonePostProvider.notifier);
    var ipAddress = ref.read(ipAddressProvider.notifier);
    var fullNotif = ref.read(fullNotifProvider.notifier);
    var stallNotif = ref.read(stallNotifProvider.notifier);
    var oilNotif = ref.read(oilNotifProvider.notifier);
    var engineDeath = ref.read(engineDeathNotifProvider.notifier);
    var pullUpNotif = ref.read(pullUpNotifProvider.notifier);
    var waterNotif = ref.read(waterNotifProvider.notifier);
    var tray = ref.read(trayProvider.notifier);
    var gLoad = ref.read(gLoadProvider.notifier);
    var transparentFont = ref.read(transparentFontProvider.notifier);
    var headerColor = ref.read(headerColorProvider.notifier);
    var drawerIcon = ref.read(drawerIconProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('WTbgA Settings'),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.black),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              curve: Curves.bounceIn,
              duration: const Duration(seconds: 4),
              decoration: BoxDecoration(
                color: headerColor.state,
              ),
              child: Icon(
                drawerIcon.state,
                size: 100,
              ),
            ),
            phoneConnected.state
                ? SelectableText(
                    'PC IP: ${ipAddress.state}',
                  )
                : nonePost.state
                    ? SelectableText(
                        'PC IP: ${ipAddress.state}',
                      )
                    : SelectableText(
                        'PC IP: ${ipAddress.state}',
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 20),
                      ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                  onPressed: () async {
                    final SharedPreferences prefs = await widget.prefs;
                    bool isFullNotifOn =
                        (prefs.getBool('isFullNotifOn') ?? true);
                    isFullNotifOn = !isFullNotifOn;
                    setState(() {
                      fullNotif.state = isFullNotifOn;
                    });
                    prefs.setBool('isFullNotifOn', isFullNotifOn);
                  },
                  label: fullNotif.state
                      ? const Text(
                          'Notifications: On',
                          style: TextStyle(color: Colors.green),
                        )
                      : const Text(
                          'Notifications: Off',
                          style: TextStyle(color: Colors.red),
                        ),
                  icon: fullNotif.state
                      ? const Icon(Icons.notifications)
                      : const Icon(Icons.notifications_off)),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                  onPressed: () async {
                    final SharedPreferences prefs = await widget.prefs;
                    bool _playStallWarning =
                        (prefs.getBool('playStallWarning') ?? true);
                    _playStallWarning = !_playStallWarning;
                    setState(() {
                      stallNotif.state = _playStallWarning;
                    });
                    prefs.setBool('playStallWarning', _playStallWarning);
                  },
                  label: stallNotif.state
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
                    final SharedPreferences prefs = await widget.prefs;
                    bool _isPullUpEnabled =
                        (prefs.getBool('isPullUpEnabled') ?? true);
                    _isPullUpEnabled = !_isPullUpEnabled;
                    setState(() {
                      pullUpNotif.state = _isPullUpEnabled;
                    });
                    prefs.setBool('isPullUpEnabled', _isPullUpEnabled);
                  },
                  label: pullUpNotif.state
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
                    final SharedPreferences prefs = await widget.prefs;
                    bool isEngineDeathNotifOn =
                        (prefs.getBool('isEngineDeathNotifOn') ?? true);
                    isEngineDeathNotifOn = !isEngineDeathNotifOn;
                    setState(() {
                      engineDeath.state = isEngineDeathNotifOn;
                    });
                    prefs.setBool('isEngineDeathNotifOn', isEngineDeathNotifOn);
                  },
                  label: engineDeath.state
                      ? const Text(
                          'Engine Notification: On',
                          style: TextStyle(color: Colors.green),
                        )
                      : const Text(
                          'Engine Notification: Off',
                          style: TextStyle(color: Colors.red),
                        ),
                  icon: engineDeath.state
                      ? const Icon(MaterialCommunityIcons.engine)
                      : const Icon(Icons.notifications_off)),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                  onPressed: () async {
                    final SharedPreferences prefs = await widget.prefs;
                    bool isOilNotifOn = (prefs.getBool('isOilNotifOn') ?? true);
                    isOilNotifOn = !isOilNotifOn;
                    setState(() {
                      oilNotif.state = isOilNotifOn;
                    });
                    prefs.setBool('isOilNotifOn', isOilNotifOn);
                  },
                  label: oilNotif.state
                      ? const Text(
                          'Oil Notification: On',
                          style: TextStyle(color: Colors.green),
                        )
                      : const Text(
                          'Oil Notification: Off',
                          style: TextStyle(color: Colors.red),
                        ),
                  icon: oilNotif.state
                      ? const Icon(MaterialCommunityIcons.oil_temperature)
                      : const Icon(Icons.notifications_off)),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                  onPressed: () async {
                    final SharedPreferences prefs = await widget.prefs;
                    bool isWaterNotifOn =
                        (prefs.getBool('isWaterNotifOn') ?? true);
                    isWaterNotifOn = !isWaterNotifOn;
                    setState(() {
                      waterNotif.state = isWaterNotifOn;
                    });
                    prefs.setBool('isWaterNotifOn', isWaterNotifOn);
                  },
                  label: waterNotif.state
                      ? const Text(
                          'Water Notification: On',
                          style: TextStyle(color: Colors.green),
                        )
                      : const Text(
                          'Water Notification: Off',
                          style: TextStyle(color: Colors.red),
                        ),
                  icon: waterNotif.state
                      ? const Icon(MaterialCommunityIcons.water)
                      : const Icon(Icons.notifications_off)),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                  onPressed: () async {
                    final SharedPreferences prefs = await widget.prefs;
                    bool isTrayEnabled =
                        (prefs.getBool('isTrayEnabled') ?? true);
                    isTrayEnabled = !isTrayEnabled;
                    setState(() {
                      tray.state = isTrayEnabled;
                    });
                    prefs.setBool('isTrayEnabled', isTrayEnabled);
                  },
                  label: tray.state
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
            // Container(
            //   alignment: Alignment.topLeft,
            //   decoration: const BoxDecoration(color: Colors.black87),
            //   child: TextButton.icon(
            //     label: Text(
            //         'Current red line IAS for flaps: ${flapIas.state}Km/h'),
            //     icon: const Icon(
            //       MaterialCommunityIcons.airplane_takeoff,
            //       color: Colors.red,
            //     ),
            //     onPressed: () async {
            //       final SharedPreferences prefs = await widget.prefs;
            //       flapIas.state = (await Navigator.of(context)
            //           .push(dialogBuilderIasFlap(context)))!;
            //       int textForIasFlap = (prefs.getInt('textForIasFlap') ?? 2000);
            //       setState(() {
            //         textForIasFlap = flapIas.state;
            //       });
            //       prefs.setInt('textForIasFlap', textForIasFlap);
            //     },
            //   ),
            // ),
            // Container(
            //   alignment: Alignment.topLeft,
            //   decoration: const BoxDecoration(color: Colors.black87),
            //   child: TextButton.icon(
            //     label: Text(
            //         'Current red line IAS for gears: ${gearIas.state}Km/h'),
            //     onPressed: () async {
            //       final SharedPreferences prefs = await widget.prefs;
            //       gearIas.state = (await Navigator.of(context)
            //           .push(dialogBuilderIasGear(context)))!;
            //       int textForIasGear = (prefs.getInt('textForIasGear') ?? 2000);
            //
            //       setState(() {
            //         textForIasGear = gearIas.state;
            //       });
            //       prefs.setInt('textForIasGear', textForIasGear);
            //     },
            //     icon: const Icon(
            //       EvilIcons.gear,
            //       color: Colors.deepPurple,
            //     ),
            //   ),
            // ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                  label: Text('Current red line G load: ${gLoad.state}G'),
                  onPressed: () async {
                    final SharedPreferences prefs = await widget.prefs;
                    gLoad.state = (await Navigator.of(context)
                        .push(dialogBuilderOverG(context)))!;
                    int textForGLoad = (prefs.getInt('textForGLoad') ?? 12);
                    setState(() {
                      textForGLoad = gLoad.state;
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
                  label: const Text(
                    'In-game Overlay (Hold for font size)',
                  ),
                  onLongPress: () async {
                    showGeneralDialog(
                        context: context,
                        pageBuilder: (context, an, an2) {
                          return SliderClass(
                              defaultText: transparentFont.state,
                              callback: (double value) {
                                setState(() {
                                  transparentFont.state = value;
                                });
                              });
                        });
                  },
                  onPressed: () async {
                    await Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) {
                        int gearLimit = ref.watch(gearLimitProvider);
                        int flapLimit = ref.watch(flapLimitProvider);
                        return TransparentPage(
                          flapLimit: flapLimit,
                          gearLimit: gearLimit,
                          gLoad: gLoad.state,
                          fontSize: transparentFont.state,
                        );
                      }),
                    );
                  },
                  icon: const Icon(
                    MaterialCommunityIcons.window_open,
                    color: Colors.amber,
                  )),
            ),
            // Container(
            //   alignment: Alignment.topCenter,
            //   decoration: const BoxDecoration(color: Colors.black87),
            //   child: const Chat(),
            // ),
            // Container(
            //   alignment: Alignment.topCenter,
            //   decoration: const BoxDecoration(color: Colors.black87),
            //   child: const Chat(),
          ],
        ),
      ),
    );
  }
}
