import 'package:color/color.dart' as c;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:wtbgassistant/data/orgb_data_class.dart';
import 'package:wtbgassistant/main.dart';
import 'package:wtbgassistant/screens/widgets/settings_list_custom.dart';
import 'package:wtbgassistant/services/extensions.dart';

class RGBSettings extends ConsumerStatefulWidget {
  const RGBSettings({Key? key}) : super(key: key);

  @override
  RGBSettingsState createState() => RGBSettingsState();
}

class RGBSettingsState extends ConsumerState<RGBSettings> {
  @override
  void initState() {
    super.initState();
  }

  Widget settings(BuildContext context) {
    final orgbSettings = ref.watch(provider.rgbSettingProvider);
    final fireSettings = orgbSettings.fireSettings;
    final overheatSettings = orgbSettings.overHeat;
    final loadingColor = orgbSettings.loadingColor;
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
              title: Row(
                children: [
                  Text('Select Color for Fire',
                      style: TextStyle(
                          color: Color.fromRGBO(
                              fireSettings.color.toRgbColor().r.toInt(),
                              fireSettings.color.toRgbColor().g.toInt(),
                              fireSettings.color.toRgbColor().b.toInt(),
                              1))),
                ],
              ),
              description: const Text('Select the color for the moment you catch fire'),
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
                        title: const Text('Select Fire Color'),
                      );
                    });
                if (colorFire != null) {
                  ref.read(provider.rgbSettingProvider.notifier).state = orgbSettings.copyWith(
                    fireSettings: orgbSettings.fireSettings.copyWith(
                      color: colorFire,
                    ),
                  );
                }
                await orgbSettings.save();
              },
            ),
            SettingsTile(
              title: Row(
                children: [
                  Text('Select Color for Overheat',
                      style: TextStyle(
                          color: Color.fromRGBO(
                              overheatSettings.color.toRgbColor().r.toInt(),
                              overheatSettings.color.toRgbColor().g.toInt(),
                              overheatSettings.color.toRgbColor().b.toInt(),
                              1))),
                ],
              ),
              description: const Text('Select the color for the moment your plane overheats'),
              onPressed: (context) async {
                c.Color? colorOH = await showDialog<c.Color?>(
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
                if (colorOH != null) {
                  ref.read(provider.rgbSettingProvider.notifier).state = orgbSettings.copyWith(
                    overHeat: orgbSettings.overHeat.copyWith(
                      color: colorOH,
                    ),
                  );
                  await orgbSettings.save();
                }
              },
            ),
            SettingsTile(
              title: Row(
                children: [
                  Text('Select Color for Loadings',
                      style: TextStyle(
                          color: Color.fromRGBO(loadingColor.toRgbColor().r.toInt(),
                              loadingColor.toRgbColor().g.toInt(), loadingColor.toRgbColor().b.toInt(), 1))),
                ],
              ),
              description: const Text('This color is used when you are outside of a battle'),
              onPressed: (context) async {
                c.Color? loadingColor = await showDialog<c.Color?>(
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
                        title: const Text('Select Loading Color'),
                      );
                    });
                if (loadingColor != null) {
                  ref.read(provider.rgbSettingProvider.notifier).state =
                      orgbSettings.copyWith(loadingColor: loadingColor);
                  await orgbSettings.save();
                }
              },
            ),
            SettingsTile(
              title: Text('Flash times: ${orgbSettings.flashTimes}'),
              description: const Text('Number of times to flash devices'),
              leading: counter(context, orgbSettings),
            ),
            SettingsTile(
              title: Text('Delay Between Each Flash: ${orgbSettings.delayBetweenFlashes} ms'),
              description: const Text('Delay between each flash for flash (OH and Fire) effects'),
              leading: delayCounter(context, orgbSettings),
            ),
          ],
        ),
      ],
    );
  }

  Widget counter(BuildContext context, OpenRGBSettings orgbSettings) {
    return Column(
      children: [
        IconButton(
            icon: const Icon(FluentIcons.add),
            onPressed: () async {
              ref.read(provider.rgbSettingProvider.notifier).state =
                  orgbSettings.copyWith(flashTimes: orgbSettings.flashTimes + 1);
              await orgbSettings.save();
            }),
        IconButton(
            icon: const Icon(FluentIcons.remove),
            onPressed: () async {
              ref.read(provider.rgbSettingProvider.notifier).state =
                  orgbSettings.copyWith(flashTimes: orgbSettings.flashTimes - 1);
              await orgbSettings.save();
            }),
      ],
    );
  }

  Widget delayCounter(BuildContext context, OpenRGBSettings orgbSettings) {
    return Column(
      children: [
        IconButton(
            icon: const Icon(FluentIcons.add),
            onPressed: () async {
              ref.read(provider.rgbSettingProvider.notifier).state =
                  orgbSettings.copyWith(delayBetweenFlashes: orgbSettings.delayBetweenFlashes + 100);
              await ref.read(provider.rgbSettingProvider).save();
            }),
        IconButton(
            icon: const Icon(FluentIcons.remove),
            onPressed: () async {
              if (ref.read(provider.rgbSettingProvider).delayBetweenFlashes > 50) {
                ref.read(provider.rgbSettingProvider.notifier).state =
                    orgbSettings.copyWith(delayBetweenFlashes: orgbSettings.delayBetweenFlashes - 100);
                await ref.read(provider.rgbSettingProvider).save();
              }
            }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return settings(context);
  }
}
