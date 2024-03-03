import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../main.dart';
import 'aoa.dart';
import 'critairspeed.dart';
import 'flap.dart';
import 'rpm.dart';
import 'wing_area.dart';
import 'wing_overload.dart';
import 'wing_span.dart';

String fmPath = p.joinAll([
  p.dirname(Platform.resolvedExecutable),
  'data/flutter_assets/assets',
  'fm',
  'fm_data_db.csv'
]);

// Name;Length;WingSpan;WingArea;EmptyMass;MaxFuelMass;CritAirSpd;CritAirSpdMach;CritGearSpd;CombatFlaps;TakeoffFlaps;CritFlapsSpd;CritWingOverload;NumEngines;RPM;MaxNitro;NitroConsum;CritAoA
class FmData {
  final String name;
  final double length;
  final WingSpan wingSpan;
  final WingArea wingArea;
  final double emptyMass;
  final double maxFuelMass;
  final CritAirSpeed critAirSpd;
  final double critAirSpdMach;
  final double critGearSpd;
  final Flap flap;
  final WingOverload critWingOverload;
  final int engineNum;
  final double maxNitro;
  final double nitroConsume;
  final CritAoA critAoA;
  final RPM rpm;

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
    required this.critWingOverload,
    required this.engineNum,
    required this.rpm,
    required this.maxNitro,
    required this.nitroConsume,
    required this.critAoA,
  });

  static Future<FmData?> setFlightModel(String? name) async {
    if (name == null) return null;
    if (csvList.isEmpty) {
      csvList.addAll(convertCsvToList(await csvString()));
    }
    FmData? fmData;
    for (var element in csvList.skip(1)) {
      final data = element.split(';');
      if (data[0] == name) {
        fmData = FmData(
          name: data[0],
          length: double.parse(data[1]),
          wingSpan: WingSpan.load(data[2]),
          wingArea: WingArea.load(data[3]),
          emptyMass: double.parse(data[4]),
          maxFuelMass: double.parse(data[5]),
          critAirSpd: CritAirSpeed.load(data[6]),
          critAirSpdMach: double.parse(data[7]),
          critGearSpd: double.parse(data[8]),
          flap: Flap.load(data[9], data[10], data[11]),
          critWingOverload: WingOverload.load(data[12]),
          engineNum: int.parse(data[13]),
          rpm: RPM.load(data[14]),
          maxNitro: double.parse(data[15]),
          nitroConsume: double.parse(data[16]),
          critAoA: CritAoA.load(
            data[17],
          ),
        );
      }
    }
    return fmData;
  }

  @override
  String toString() {
    return 'FmData{name: $name, length: $length, wingSpan: $wingSpan, wingArea: $wingArea, emptyMass: $emptyMass, maxFuelMass: $maxFuelMass, critAirSpd: $critAirSpd, critAirSpdMach: $critAirSpdMach, critGearSpd: $critGearSpd, flap: $flap, critWingOverload: $critWingOverload, engineNum: $engineNum, maxNitro: $maxNitro, nitroConsume: $nitroConsume, critAoA: $critAoA, rpm: $rpm}';
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
