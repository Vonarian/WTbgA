import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

class ToolDataIndicator {
  String? name;
  double? throttle;
  double? mach;
  double? compass;
  double? engine;
  double? flap1;
  double? flap2;
  double? vertical;
  bool? valid;
  ToolDataIndicator(
      {this.name,
      this.throttle,
      this.mach,
      this.compass,
      this.engine,
      this.flap1,
      this.flap2,
      this.vertical,
      this.valid});

  static Future<ToolDataIndicator> getIndicator() async {
    // make the request
    Response? response =
        await get(Uri.parse('http://localhost:8111/indicators'));
    Map<String, dynamic> indicatorData = jsonDecode(response.body);
    return ToolDataIndicator(
        name: indicatorData['type'].toString().toUpperCase(),
        throttle: indicatorData['throttle'],
        compass: indicatorData['compass'],
        mach: indicatorData['mach'],
        engine: indicatorData.containsKey('water_temperature_hour')
            ? indicatorData['water_temperature_hour']
            : indicatorData['water_temperature'],
        flap1: indicatorData['flaps1'],
        flap2: indicatorData['flaps2'],
        vertical: indicatorData['aviahorizon_pitch'],
        valid: indicatorData['valid']);
  }
}
