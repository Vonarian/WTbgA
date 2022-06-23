import 'package:firebase_dart/firebase_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtbgassistant/main.dart';
import 'package:wtbgassistant/services/presence.dart';
import 'package:wtbgassistant/services/utility.dart';

class MyProvider {
  final StateProvider<bool> fullNotifProvider = StateProvider((ref) => true);
  final StateProvider<bool> oilNotifProvider = StateProvider((ref) => true);
  final StateProvider<bool> engineOHNotifProvider =
      StateProvider((ref) => true);
  final StateProvider<bool> engineDeathNotifProvider =
      StateProvider((ref) => true);

  final StateProvider<bool> waterNotifProvider = StateProvider((ref) => true);

  final StateProvider<bool> trayProvider = StateProvider((ref) => true);
  final StateProvider<String?> vehicleNameProvider =
      StateProvider((ref) => null);
  final StateProvider<int> gearLimitProvider = StateProvider((ref) => 1000);

  final StateProvider<int> flapLimitProvider = StateProvider((ref) => 800);
  final StateProvider<bool> downloadCompleteProvider =
      StateProvider((ref) => false);
  final deviceIPProvider = FutureProvider.autoDispose<String>(
    (ref) async {
      String ip = await AppUtil.runPowerShellScript(deviceIPPath, []);
      return ip;
    },
  );
  final versionFBProvider = StreamProvider<String>(
    (ref) async* {
      await for (Event e in PresenceService().getVersion()) {
        yield e.snapshot.value.toString();
      }
    },
  );
}
