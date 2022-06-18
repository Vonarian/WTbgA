import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtbgassistant/services/extensions.dart';

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

final StateProvider<bool> trayProvider = StateProvider((ref) => true);
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

final StateProvider<String> rgbProvider =
    StateProvider((ref) => Colors.white.toHex());
