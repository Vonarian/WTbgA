import 'dart:convert';

import 'package:color/color.dart' as c;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openrgb/data/rgb_controller.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:wtbgassistant/data/orgb_data_class.dart';
import 'package:wtbgassistant/screens/widgets/settings_list_custom.dart';
import 'package:wtbgassistant/services/extensions.dart';

import '../../main.dart';

class ORGBSettings extends ConsumerStatefulWidget {
  const ORGBSettings({Key? key}) : super(key: key);

  @override
  ORGBSettingsState createState() => ORGBSettingsState();
}

class ORGBSettingsState extends ConsumerState<ORGBSettings> {
  List<RGBController>? controllers;

  Widget settings(BuildContext context) {
    return CustomizedSettingsList(
      platform: DevicePlatform.web,
      brightness: Brightness.dark,
      darkTheme: const SettingsThemeData(
        settingsListBackground: Colors.transparent,
        settingsSectionBackground: Colors.transparent,
      ),
      contentPadding: EdgeInsets.zero,
      sections: [
        SettingsSection(
          title: const Text('OpenRGB'),
          tiles: [
            SettingsTile(
              title: const Text('Select Color Settings'),
              onPressed: (context) async {
                c.Color? colorFire = await showDialog<c.Color?>(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) {
                      c.Color? internalColor;

                      return ContentDialog(
                        content: MaterialPicker(
                            pickerColor: Colors.grey,
                            onColorChanged: (color) {
                              if (!mounted) return;
                              Navigator.pop(context, color.toRGB());
                            }),
                        actions: [
                          TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop(null);
                              }),
                          TextButton(
                              child: const Text('Set Color'),
                              onPressed: () {
                                Navigator.of(context).pop(internalColor);
                              }),
                        ],
                        title: const Text('Select Fire Color'),
                      );
                    });
                if (colorFire.notNull) {
                  c.Color? colorOh = await showDialog<c.Color?>(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        c.Color? internalColor;
                        return ContentDialog(
                          content: MaterialPicker(
                              pickerColor: Colors.grey,
                              onColorChanged: (color) {
                                internalColor = color.toRGB();
                              }),
                          actions: [
                            TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop(null);
                                }),
                            TextButton(
                                child: const Text('Set Color'),
                                onPressed: () {
                                  Navigator.of(context).pop(internalColor);
                                }),
                          ],
                          title: const Text('Select Overheat Color'),
                        );
                      });
                  if (colorOh.notNull) {
                    OpenRGBSettings settings = OpenRGBSettings(
                      overHeat: OverHeatSettings(color: colorOh!),
                      fireSettings: FireSettings(color: colorFire!),
                    );
                    await prefs.setString(
                        'openrgb',
                        jsonEncode(settings.toMap(), toEncodable: (Object? value) {
                          if (value is c.Color) {
                            return value.toStringHex();
                          } else {
                            return value;
                          }
                        }));
                  }
                }
              },
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return settings(context);
  }
}
