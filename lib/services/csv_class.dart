import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

String fmPath = p.joinAll([
  p.dirname(Platform.resolvedExecutable),
  'data/flutter_assets/assets',
  'fm_data_db.csv'
]);

class FmData {
  final String name;
  final double length;
  final double wingSpan;
  final double wingArea;
  final double emptyMass;
  final double maxFuelMass;
  final int critAirSpd;
  final double airSpdMach;
  final int critGearSpd;
  final int combatFlaps;
  final int takeOffFlaps;
  final double flapState1;
  final double flapState2;
  final double flapDestruction1;
  final double flapDestruction2;
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
    required this.airSpdMach,
    required this.critGearSpd,
    required this.combatFlaps,
    required this.takeOffFlaps,
    required this.flapState1,
    required this.flapState2,
    required this.flapDestruction1,
    required this.flapDestruction2,
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
    final rowList = convertFmToList(await csvString());
    FmData? fmData;
    if (name == null) return null;
    for (var element in rowList.skip(1)) {
      if (element.split(';')[0] == name) {
        fmData = FmData(
            name: element.split(';')[0],
            length: double.parse(element.split(';')[1]),
            wingSpan: !element.split(';')[2].contains(',')
                ? double.parse(element.split(';')[2])
                : 0,
            wingArea: !element.split(';')[3].contains(',')
                ? double.parse(element.split(';')[3])
                : 0,
            emptyMass: double.parse(element.split(';')[4]),
            maxFuelMass: double.parse(element.split(';')[5]),
            critAirSpd: !element.split(';')[6].contains(',')
                ? int.parse(element.split(';')[6])
                : 2000,
            airSpdMach: !element.split(';')[7].contains(',')
                ? double.parse(element.split(';')[7])
                : 2,
            critGearSpd: int.parse(element.split(';')[8]),
            combatFlaps: int.parse(element.split(';')[9]),
            takeOffFlaps: int.parse(element.split(';')[10]),
            flapState1: element.split(';')[11].isNotEmpty
                ? double.parse(element.split(';')[11].split(',')[0])
                : 0,
            flapState2: element.split(';')[11].isNotEmpty
                ? double.parse(element.split(';')[11].split(',')[2])
                : 0,
            flapDestruction1: element.split(';')[11].isNotEmpty
                ? double.parse(element.split(';')[11].split(',')[1])
                : 0,
            flapDestruction2: element.split(';')[11].isNotEmpty
                ? double.parse(element.split(';')[11].split(',')[3])
                : 0,
            critWingOverload1:
                double.parse(element.split(';')[12].split(',').first)
                    .toDouble(),
            critWingOverload2:
                double.parse(element.split(';')[12].split(',').last),
            engineNum: int.parse(element.split(';')[13]),
            maxNitro: double.parse(element.split(';')[14]),
            nitroConsume: double.parse(element.split(';')[15]),
            critAoa1: double.parse(element.split(';')[16].split(',')[0]),
            critAoa2: double.parse(element.split(';')[16].split(',')[1]),
            critAoa3: double.parse(element.split(';')[16].split(',')[2]),
            critAoa4: double.parse(element.split(';')[16].split(',')[3]));
      }
    }
    return fmData;
  }
}

Future<String> csvString() async {
  final String csvStr = await File(fmPath).readAsString();
  return csvStr;
}

List<String> convertFmToList(String csvString) {
  final List<String> rowList = [];
  for (final rows in LineSplitter.split(csvString)) {
    rowList.add(rows);
  }
  return rowList;
}
