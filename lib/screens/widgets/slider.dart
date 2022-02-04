import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wtbgassistant/services/providers.dart';

class SliderClass extends ConsumerStatefulWidget {
  final double defaultText;
  final DoubleCallBack callback;

  const SliderClass(
      {Key? key, required this.defaultText, required this.callback})
      : super(key: key);

  @override
  _SliderClassState createState() => _SliderClassState();
}

typedef DoubleCallBack = Function(double value);

class _SliderClassState extends ConsumerState<SliderClass> {
  @override
  void initState() {
    super.initState();
    loadPrefs();
  }

  Future<void> loadPrefs() async {
    prefs.then((SharedPreferences prefs) {
      ref.read(transparentFontProvider.notifier).state =
          (prefs.getDouble('fontSize') ?? 40);
    });
  }

  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  @override
  Widget build(BuildContext context) {
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
              activeColor: Colors.red,
              inactiveColor: Colors.blue,
              min: 20,
              max: 80,
              divisions: 60,
              label: ref.watch(transparentFontProvider).round().toString(),
              value: ref.watch(transparentFontProvider),
              onChanged: (double value) async {
                widget.callback(value);
                ref.read(transparentFontProvider.notifier).state = value;
                setState(() {});
                final SharedPreferences _prefs = await prefs;

                double _defaultText = (_prefs.getDouble('fontSize') ?? 40);
                setState(() {
                  _defaultText =
                      ref.read(transparentFontProvider.notifier).state;
                });
                _prefs.setDouble('fontSize', _defaultText);
              },
            ),
          ),
          Center(
              child: Text(
            'Example:',
            style: TextStyle(
                fontSize: ref.read(transparentFontProvider.notifier).state),
          ))
        ],
      ),
    );
  }
}
