import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:wtbgassistant/screens/widgets/settings_list_custom.dart';

import '../../main.dart';
import '../loading.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends ConsumerState<Settings> {
  Widget settings(BuildContext context) {
    return CustomizedSettingsList(
        platform: DevicePlatform.web,
        brightness: Brightness.dark,
        darkTheme: const SettingsThemeData(
          settingsListBackground: Colors.transparent,
          settingsSectionBackground: Colors.transparent,
        ),
        sections: [
          SettingsSection(
            title: const Text('Main'),
            tiles: [
              SettingsTile.switchTile(
                initialValue: ref.watch(provider.fullNotifProvider),
                title: const Text('Toggle All Notifications'),
                onToggle: (bool value) {
                  ref.read(provider.fullNotifProvider.notifier).state = value;
                },
              ),
              SettingsTile(
                title: const Text('Reset App Data'),
                description: Text(
                  'Resets ALL app data',
                  style: TextStyle(color: Colors.red),
                ),
                leading: const Icon(FluentIcons.update_restore),
                onPressed: (context) async {
                  showDialog(
                    context: context,
                    builder: (context) => ContentDialog(
                      title: const Text('Reset app'),
                      content: const Text(
                          'Are you sure you want to reset app data?'),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: const Text('Restart'),
                          onPressed: () async {
                            await prefs.clear();
                            if (!mounted) return;
                            Navigator.pushReplacement(
                                context,
                                FluentPageRoute(
                                    builder: (context) => const Loading()));
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          SettingsSection(title: const Text('Notifications'), tiles: [
            SettingsTile.switchTile(
              initialValue: ref.watch(provider.engineDeathNotifProvider),
              title: const Text('Toggle Engine Death Notifier'),
              onToggle: (bool value) {
                ref.read(provider.engineDeathNotifProvider.notifier).state =
                    value;
              },
            ),
            SettingsTile.switchTile(
              initialValue: ref.watch(provider.engineOHNotifProvider),
              title: const Text('Toggle Engine OH Notifier'),
              onToggle: (bool value) {
                ref.read(provider.engineDeathNotifProvider.notifier).state =
                    value;
              },
            ),
            SettingsTile.switchTile(
              initialValue: ref.watch(provider.waterNotifProvider),
              title: const Text('Toggle Water OH Notifier'),
              onToggle: (bool value) {
                ref.read(provider.engineDeathNotifProvider.notifier).state =
                    value;
              },
            ),
          ]),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: settings(context),
    );
  }
}
