// To parse this JSON data, do
//
//     final network = networkFromJson(jsonString);

import 'dart:convert';

import 'package:http/http.dart';

ToolDataState networkFromJson(String str) =>
    ToolDataState.fromJson(json.decode(str));

String networkToJson(ToolDataState data) => json.encode(data.toJson());

class ToolDataState {
  ToolDataState({
    required this.valid,
    required this.aileron,
    required this.elevator,
    required this.rudder,
    required this.flaps,
    required this.gear,
    required this.airbrake,
    required this.altitude,
    required this.tas,
    required this.ias,
    required this.mach,
    required this.aoa,
    required this.aos,
    required this.load,
    required this.climb,
    required this.wxDegS,
    required this.fuel,
    required this.maxFuel,
    required this.throttle1,
    required this.power1Hp,
    required this.rpm1,
    required this.manifoldPressure1Atm,
    required this.oilTemp1C,
    required this.thrust1Kgs,
    required this.efficiency1,
    required this.throttle2,
    required this.power2Hp,
    required this.rpm2,
    required this.manifoldPressure2Atm,
    required this.oilTemp2C,
    required this.thrust2Kgs,
    required this.efficiency2,
    required this.waterTemp1C,
  });

  final bool valid;
  final int aileron;
  final int elevator;
  final int rudder;
  final int? flaps;
  final int gear;
  final int? airbrake;
  final int altitude;
  final int tas;
  final int ias;
  final double mach;
  final double aoa;
  final double aos;
  final double load;
  final double climb;
  final int wxDegS;
  final int fuel;
  final int maxFuel;
  final int throttle1;
  final double power1Hp;
  final int rpm1;
  final double manifoldPressure1Atm;
  final int oilTemp1C;
  final int thrust1Kgs;
  final int efficiency1;
  final int? throttle2;
  final double? power2Hp;
  final int? rpm2;
  final double? manifoldPressure2Atm;
  final int? oilTemp2C;
  final int? thrust2Kgs;
  final int? efficiency2;
  final int? waterTemp1C;

  static Future<ToolDataState> getState() async {
    // make the request
    try {
      Response? response = await get(Uri.parse('http://localhost:8111/state'));
      Map<String, dynamic> data = jsonDecode(response.body);
      ToolDataState toolDataState = ToolDataState.fromJson(data);
      return toolDataState;
    } catch (e) {
      rethrow;
    }
  }

  factory ToolDataState.fromJson(Map<String, dynamic> json) => ToolDataState(
        valid: json['valid'] == null ? null : json['valid'],
        aileron: json['aileron, %'] == null ? null : json['aileron, %'],
        elevator: json['elevator, %'] == null ? null : json['elevator, %'],
        rudder: json['rudder, %'] == null ? null : json['rudder, %'],
        flaps: json['flaps, %'] == null ? null : json['flaps, %'],
        gear: json['gear, %'] == null ? null : json['gear, %'],
        airbrake: json['airbrake, %'] == null ? null : json['airbrake, %'],
        altitude: json['H, m'] == null ? null : json['H, m'],
        tas: json['TAS, km/h'] == null ? null : json['TAS, km/h'],
        ias: json['IAS, km/h'] == null ? null : json['IAS, km/h'],
        mach: json['M'] == null ? null : json['M'],
        aoa: json['AoA, deg'] == null ? null : json['AoA, deg'].toDouble(),
        aos: json['AoS, deg'] == null ? null : json['AoS, deg'].toDouble(),
        load: json['Ny'] == null ? null : json['Ny'].toDouble(),
        climb: json['Vy, m/s'] == null ? null : json['Vy, m/s'],
        wxDegS: json['Wx, deg/s'] == null ? null : json['Wx, deg/s'],
        fuel: json['Mfuel, kg'] == null ? null : json['Mfuel, kg'],
        maxFuel: json['Mfuel0, kg'] == null ? null : json['Mfuel0, kg'],
        throttle1: json['throttle 1, %'] == null ? null : json['throttle 1, %'],
        power1Hp: json['power 1, hp'] == null ? null : json['power 1, hp'],
        rpm1: json['RPM 1'] == null ? null : json['RPM 1'],
        manifoldPressure1Atm: json['manifold pressure 1, atm'] == null
            ? null
            : json['manifold pressure 1, atm'],
        oilTemp1C: json['oil temp 1, C'] == null ? null : json['oil temp 1, C'],
        thrust1Kgs:
            json['thrust 1, kgs'] == null ? null : json['thrust 1, kgs'],
        efficiency1:
            json['efficiency 1, %'] == null ? null : json['efficiency 1, %'],
        throttle2: json['throttle 2, %'] == null ? null : json['throttle 2, %'],
        power2Hp: json['power 2, hp'] == null ? null : json['power 2, hp'],
        rpm2: json['RPM 2'] == null ? null : json['RPM 2'],
        manifoldPressure2Atm: json['manifold pressure 2, atm'] == null
            ? null
            : json['manifold pressure 2, atm'],
        oilTemp2C: json['oil temp 2, C'] == null ? null : json['oil temp 2, C'],
        thrust2Kgs:
            json['thrust 2, kgs'] == null ? null : json['thrust 2, kgs'],
        efficiency2:
            json['efficiency 2, %'] == null ? null : json['efficiency 2, %'],
        waterTemp1C:
            json['water temp 1, C'] == null ? 0 : json['water temp 1, C'],
      );

  Map<String, dynamic> toJson() => {
        'valid': valid == null ? null : valid,
        'aileron, %': aileron == null ? null : aileron,
        'elevator, %': elevator == null ? null : elevator,
        'rudder, %': rudder == null ? null : rudder,
        'flaps, %': flaps == null ? null : flaps,
        'gear, %': gear == null ? null : gear,
        'airbrake, %': airbrake == null ? null : airbrake,
        'H, m': altitude == null ? null : altitude,
        'TAS, km/h': tas == null ? null : tas,
        'IAS, km/h': ias == null ? null : ias,
        'M': mach == null ? null : mach,
        'AoA, deg': aoa == null ? null : aoa,
        'AoS, deg': aos == null ? null : aos,
        'Ny': load == null ? null : load,
        'Vy, m/s': climb == null ? null : climb,
        'Wx, deg/s': wxDegS == null ? null : wxDegS,
        'Mfuel, kg': fuel == null ? null : fuel,
        'Mfuel0, kg': maxFuel == null ? null : maxFuel,
        'throttle 1, %': throttle1 == null ? null : throttle1,
        'power 1, hp': power1Hp == null ? null : power1Hp,
        'RPM 1': rpm1 == null ? null : rpm1,
        'manifold pressure 1, atm':
            manifoldPressure1Atm == null ? null : manifoldPressure1Atm,
        'oil temp 1, C': oilTemp1C == null ? null : oilTemp1C,
        'thrust 1, kgs': thrust1Kgs == null ? null : thrust1Kgs,
        'efficiency 1, %': efficiency1 == null ? null : efficiency1,
        'throttle 2, %': throttle2 == null ? null : throttle2,
        'power 2, hp': power2Hp == null ? null : power2Hp,
        'RPM 2': rpm2 == null ? null : rpm2,
        'manifold pressure 2, atm':
            manifoldPressure2Atm == null ? null : manifoldPressure2Atm,
        'oil temp 2, C': oilTemp2C == null ? null : oilTemp2C,
        'thrust 2, kgs': thrust2Kgs == null ? null : thrust2Kgs,
        'efficiency 2, %': efficiency2 == null ? null : efficiency2,
        'water temp 1, C': waterTemp1C == null ? null : waterTemp1C,
      };
}
