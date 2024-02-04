import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../main.dart';

String fmPath = p.joinAll([
  p.dirname(Platform.resolvedExecutable),
  'data/flutter_assets/assets',
  'fm',
  'fm_data_db.csv'
]);

class Flap {
  final double combatFlaps;
  final double takeoffFlaps;
  final List<double> states;
  final List<double> criticalSpeeds;

  const Flap({
    required this.combatFlaps,
    required this.takeoffFlaps,
    required this.states,
    required this.criticalSpeeds,
  });

  factory Flap.load(String combat, String takeoff, String critSpeeds) {
    final double combatFlaps = double.parse(combat);
    final double takeoffFlaps = double.parse(takeoff);
    final List<String> critSpeedsSplit = critSpeeds.split(',');
    final states = <double>[];
    final speeds = <double>[];
    for (int i = 0; i < critSpeedsSplit.length; i++) {
      final value = critSpeedsSplit[i];
      if (i.isEven) {
        states.add(double.parse(value));
      } else {
        speeds.add(double.parse(value));
      }
    }

    return Flap(
        combatFlaps: combatFlaps,
        takeoffFlaps: takeoffFlaps,
        criticalSpeeds: speeds,
        states: states);
  }
}

class FmData {
  final String name;
  final double length;
  final double wingSpan;
  final double wingArea;
  final double emptyMass;
  final double maxFuelMass;
  final int critAirSpd;
  final double critAirSpdMach;
  final int critGearSpd;
  final Flap flap;
  final double critWingOverload1;
  final double critWingOverload2;
  final int engineNum;
  final double maxNitro;
  final double nitroConsume;
  final double critAoa1;
  final double critAoa2;
  final double critAoa3;
  final double critAoa4;

  const FmData({
    required this.name,
    required this.length,
    required this.wingSpan,
    required this.wingArea,
    required this.emptyMass,
    required this.maxFuelMass,
    required this.critAirSpd,
    required this.critAirSpdMach,
    required this.critGearSpd,
    required this.flap,
    required this.critWingOverload1,
    required this.critWingOverload2,
    required this.engineNum,
    required this.maxNitro,
    required this.nitroConsume,
    required this.critAoa1,
    required this.critAoa2,
    required this.critAoa3,
    required this.critAoa4,
  });

  static Future<FmData?> setFlightModel(String? name) async {
    if (csvList.isEmpty) {
      csvList.addAll(convertCsvToList(await csvString()));
    }
    FmData? fmData;
    if (name == null) return null;
    for (var element in csvList.skip(1)) {
      final data = element.split(';');
      if (data[0] == name) {
        fmData = FmData(
            name: data[0],
            length: double.parse(data[1]),
            wingSpan: !data[2].contains(',') ? double.parse(data[2]) : 0,
            wingArea: !data[3].contains(',') ? double.parse(data[3]) : 0,
            emptyMass: double.parse(data[4]),
            maxFuelMass: double.parse(data[5]),
            critAirSpd: !data[6].contains(',') ? int.parse(data[6]) : 2000,
            critAirSpdMach: !data[7].contains(',') ? double.parse(data[7]) : 2,
            critGearSpd: int.parse(data[8]),
            flap: Flap.load(data[9], data[10], data[11]),
            critWingOverload1:
                double.parse(data[12].split(',').first).toDouble(),
            critWingOverload2: double.parse(data[12].split(',').last),
            engineNum: int.parse(data[13]),
            maxNitro: double.parse(data[14]),
            nitroConsume: double.parse(data[15]),
            critAoa1: double.parse(data[16].split(',')[0]),
            critAoa2: double.parse(data[16].split(',')[1]),
            critAoa3: double.parse(data[16].split(',')[2]),
            critAoa4: double.parse(data[16].split(',')[3]));
      }
    }
    return fmData;
  }
}

Future<String> csvString() async {
  final String csvStr = await File(fmPath).readAsString();
  return csvStr;
}

List<String> convertCsvToList(String csvString) {
  final List<String> rowList = [];
  for (final rows in LineSplitter.split(csvString)) {
    rowList.add(rows);
  }
  return rowList;
}
