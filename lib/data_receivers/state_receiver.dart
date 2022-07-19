import 'package:dio/dio.dart';

import '../main.dart';

class StateData {
  const StateData({
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
  final int? efficiency1;
  final int? throttle2;
  final double? power2Hp;
  final int? rpm2;
  final double? manifoldPressure2Atm;
  final int? oilTemp2C;
  final int? thrust2Kgs;
  final int? efficiency2;
  final int? waterTemp1C;

  static Stream<StateData?> getState() async* {
    final stream = Stream.periodic(const Duration(milliseconds: 200), (count) async {
      try {
        final Response response = await dio.get('http://localhost:8111/state').timeout(const Duration(seconds: 2));
        final StateData toolDataState = StateData.fromJson(response.data);
        return toolDataState;
      } catch (e) {
        return null;
      }
    }).asBroadcastStream();
    await for (var value in stream) {
      yield await value;
    }
  }

  factory StateData.fromJson(Map<String, dynamic> json) => StateData(
        valid: json['valid'],
        aileron: json['aileron, %'],
        elevator: json['elevator, %'],
        rudder: json['rudder, %'],
        flaps: json['flaps, %'],
        gear: json['gear, %'],
        airbrake: json['airbrake, %'],
        altitude: json['H, m'],
        tas: json['TAS, km/h'],
        ias: json['IAS, km/h'],
        mach: json['M'],
        aoa: json['AoA, deg'] ?? json['AoA, deg'].toDouble(),
        aos: json['AoS, deg'] ?? json['AoS, deg'].toDouble(),
        load: json['Ny'] ?? json['Ny'].toDouble(),
        climb: json['Vy, m/s'],
        wxDegS: json['Wx, deg/s'],
        fuel: json['Mfuel, kg'],
        maxFuel: json['Mfuel0, kg'],
        throttle1: json['throttle 1, %'],
        power1Hp: json['power 1, hp'],
        rpm1: json['RPM 1'],
        manifoldPressure1Atm: json['manifold pressure 1, atm'],
        oilTemp1C: json['oil temp 1, C'],
        thrust1Kgs: json['thrust 1, kgs'],
        efficiency1: json['efficiency 1, %'],
        throttle2: json['throttle 2, %'],
        power2Hp: json['power 2, hp'],
        rpm2: json['RPM 2'],
        manifoldPressure2Atm: json['manifold pressure 2, atm'],
        oilTemp2C: json['oil temp 2, C'],
        thrust2Kgs: json['thrust 2, kgs'],
        efficiency2: json['efficiency 2, %'],
        waterTemp1C: json['water temp 1, C'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'valid': valid,
        'aileron, %': aileron,
        'elevator, %': elevator,
        'rudder, %': rudder,
        'flaps, %': flaps,
        'gear, %': gear,
        'airbrake, %': airbrake,
        'H, m': altitude,
        'TAS, km/h': tas,
        'IAS, km/h': ias,
        'M': mach,
        'AoA, deg': aoa,
        'AoS, deg': aos,
        'Ny': load,
        'Vy, m/s': climb,
        'Wx, deg/s': wxDegS,
        'Mfuel, kg': fuel,
        'Mfuel0, kg': maxFuel,
        'throttle 1, %': throttle1,
        'power 1, hp': power1Hp,
        'RPM 1': rpm1,
        'manifold pressure 1, atm': manifoldPressure1Atm,
        'oil temp 1, C': oilTemp1C,
        'thrust 1, kgs': thrust1Kgs,
        'efficiency 1, %': efficiency1,
        'throttle 2, %': throttle2,
        'power 2, hp': power2Hp,
        'RPM 2': rpm2,
        'manifold pressure 2, atm': manifoldPressure2Atm,
        'oil temp 2, C': oilTemp2C,
        'thrust 2, kgs': thrust2Kgs,
        'efficiency 2, %': efficiency2,
        'water temp 1, C': waterTemp1C,
      };

  @override
  String toString() {
    return 'StateData{valid: $valid, aileron: $aileron, elevator: $elevator, rudder: $rudder, flaps: $flaps, gear: $gear, airbrake: $airbrake, altitude: $altitude, tas: $tas, ias: $ias, mach: $mach, aoa: $aoa, aos: $aos, load: $load, climb: $climb, wxDegS: $wxDegS, fuel: $fuel, maxFuel: $maxFuel, throttle1: $throttle1, power1Hp: $power1Hp, rpm1: $rpm1, manifoldPressure1Atm: $manifoldPressure1Atm, oilTemp1C: $oilTemp1C, thrust1Kgs: $thrust1Kgs, efficiency1: $efficiency1, throttle2: $throttle2, power2Hp: $power2Hp, rpm2: $rpm2, manifoldPressure2Atm: $manifoldPressure2Atm, oilTemp2C: $oilTemp2C, thrust2Kgs: $thrust2Kgs, efficiency2: $efficiency2, waterTemp1C: $waterTemp1C}';
  }
}
