import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SliderClass extends StatefulWidget {
  final double defaultText;
  final DoubleCallBack callback;

  const SliderClass(
      {Key? key, required this.defaultText, required this.callback})
      : super(key: key);

  @override
  _SliderClassState createState() => _SliderClassState();
}

typedef DoubleCallBack = Function(double value);

class _SliderClassState extends State<SliderClass> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> loadPrefs() async {
    prefs.then((SharedPreferences prefs) {
      defaultText = (prefs.getDouble('fontSize') ?? 40);
    });
  }

  double defaultText = 40;
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  @override
  Widget build(BuildContext context) {
    defaultText = widget.defaultText;
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Set font size'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Padding(padding: EdgeInsets.only(top: 100)),
          Center(
            child: Slider(
              min: 20,
              max: 80,
              divisions: 60,
              label: defaultText.round().toString(),
              value: defaultText,
              onChanged: (double value) async {
                widget.callback(value);
                defaultText = value;
                setState(() {});
                final SharedPreferences _prefs = await prefs;

                double _defaultText = (_prefs.getDouble('fontSize') ?? 40);
                setState(() {
                  _defaultText = defaultText;
                });
                _prefs.setDouble('fontSize', _defaultText);
              },
            ),
          ),
          Center(
              child: Text(
            'Example:',
            style: TextStyle(fontSize: defaultText),
          ))
        ],
      ),
    );
  }
}
