import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wtbgassistant/services/providers.dart';

import '../../main.dart';

class TopDrawer extends ConsumerStatefulWidget {
  const TopDrawer({Key? key}) : super(key: key);

  @override
  _DrawerBuilderHomeState createState() => _DrawerBuilderHomeState();
}

class _DrawerBuilderHomeState extends ConsumerState<TopDrawer> {
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
                ? Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SelectableText(
                      'PC IP: ${ipAddress.state}',
                    ),
                  )
                : nonePost.state
                    ? Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SelectableText(
                          'PC IP: ${ipAddress.state}',
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SelectableText(
                          'PC IP: ${ipAddress.state}',
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 20),
                        ),
                      ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                  onPressed: () async {
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
          ],
        ),
      ),
    );
  }
}
