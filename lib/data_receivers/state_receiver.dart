import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

class ToolDataState {
  int? ias;
  int? oil;
  int? water;
  int? height;
  int? flap;
  int? minFuel;
  int? maxFuel;
  int? gear;
  double? climb;
  bool valid;
  double? load;
  double? aoa;

  ToolDataState(
      {required this.ias,
      this.oil,
      this.water,
      this.height,
      this.flap,
      this.maxFuel,
      this.minFuel,
      required this.valid,
      this.climb,
      this.gear,
      this.load,
      this.aoa});

  static Future<ToolDataState> getState() async {
    // make the request
    try {
      Response? response = await get(Uri.parse('http://localhost:8111/state'));
      Map<String, dynamic>? data = jsonDecode(response.body);
      return ToolDataState(
          ias: data!['IAS, km/h'],
          oil: data['oil temp 1, C'],
          water: data['water temp 1, C'],
          height: data['H, m'],
          flap: data['flaps, %'],
          maxFuel: data['Mfuel0, kg'],
          minFuel: data['Mfuel, kg'],
          valid: data['valid'],
          climb: data['Vy, m/s'],
          gear: data['gear, %'],
          load: data['Ny'],
          aoa: data['AoA, deg']);
    } catch (e) {
      rethrow;
    }
  }
}
