import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

class ToolDataIndicator {
  String type;
  double throttle;
  double? mach;
  double compass;
  double? engine;
  double? flap1;
  double? flap2;
  double? vertical;
  bool valid;

  ToolDataIndicator(
      {required this.type,
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
    try {
      Response? response =
          await get(Uri.parse('http://localhost:8111/indicators'));
      Map<String, dynamic> indicatorData = jsonDecode(response.body);
      if (response.body.contains('{"valid": true')) {
        ToolDataIndicator toolDataIndicator =
            ToolDataIndicator.fromMap(indicatorData);
        return toolDataIndicator;
      } else
        throw 0;
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': this.type,
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
      type: map['type'] as String,
      throttle: map['throttle'] as double,
      mach: map.containsKey('mach') ? map['mach'] as double : null,
      compass: map['compass'] as double,
      engine: map.containsKey('engine') ? map['engine'] as double : null,
      flap1: map.containsKey('flap1') ? map['flap1'] as double : null,
      flap2: map.containsKey('flap2') ? map['flap2'] as double : null,
      vertical: map.containsKey('vertical') ? map['vertical'] as double : null,
      valid: map['valid'] as bool,
    );
  }
}
