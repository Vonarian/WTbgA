import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';

class PingingPoint extends StatefulWidget {
  const PingingPoint({super.key, this.alignment = Alignment.center});

  final Alignment alignment;

  @override
  State<PingingPoint> createState() => _PingingPointState();
}

class _PingingPointState extends State<PingingPoint> {
  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (height == 10) {
        height = 2;
      } else {
        height = 10;
      }
      setState(() {});
    });
  }

  double height = 10;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedContainer(
          alignment: Alignment.center,
          height: height,
          width: height,
          duration: const Duration(milliseconds: 600),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              width: 1,
              color: Colors.red,
            ),
            shape: BoxShape.circle,
          ),
          child: Container(
            alignment: Alignment.center,
            height: 2,
            decoration:
                BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          ),
        ),
      ],
    );
  }
}
