import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';

bool? active;
Future<bool?> getData(url) async {
  try {
    await get(Uri.parse("http://$url:54338"));
    active = await true;
    // print('true');
    return active;
  } catch (e, stackTrace) {
    log('Encountered error: $e', stackTrace: stackTrace);
    // print('false');
    active = await false;
    return active;
  }
}

Future<Map> getPhoneState(url) async {
  Response? response = await get(Uri.parse("http://$url:54338"));
  Map<String?, String?> data = await jsonDecode(response.body);
  return data;
}

// getData(url) async {
//   if (await canLaunch("http://$url:54338")) {
//     print(await canLaunch("http://$url:54338"));
//     return true;
//   } else {
//     return false;
//   }
// }
