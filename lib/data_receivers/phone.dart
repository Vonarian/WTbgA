// import 'dart:math';
//
// import 'package:flutter/material.dart';
//
// Random random = Random();
//
// class RandomNum extends StatefulWidget {
//   const RandomNum({Key? key}) : super(key: key);
//
//   @override
//   _RandomNumState createState() => _RandomNumState();
// }
//
// class _RandomNumState extends State<RandomNum> {
//   List<Color> someColors = [
//     Colors.indigo,
//     Colors.purple,
//     Colors.redAccent,
//     Colors.green,
//     Colors.teal,
//   ];
//   List<String> facts = [
//     "A crocodile cannot stick its tongue out.",
//     "A shrimp's heart is in its head.",
//     "You burn more calories sleeping than you do watching television.",
//     "A shrimp's heart is in its head.",
//     "It is physically impossible for pigs to look up into the sky.",
//     "In the course of an average lifetime, while sleeping you might eat around 70 assorted insects and 10 spiders, or more."
//   ];
//   String getRandomElement(List<String> list) {
//     var i = random.nextInt(list.length);
//     return list[i];
//   }
//
//   late var elementText = getRandomElement(facts);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: someColors[Random().nextInt(someColors.length)],
//       child: ElevatedButton(
//         onPressed: () {
//           setState(() {
//             elementText = getRandomElement(facts);
//           });
//         },
//         child: Text(elementText),
//       ),
//     );
//   }
// }
