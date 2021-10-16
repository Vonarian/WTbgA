// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:http/http.dart';
//
// class PhoneData {
//   bool? active;
//   String? state;
//   PhoneData({
//     this.active,
//     this.state,
//   });
//   static Future<PhoneData> getPhoneData(ip) async {
//     try {
//       Response? response = await get(Uri.parse("http://$ip:54338"));
//       Map<String?, dynamic> data = jsonDecode(response.body);
//       return PhoneData(active: data['active'], state: data['state']);
//     } catch (e, stackTrace) {
//       log('Encountered error: $e', stackTrace: stackTrace);
//       rethrow;
//     }
//   }
// }

// getData(url) async {
//   if (await canLaunch("http://$url:54338")) {
//     print(await canLaunch("http://$url:54338"));
//     return true;
//   } else {
//     return false;
//   }
// }
