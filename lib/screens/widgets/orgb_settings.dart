import 'dart:convert';

import 'package:color/color.dart' as c;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openrgb/data/rgb_controller.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:wtbgassistant/data/orgb_data_class.dart';
import 'package:wtbgassistant/main.dart';
import 'package:wtbgassistant/screens/widgets/settings_list_custom.dart';
import 'package:wtbgassistant/services/extensions.dart';

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
              title: const Text('OpenRGB'),
              description: const Text('Select Color And Mode'),
              leading: const Icon(FluentIcons.keyboard_classic),
              onPressed: (context) async {
                controllers = await ref.watch(provider.orgbClientProvider)!.getAllControllers();
                await ref.read(provider.orgbClientProvider)?.updateLeds(2, 2, Colors.red.toRGB());
                if (controllers.notNull) {
                  showBottomSheet(
                      context: context,
                      builder: (context) {
                        return Column(
                          children: [
                            GestureDetector(
                              child: SizedBox(
                                height: 50,
                                child: ListTile(
                                  title: Text(
                                    'Close',
                                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                  trailing: Icon(
                                    FluentIcons.close_pane,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: controllers!.length,
                                itemBuilder: (context, index) {
                                  final controller = controllers![index];
                                  return GestureDetector(
                                    child: ListTile(
                                      title: Text(controller.name),
                                      subtitle: Text(controller.vendor),
                                    ),
                                    onTap: () {
                                      showDialog(
                                          barrierDismissible: true,
                                          context: context,
                                          builder: (context) {
                                            return ContentDialog(
                                              content: ListView.builder(
                                                  itemCount: controller.modes.length,
                                                  itemBuilder: (context, i) {
                                                    final mode = controller.modes[i];
                                                    return GestureDetector(
                                                      child: ListTile(
                                                        title: Text(mode.modeName),
                                                        subtitle: Text(mode.modeNumColors < 1
                                                            ? 'No Colors to Set'
                                                            : '${mode.modeNumColors} color(s)'),
                                                      ),
                                                      onTap: () async {
                                                        c.Color? color;
                                                        if (mode.modeNumColors > 0) {
                                                          color = await showDialog<c.Color>(
                                                              context: context,
                                                              builder: (context) {
                                                                Color internalColor = Colors.red;
                                                                return ContentDialog(
                                                                  content: MaterialPicker(
                                                                      pickerColor: Colors.grey,
                                                                      onColorChanged: (color) {
                                                                        internalColor = color;
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
                                                                          Navigator.of(context)
                                                                              .pop(internalColor.toRGB());
                                                                        }),
                                                                  ],
                                                                );
                                                              });
                                                        }
                                                        if (color.notNull) {
                                                          OpenRGBSettings openRGBSettings = OpenRGBSettings(
                                                              overHeat: OverHeatSettings(color: color!, mode: mode, controllerId: index),
                                                              fireSettings: FireSettings(color: color, mode: mode, controllerId: index));
                                                          await prefs.setString(
                                                              'orgbSettings', json.encode(openRGBSettings.toMap()));
                                                          openRGBSettings.setAll(ref.read(provider.orgbClientProvider)!);
                                                        }
                                                        if (!mounted) return;
                                                        Navigator.pop(context);
                                                      },
                                                    );
                                                  }),
                                            );
                                          });
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      });
                }
              },
            ),
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
