import 'dart:io';

import 'package:dio/dio.dart';

// Thanks to avb :)
const String fmNames =
    'https://raw.githubusercontent.com/MeSoftHorny/WTRTI-Data/main/FM/fm_names_db.csv';
const String fmData =
    'https://raw.githubusercontent.com/MeSoftHorny/WTRTI-Data/main/FM/fm_data_db.csv';

Future<void> main() async {
  final dio = Dio();

  final names = await dio.get<String>(fmNames);
  final data = await dio.get<String>(fmData);

  if (names.data != null) {
    await File('.\\assets\\fm\\fm_names_db.csv').writeAsString(names.data!);
  }

  if (data.data != null) {
    await File('.\\assets\\fm\\fm_data_db.csv').writeAsString(data.data!);
  }
}
