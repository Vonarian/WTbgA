import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}
