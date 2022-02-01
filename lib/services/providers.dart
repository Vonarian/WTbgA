import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

final StateProvider<bool> phoneConnectedProvider =
    StateProvider((ref) => false);
final StateProvider<bool> nonePostProvider = StateProvider((ref) => false);

final StateProvider<bool> fullNotifProvider = StateProvider((ref) => true);
final StateProvider<bool> oilNotifProvider = StateProvider((ref) => true);
final StateProvider<bool> engineOhNotifProvider = StateProvider((ref) => true);
final StateProvider<bool> engineDeathNotifProvider =
    StateProvider((ref) => true);

final StateProvider<bool> waterNotifProvider = StateProvider((ref) => true);
final StateProvider<bool> stallNotifProvider = StateProvider((ref) => true);
final StateProvider<bool> pullUpNotifProvider = StateProvider((ref) => true);
// final StateProvider<bool> stallNotifProvider = StateProvider((ref) => true);
// final StateProvider<bool> pullUpNotifProvider = StateProvider((ref) => true);
final StateProvider<bool> trayProvider = StateProvider((ref) => true);
final StateProvider<String> ipAddressProvider = StateProvider((ref) => '');
final StateProvider<String> chatMsgProvider = StateProvider((ref) => '');
final StateProvider<String?> vehicleNameProvider = StateProvider((ref) => null);

final StateProvider<Color> chatColorFirstProvider =
    StateProvider((ref) => Colors.lightBlueAccent);
final StateProvider<Color> chatColorSecondProvider =
    StateProvider((ref) => Colors.lightBlueAccent);
final StateProvider<Color> headerColorProvider =
    StateProvider((ref) => Colors.teal);
final StateProvider<IconData> drawerIconProvider =
    StateProvider((ref) => Icons.settings);
final StateProvider<String> chatPrefixProvider = StateProvider((ref) => '');
final StateProvider<int> gearLimitProvider = StateProvider((ref) => 1000);

final StateProvider<int> flapLimitProvider = StateProvider((ref) => 800);
final StateProvider<int> gLoadProvider = StateProvider((ref) => 18);
final StateProvider<double> transparentFontProvider =
    StateProvider((ref) => 40);
final StateProvider<bool> streamStateProvider = StateProvider((ref) => false);
final StateProvider<String> phoneStateProvider = StateProvider((ref) => '');
