// import 'package:flutter/material.dart';
//
// class InputMessage extends StatelessWidget {
//   TextEditingController inputMessageController = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     var variables = Provider.of<Variables>(context);
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//       margin: const EdgeInsets.only(top: 10),
//       decoration: const BoxDecoration(color: Colors.white),
//       child: Row(
//         children: [
//           IconButton(
//             onPressed: () {
//               // print(variables.keyboardController.canRequestFocus);
//               // variables.keyboardController.requestFocus();
//             },
//             icon: const Icon(Icons.camera_alt, color: Colors.black54),
//           ),
//           Container(
//             width: MediaQuery.of(context).size.width * 0.7,
//             child: TextField(
//               onSubmitted: (text) {
//                 variables.changeVariable("messageText", text);
//               },
//               onChanged: (text) {
//                 print(variables.localData['messageText']);
//               },
//               minLines: 1,
//               maxLines: 4,
//               keyboardType: TextInputType.multiline,
//               controller: inputMessageController,
//               decoration: const InputDecoration(
//                 border: InputBorder.none,
//                 focusedBorder: InputBorder.none,
//                 enabledBorder: InputBorder.none,
//                 disabledBorder: InputBorder.none,
//                 errorBorder: InputBorder.none,
//                 focusedErrorBorder: InputBorder.none,
//                 hintText: "پیام را وارد کنید",
//               ),
//             ),
//           ),
//           variables.localData['messageText'] != ""
//               ? IconButton(
//                   onPressed: () {
//                     // variables.changeVariable("messageText" , variables.localData['textValue']);
//                     // variables.changeVariable("isTyping", false);
//                     // variables.changeVariable("textValue","");
//                     // variables.keyboardController1.text = "";
//                     inputMessageController.clear();
//                     variables.changeVariable("messageText", "");
//                     print(
//                         "SENT WITH VALUE \"${variables.localData['messageText']}\"");
//                   },
//                   icon: const Icon(
//                     Icons.send,
//                     color: Colors.blue,
//                   ))
//               : RotationTransition(
//                   turns: const AlwaysStoppedAnimation(220 / 360),
//                   child: IconButton(
//                     onPressed: () {},
//                     icon: const Icon(
//                       Icons.attach_file,
//                       color: Colors.black54,
//                       size: 26,
//                     ),
//                   ),
//                 )
//         ],
//       ),
//     );
//   }
// }
