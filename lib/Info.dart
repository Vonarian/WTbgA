import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'stateReceiver.dart';

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        centerTitle: true,
        title: Text(
          'Information Page',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Flex(
          direction: Axis.vertical,
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
            containerBuilder('Throttle', 'This button does nothing😁')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(
                  'This button will toggle all notifications with one click.'),
              duration: Duration(seconds: 5),
            ));
        },
        child: Icon(Icons.notifications),
      ),
    );
  }

  Widget containerBuilder(String text, String buttonText) {
    return Flexible(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
            gradient: LinearGradient(
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
                offset: Offset(0, 3),
              )
            ]),
        child: TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(buttonText),
                duration: Duration(seconds: 5),
              ));
          },
          child: Text(
            text,
            style: TextStyle(fontSize: 27, color: Colors.pink),
          ),
        ),
      ),
    );
  }
}