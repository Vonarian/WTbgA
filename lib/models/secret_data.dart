import 'dart:developer';

import 'package:firebase_dart/firebase_dart.dart';

import '../services/extensions.dart';

class SecretData {
  final FirebaseOptions? firebaseData;

  const SecretData({this.firebaseData});

  factory SecretData.load() {
    try {
      const firebaseData = String.fromEnvironment('firebaseData');
      return SecretData(
        firebaseData: firebaseData.isNotEmpty
            ? FirebaseOptions.fromMap(firebaseData.decodeJson())
            : null,
      );
    } catch (e, st) {
      log(e.toString(), stackTrace: st);
      return const SecretData();
    }
  }

  bool get firebaseValid => firebaseData != null;

  bool get firebaseInvalid => !firebaseValid;
}
