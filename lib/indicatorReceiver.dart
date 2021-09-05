import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';

class ToolDataIndicator {
  String? name;
  String? throttle;
  double? mach;
  double? compass;
  double? engine;
  double? flap1;
  double? flap2;
  ToolDataIndicator(
      {this.name,
      this.throttle,
      this.mach,
      this.compass,
      this.engine,
      this.flap1,
      this.flap2});

  static Future<ToolDataIndicator> getIndicator() async {
    try {
      // make the request
      Response? response =
          await get(Uri.parse('http://localhost:8111/indicators'));
      Map<String, dynamic> indicatorData = jsonDecode(response.body);
      return ToolDataIndicator(
          name: indicatorData['type'].toString().toUpperCase(),
          throttle: indicatorData['throttle'].toString(),
          compass: indicatorData['compass'],
          mach: indicatorData['mach'],
          engine: indicatorData.containsKey('water_temperature_hour')
              ? indicatorData['water_temperature_hour']
              : indicatorData['water_temperature'],
          flap1: indicatorData['flaps1'],
          flap2: indicatorData['flaps2']);
    } catch (e, stackTrace) {
      log('Encountered error: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
}
