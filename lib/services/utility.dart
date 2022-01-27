import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firedart/auth/firebase_auth.dart';
import 'package:firedart/auth/token_store.dart';
import 'package:firedart/auth/user_gateway.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wtbgassistant/screens/vars.dart';

class AppUtil {
  static Future<String> createFolderInAppDocDir(String path) async {
    //Get this App Document Directory

    //App Document Directory + folder name
    final Directory _appDocDirFolder = Directory(path);

    try {
      if (await _appDocDirFolder.exists()) {
        //if folder already exists return path
        return _appDocDirFolder.path;
      } else {
        //if folder not exists create folder and then return its path
        final Directory _appDocDirNewFolder =
            await _appDocDirFolder.create(recursive: true);
        return _appDocDirNewFolder.path;
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

class PreferencesStore extends TokenStore {
  static const keyToken = 'auth_token';

  static Future<PreferencesStore> create() async =>
      PreferencesStore._internal(await SharedPreferences.getInstance());

  SharedPreferences _prefs;

  PreferencesStore._internal(this._prefs);

  @override
  Token? read() => _prefs.containsKey(keyToken)
      ? Token.fromMap(json.decode(_prefs.get(keyToken) as String))
      : null;

  @override
  void write(Token? token) => token != null
      ? _prefs.setString(keyToken, json.encode(token.toMap()))
      : null;

  @override
  void delete() => _prefs.remove(keyToken);
}

final FirebaseAuth _auth = FirebaseAuth.instance;
String? uid;
String? name;
String? userEmail;
Future<User?> registerWithEmailPassword(String email, String password) async {
  if (Firebase.apps == '[DEFAULT]') {
    Firebase.initializeApp(options: firebaseOptions);
  } else {
    Firebase.app();
  }
  User? user;

  try {
    User userCredential = await _auth.signUp(email, password);

    user = userCredential;

    uid = user.id;
    userEmail = user.email;
  } on FirebaseException catch (e) {
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      print('An account already exists for that email.');
    }
  } catch (e) {
    print(e);
  }

  return user;
}

Future<User?> signInWithEmailPassword(String email, String password) async {
  if (Firebase.apps == '[DEFAULT]') {
    Firebase.initializeApp(options: firebaseOptions);
  } else {
    Firebase.app();
  }
  User? user;

  try {
    User userCredential = await _auth.signIn(
      email,
      password,
    );
    user = userCredential;

    if (user != null) {
      uid = user.id;
      userEmail = user.email;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auth', true);
    }
  } on FirebaseException catch (e) {
    if (e.code == 'user-not-found') {
      print('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      print('Wrong password provided.');
    }
  }

  return user;
}

Future<String> signOut() async {
  _auth.signOut();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('auth', false);

  uid = null;
  userEmail = null;

  return 'User signed out';
}

FirebaseOptions firebaseOptions = FirebaseOptions(
  appId: fireBaseConfig['appId'] ?? '',
  apiKey: fireBaseConfig['apiKey'] ?? '',
  projectId: fireBaseConfig['projectId'] ?? '',
  messagingSenderId: fireBaseConfig['messagingSenderId'] ?? '',
  authDomain: fireBaseConfig['authDomain'],
);
