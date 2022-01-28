import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wtbgassistant/screens/widgets/drawer.dart';
import 'package:wtbgassistant/screens/widgets/providers.dart';

class TopBar extends ConsumerStatefulWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  _TopBarState createState() => _TopBarState();
}

Future<SharedPreferences> prefs = SharedPreferences.getInstance();

class _TopBarState extends ConsumerState<TopBar> {
  @override
  Widget build(BuildContext context) {
    var vehicleName = ref.read(vehicleNameProvider.notifier);
    var screenSize = MediaQuery.of(context).size;
    return PreferredSize(
      preferredSize: Size(screenSize.width, 1000),
      child: Container(
        color: Colors.blueGrey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 20, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
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
                (vehicleName.state ?? 'ERROR').toUpperCase(),
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
            ],
          ),
        ),
      ),
    );
  }
}
