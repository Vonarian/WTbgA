import 'package:audioplayers/audioplayers.dart';
import '../main.dart';

import 'app_settings.dart';

class PullUpData {
  ///Play warning by checking if the altitude is dangerous.
  static Future<void> checkAndPlayWarning(
      int alt, double climb, AppSettings settings) async {
    final double secondsToCrash = alt / climb.abs();
    if (secondsToCrash <= 4) {
      await audio2.play(DeviceFileSource(settings.pullUpSetting.path),
          volume: settings.pullUpSetting.volume, mode: PlayerMode.lowLatency);
    }
  }
}
