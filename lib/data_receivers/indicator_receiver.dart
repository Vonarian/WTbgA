import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

class ToolDataIndicator {
  String name;
  double throttle;
  double mach;
  double compass;
  double engine;
  double flap1;
  double flap2;
  double vertical;
  bool valid;

  ToolDataIndicator(
      {required this.name,
      required this.throttle,
      required this.mach,
      required this.compass,
      required this.engine,
      required this.flap1,
      required this.flap2,
      required this.vertical,
      required this.valid});

  static Future<ToolDataIndicator> getIndicator() async {
    // make the request
    Response? response =
        await get(Uri.parse('http://localhost:8111/indicators'));
    Map<String, dynamic> indicatorData = jsonDecode(response.body);
    ToolDataIndicator toolDataIndicator =
        ToolDataIndicator.fromMap(indicatorData);
    return toolDataIndicator;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': this.name,
      'throttle': this.throttle,
      'mach': this.mach,
      'compass': this.compass,
      'engine': this.engine,
      'flap1': this.flap1,
      'flap2': this.flap2,
      'vertical': this.vertical,
      'valid': this.valid,
    };
  }

  factory ToolDataIndicator.fromMap(Map<String, dynamic> map) {
    return ToolDataIndicator(
      name: map['name'] as String,
      throttle: map['throttle'] as double,
      mach: map['mach'] as double,
      compass: map['compass'] as double,
      engine: map['engine'] as double,
      flap1: map['flap1'] as double,
      flap2: map['flap2'] as double,
      vertical: map['vertical'] as double,
      valid: map['valid'] as bool,
    );
  }
}
