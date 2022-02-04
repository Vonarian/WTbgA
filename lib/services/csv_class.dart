import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

String fmPath = p.joinAll([
  p.dirname(Platform.resolvedExecutable),
  'data/flutter_assets/assets',
  'fm_data_db.csv'
]);
List<String>? rowList;

class FmData {
  String name;
  double length;
  double wingSpan;
  double wingArea;
  double emptyMass;
  double maxFuelMass;
  int critAirSpd;
  double airSpdMach;
  int critGearSpd;
  int combatFlaps;
  int takeOffFlaps;
  double flapState1;
  double flapState2;
  double flapDestruction1;
  double flapDestruction2;
  double critWingOverload1;
  double critWingOverload2;
  int engineNum;
  double maxNitro;
  double nitroConsume;
  double critAoa1;
  double critAoa2;
  double critAoa3;
  double critAoa4;

  FmData({
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
  static Future<FmData?> setObject(String name) async {
    rowList ??= convertFmToList(await csvString());
    FmData? fmData;
    for (var element in rowList!.skip(1)) {
      if (element.split(';')[0] == name) {
        fmData = FmData(
            name: element.split(';')[0],
            length: double.parse(element.split(';')[1]),
            wingSpan: double.parse(element.split(';')[2]),
            wingArea: double.parse(element.split(';')[3]),
            emptyMass: double.parse(element.split(';')[4]),
            maxFuelMass: double.parse(element.split(';')[5]),
            critAirSpd: int.parse(element.split(';')[6]),
            airSpdMach: double.parse(element.split(';')[7]),
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
  String csvStr = await File(fmPath).readAsString();
  return csvStr;
}

List<String> convertFmToList(String csvString) {
  List<String> rowList = [];
  for (final rows in LineSplitter.split(csvString)) {
    rowList.add(rows);
  }
  return rowList;
}
