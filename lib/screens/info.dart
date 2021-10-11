import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  drawerBuilder() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(color: Colors.blueGrey),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Icon(
                Icons.notifications,
                size: 100,
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                  onPressed: () {},
                  label: const Text(
                    'Notifications: On/Off',
                    style: TextStyle(color: Colors.green),
                  ),
                  icon: const Icon(Icons.notifications)),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                  onPressed: () {},
                  label: const Text(
                    'Engine Notification: On/Off',
                    style: TextStyle(color: Colors.green),
                  ),
                  icon: const Icon(Icons.notifications)),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                  onPressed: () {},
                  label: const Text(
                    'Oil Notification: On/Off',
                    style: TextStyle(color: Colors.green),
                  ),
                  icon: const Icon(Icons.notifications)),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                  onPressed: () {},
                  label: const Text(
                    'Water Notification: On/Off',
                    style: TextStyle(color: Colors.green),
                  ),
                  icon: const Icon(Icons.notifications)),
            ),
            Container(
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(color: Colors.black87),
              child: TextButton.icon(
                  onPressed: () {},
                  label: const Text(
                    'Minimize to tray: On/Off',
                    style: TextStyle(color: Colors.green),
                  ),
                  icon: const Icon(Icons.minimize_rounded)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawerBuilder(),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        actions: [
          appbarButtonBuilder(
              'IAS red line for Flaps',
              'This button in the home screen allows you to enter maximum IAS allowed with flaps open',
              Icons.warning,
              Colors.red),
          appbarButtonBuilder(
              'IAS red line for gears',
              'This button in the home screen allows you to enter maximum IAS allowed with gears open',
              Icons.warning,
              Colors.deepPurple),
          appbarButtonBuilder(
              'G load limit',
              "This button in the home screen allows you to enter allowed G load before you get a warning. ",
              Icons.warning,
              Colors.amber),
          appbarButtonBuilder(
              'Transparent page',
              'This button in the home screen allows you to enter transparent page',
              Icons.window,
              Colors.white),
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.list),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ],
        centerTitle: true,
        title: const Text(
          'Information Page',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            containerBuilder('Oil Temp',
                'Clicking on Oil Temp button allows you enable/disable the overheat notifications'),
            containerBuilder('Engine Temp',
                'Clicking on Engine Temp allows you enable/disable the engine overheat / death notifications'),
            containerBuilder('Altitude', 'This button does nothing😁'),
            containerBuilder('Water Temp',
                'Clicking on Water Temp button allows you enable/disable the overheat notifications'),
            containerBuilder('Compass', 'This button does nothing😁'),
            containerBuilder('IAS', 'This button does nothing😁'),
            containerBuilder('Throttle', 'This button does nothing😁'),
            containerBuilder('Absolute Climb rate', 'This button does nothing')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(const SnackBar(
              content: Text(
                  'This button will toggle all notifications with one click.'),
              duration: Duration(seconds: 5),
            ));
        },
        child: const Icon(Icons.notifications),
      ),
    );
  }

  Widget containerBuilder(String text, String buttonText) {
    return Flexible(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(10, 25, 123, 0.5),
                Color.fromRGBO(200, 200, 200, 0.5),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(20.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.2),
                spreadRadius: 4,
                blurRadius: 10,
                offset: const Offset(0, 3),
              )
            ]),
        child: Expanded(
          child: TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text(buttonText),
                  duration: const Duration(seconds: 5),
                ));
            },
            child: Text(
              text,
              style: const TextStyle(fontSize: 27, color: Colors.pink),
            ),
          ),
        ),
      ),
    );
  }

  Widget appbarButtonBuilder(
      String text, String buttonText, var buttonIcon, var buttonColor) {
    return IconButton(
        onPressed: () {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(buttonText),
              duration: const Duration(seconds: 5),
            ));
        },
        icon: Icon(buttonIcon, color: buttonColor),
        tooltip: text);
  }
}
