import 'dart:async';

import 'package:firebase_dart/database.dart';
import 'package:intl/intl.dart';

import '../data/firebase.dart';
import '../main.dart';

class PresenceService {
  FirebaseDatabase database = FirebaseDatabase(app: app, databaseURL: dataBaseUrl);
  StreamSubscription? subscription;
  DatabaseReference? con;

  Future<void> configureUserPresence(String uid, String version) async {
    final uidRef = database.reference().child('presence').child(uid);
    final myConnectionsRef = uidRef.child('connected');
    final lastOnlineRef = uidRef.child('lastOnline');
    final userNameRef = uidRef.child('username');
    final versionRef = uidRef.child('version');
    await database.goOnline();
    String? userName = prefs.getString('userName');
    if (userName != '' && userName != null) {
      userNameRef.set(userName);
    }
    versionRef.set(version);
    subscription = database.reference().child('.info/connected').onValue.listen((event) async {
      if (event.snapshot.value) {
        con = myConnectionsRef;
        con?.onDisconnect().set(false);
        con?.set(true);
        DateFormat f = DateFormat('E, d MMM yyyy HH:mm:ss');
        String date = '${f.format(DateTime.now().toUtc())} GMT';
        lastOnlineRef.onDisconnect().set(date);
      }
    });
  }

  Stream<Event> getVersion() {
    final versionRef = database.reference().child('version');
    final sub = versionRef.onValue;
    return sub.asBroadcastStream();
  }

  void connect() {
    database.goOnline();
  }

  void disconnect({bool signOut = false}) {
    if (signOut && subscription != null) {
      subscription?.cancel();
    }
    database.goOffline();
  }
}
