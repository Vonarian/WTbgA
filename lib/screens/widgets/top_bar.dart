import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wtbgassistant/screens/widgets/drawer.dart';
import 'package:wtbgassistant/services/providers.dart';

class TopBar extends ConsumerStatefulWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  _TopBarState createState() => _TopBarState();
}

Future<SharedPreferences> prefs = SharedPreferences.getInstance();

class _TopBarState extends ConsumerState<TopBar> with TickerProviderStateMixin {
  void displayCapture() async {
    await Process.run(delPath, [], runInShell: true);
  }

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: false, period: const Duration(seconds: 1));
  String delPath = p.joinAll([
    p.dirname(Platform.resolvedExecutable),
    'data/flutter_assets/assets',
    'del.bat'
  ]);
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return PreferredSize(
      preferredSize: Size(screenSize.width, 1000),
      child: Container(
        color: Colors.blueGrey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 20, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                padding: const EdgeInsets.only(top: 3),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return TopDrawer(
                          prefs: prefs,
                        );
                      });
                },
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
              ),
              Text(
                (ref.watch(vehicleNameProvider) ?? 'ERROR')
                    .toUpperCase()
                    .replaceAll('_', ' '),
                style: TextStyle(
                  color: Colors.blueGrey[100],
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 3,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: screenSize.width / 8),
                    SizedBox(width: screenSize.width / 20),
                  ],
                ),
              ),
              SizedBox(
                width: screenSize.width / 50,
              ),
              ref.watch(phoneConnectedProvider)
                  ? RotationTransition(
                      turns: _controller,
                      child: IconButton(
                        onPressed: displayCapture,
                        icon: const Icon(
                          Icons.wifi_rounded,
                          color: Colors.green,
                        ),
                        tooltip:
                            'Phone Connected = ${ref.watch(phoneConnectedProvider)}',
                      ),
                    )
                  : IconButton(
                      onPressed: displayCapture,
                      icon: const Icon(
                        Icons.wifi_rounded,
                        color: Colors.red,
                      ),
                      tooltip: 'Toggle Stream Mode',
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
