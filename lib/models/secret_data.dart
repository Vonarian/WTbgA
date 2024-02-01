import 'dart:developer';

import 'package:firebase_dart/firebase_dart.dart';

import '../services/extensions.dart';

class SecretData {
  final FirebaseOptions? firebaseData;
  final String? gh;

  const SecretData({required this.firebaseData, required this.gh});

  factory SecretData.load() {
    try {
      const firebaseData = String.fromEnvironment('firebaseData');
      const ghString = String.fromEnvironment('gh');
      return SecretData(
          firebaseData: firebaseData.isNotEmpty
              ? FirebaseOptions.fromMap(firebaseData.decode())
              : null,
          gh: ghString.isNotEmpty ? ghString : null);
    } catch (e, st) {
      log(e.toString(), stackTrace: st);
      return const SecretData(firebaseData: null, gh: null);
    }
  }

  bool get firebaseValid => firebaseData != null;
}
