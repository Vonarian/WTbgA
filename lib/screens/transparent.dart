// import 'dart:async';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_acrylic/flutter_acrylic.dart';
// import 'package:hotkey_manager/hotkey_manager.dart';
// import 'package:screen_recorder/screen_recorder.dart';
//
// import 'home.dart';
//
// class TransparentPage extends StatefulWidget {
//   @override
//   _TransparentPageState createState() => _TransparentPageState();
// }
//
// class _TransparentPageState extends State<TransparentPage> {
//   AcrylicEffect effect = AcrylicEffect.transparent;
//   Color color = Platform.isWindows ? Color(0x00222222) : Colors.transparent;
//   // keyRegister() async {
//   //
//   // }
//
//   keyRegister() async {
//     HotKeyManager.instance.register(
//       HotKey(
//         KeyCode.digit5,
//         modifiers: [KeyModifier.alt],
//       ),
//       keyDownHandler: (_) async {
//         bool isVisible = await windowManager.isVisible();
//         if (isVisible) {
//           windowManager.hide();
//         } else {
//           windowManager.show();
//         }
//       },
//     );
//     HotKeyManager.instance.register(
//         HotKey(
//           KeyCode.delete,
//           modifiers: [KeyModifier.alt],
//         ), keyDownHandler: (_) {
//       windowManager.terminate();
//     });
//     bool isAlwaysOnTop = await windowManager.isAlwaysOnTop();
//
//     HotKeyManager.instance.register(
//       HotKey(
//         KeyCode.keyT,
//         modifiers: [KeyModifier.control, KeyModifier.shift],
//       ),
//       keyDownHandler: (_) async {
//         windowManager.setAlwaysOnTop(!isAlwaysOnTop);
//         Future.delayed(Duration(milliseconds: 200));
//         isAlwaysOnTop = await windowManager.isAlwaysOnTop();
//         await windowManager.setAsFrameless();
//         controller.start();
//         print(isAlwaysOnTop);
//       },
//     );
//     HotKeyManager.instance.register(
//         HotKey(
//           KeyCode.keyB,
//           modifiers: [KeyModifier.alt],
//         ), keyDownHandler: (_) {
//       if (mounted) {
//         Navigator.pushReplacementNamed(context, '/home');
//       }
//     });
//   }
//
//   @override
//   void initState() {
//     keyRegister();
//     super.initState();
//     this.setWindowEffect(this.effect);
//   }
//
//   void setWindowEffect(AcrylicEffect? value) {
//     Acrylic.setEffect(effect: value!, gradientColor: this.color);
//     this.setState(() => this.effect = value);
//   }
//
//   late var controller = ScreenRecorderController(
//     pixelRatio: 0.5,
//     skipFramesBetweenCaptures: 2,
//   );
//   @override
//   Widget build(BuildContext context) {
//     return ScreenRecorder(
//         controller: controller,
//         height: MediaQuery.of(context).size.height,
//         width: MediaQuery.of(context).size.width,
//         child: Container());
//   }
// }
//Server HERE:::::::====>>>
// String? imageData;
// Future<void> startServer() async {
//   HttpServer.bind(InternetAddress.anyIPv4, 80).then((server) {
//     server.listen((HttpRequest request) async {
//       ContentType? contentType = request.headers.contentType;
//       if (request.method == 'POST' &&
//           contentType!.mimeType == 'application/json') {
//         String content = await utf8.decoder.bind(request).join();
//         Map<String?, dynamic> data = jsonDecode(content);
//         phoneConnected.value = data['WTbgA'];
//         phoneState.value = data['state'];
//         nonePost = false;
//         headerColor = Colors.deepPurple;
//         drawerIcon = Icons.settings;

//         request.response.write(jsonEncode(serverData));
//         request.response.close();
//       } else {
//         phoneConnected.value = false;
//         String serverData = 'ACCESS DENIED';
//         nonePost = true;
//         headerColor = Colors.red;
//         drawerIcon = Icons.warning;
//         request.response.write(serverData);
//         request.response.close();
//       }
//     });
//   });
// }
