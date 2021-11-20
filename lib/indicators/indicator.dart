import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Widget oilTempText(
    ValueListenable idData,
    double? normalHeight,
    double? smallHeight,
    double? boxShadowOpacity,
    int? oil,
    String? msgData,
    Color textColor,
    bool? showOilTemp) {
  return ValueListenableBuilder(
    valueListenable: idData,
    builder: (BuildContext context, value, Widget? child) {
      return AnimatedContainer(
          duration: const Duration(seconds: 2),
          height: MediaQuery.of(context).size.height >= 235
              ? normalHeight
              : smallHeight,
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(10, 123, 10, 0.403921568627451),
                  Color.fromRGBO(0, 50, 158, 0.4196078431372549),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(20.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(boxShadowOpacity!),
                  spreadRadius: 4,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                )
              ]),
          child: TextButton.icon(
            icon: const Icon(Icons.airplanemode_active),
            label: (oil != null && oil != 15) && msgData == 'Oil overheated'
                ? BlinkText(
                    'Oil Temp = ${oil} degrees  ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        letterSpacing: 2,
                        color: textColor,
                        fontWeight: FontWeight.bold),
                    endColor: Colors.red,
                    times: 13,
                    duration: const Duration(milliseconds: 200),
                  )
                : oil != null && oil != 15
                    ? Text('Oil Temp= ${oil} degrees  ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            letterSpacing: 2,
                            color: textColor,
                            fontWeight: FontWeight.bold))
                    : Text('No data.  ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            letterSpacing: 2,
                            color: textColor,
                            fontWeight: FontWeight.bold)),
            onPressed: () {
              showOilTemp = !showOilTemp!;
            },
          ));
    },
  );
}

Widget waterTempText(
  BuildContext context,
  double? normalHeight,
  double? smallHeight,
  double? boxShadowOpacity,
  int? water,
  bool? showWaterTemp,
  Color textColor,
) {
  return AnimatedContainer(
      duration: const Duration(seconds: 2),
      height: MediaQuery.of(context).size.height >= 235
          ? normalHeight
          : smallHeight,
      decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromRGBO(10, 123, 10, 0.403921568627451),
              Color.fromRGBO(0, 50, 158, 0.4196078431372549),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(20.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(boxShadowOpacity!),
              spreadRadius: 4,
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          ]),
      child: water == null || water == 15
          ? TextButton.icon(
              icon: const Icon(Icons.water),
              onPressed: () {
                showWaterTemp = !showWaterTemp!;
              },
              label: Text(
                'Not water-cooled / No data available!  ',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    letterSpacing: 2,
                    color: textColor,
                    fontWeight: FontWeight.bold),
              ),
            )
          : TextButton.icon(
              icon: const Icon(Icons.water),
              onPressed: () {
                showWaterTemp = !showWaterTemp!;
              },
              label: Text(
                'Water Temp = ${water} degrees  ',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    letterSpacing: 2,
                    color: textColor,
                    fontWeight: FontWeight.bold),
              ),
            ));
}
