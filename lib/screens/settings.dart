import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:openrgb/data/rgb_controller.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../main.dart';
import '../models/data_class.dart';
import '../models/settings/app_settings.dart';
import '../services/extensions.dart';
import 'downloader.dart';
import 'widgets/card_highlight.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends ConsumerState<Settings> {
  List<RGBController>? controllersData;
  final scrollController = ScrollController(keepScrollOffset: true);

  Widget updateWidget(String version, {required FluentThemeData theme}) {
    return CardHighlight(
      leading: const Icon(FluentIcons.update_restore),
      title: Text(
        'New Update!',
        style: theme.typography.bodyStrong?.copyWith(
          color: theme.accentColor.lightest,
        ),
      ),
      description: Text('$version is available to download'),
      trailing: Button(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (_) => theme.accentColor.lighter,
          ),
        ),
        onPressed: () {
          Navigator.of(context).pushReplacement(
            FluentPageRoute(
              builder: (context) {
                return const Downloader();
              },
            ),
          );
        },
        child: const Text('Update'),
      ),
    );
  }

  Widget settings(BuildContext context) {
    final appSettings = ref.watch(provider.appSettingsProvider);
    final appSettingsNotifier = ref.read(provider.appSettingsProvider.notifier);
    final firebaseVersion = ref.watch(
      provider.versionFBProvider(secrets.firebaseValid),
    );
    final theme = FluentTheme.of(context);
    return ScaffoldPage(
      header: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Text('Settings', style: theme.typography.title),
      ),
      content: SingleChildScrollView(
        controller: scrollController,
        child: Card(
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (secrets.firebaseValid)
                firebaseVersion.when(
                  data: (data) => data != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('Updates', style: theme.typography.bodyStrong),
                            const SizedBox(height: 6.0),
                            updateWidget(data.toString(), theme: theme),
                          ],
                        )
                      : const SizedBox(),
                  error: (_, _) => const SizedBox(),
                  loading: () => const SizedBox(),
                ),
              Text('Main', style: theme.typography.bodyStrong),
              CardHighlight(
                leading: const Icon(FluentIcons.important, size: 20),
                title: Text('Toggle All', style: theme.typography.body),
                description: Text(
                  'Toggles all notifiers at once',
                  style: theme.typography.caption,
                ),
                trailing: ToggleSwitch(
                  checked: appSettings.fullNotif,
                  onChanged: (value) async {
                    appSettingsNotifier.setFullNotif(value);
                  },
                ),
              ),
              CardHighlight(
                title: const Text('Reset App Data'),
                description: Text(
                  'Resets ALL app data including preferences and settings',
                  style: TextStyle(color: Colors.red),
                ),
                leading: const Icon(FluentIcons.update_restore),
                trailing: IconButton(
                  icon: Icon(FluentIcons.update_restore, color: Colors.red),
                  onPressed: () async {
                    await prefs.clear();
                    final exePath = Platform.resolvedExecutable;
                    await Process.start(
                      exePath,
                      [],
                      mode: ProcessStartMode.detached,
                    );
                    // Exit the current process
                    exit(0);
                  },
                ),
              ),
              Text('Notifiers', style: theme.typography.bodyStrong),
              CardHighlight(
                leading: const Icon(FluentIcons.alert_settings, size: 20),
                title: Text('Engine Warnings', style: theme.typography.body),
                description: Text(
                  'Enables/Disables engine warnings',
                  style: theme.typography.caption,
                ),
                trailing: ToggleSwitch(
                  checked: appSettings.engineWarning.enabled,
                  onChanged: (value) async {
                    appSettingsNotifier.setEngineWarning(enabled: value);
                  },
                ),
              ),
              CardHighlight(
                leading: const Icon(FluentIcons.alert_settings, size: 20),
                title: Text('Overheat Warnings', style: theme.typography.body),
                description: Text(
                  'Enables/Disables engine warnings',
                  style: theme.typography.caption,
                ),
                trailing: ToggleSwitch(
                  checked: appSettings.overHeatWarning.enabled,
                  onChanged: (value) async {
                    appSettingsNotifier.setOverHeatWarning(enabled: value);
                  },
                ),
              ),
              CardHighlight(
                leading: const Icon(FluentIcons.alert_settings, size: 20),
                title: Text('OverG Warnings', style: theme.typography.body),
                description: Text(
                  'Enables/Disables OverG warnings',
                  style: theme.typography.caption,
                ),
                trailing: ToggleSwitch(
                  checked: appSettings.overGWarning.enabled,
                  onChanged: (value) async {
                    appSettingsNotifier.setOverGWarning(enabled: value);
                  },
                ),
              ),
              CardHighlight(
                leading: const Icon(FluentIcons.alert_settings, size: 20),
                title: Text('Pull up Warnings', style: theme.typography.body),
                description: Text(
                  'Enables/Disables Pull up warnings',
                  style: theme.typography.caption,
                ),
                trailing: ToggleSwitch(
                  checked: appSettings.pullUpSetting.enabled,
                  onChanged: (value) async {
                    appSettingsNotifier.setPullUpSetting(enabled: value);
                  },
                ),
              ),
              CardHighlight(
                leading: const Icon(FluentIcons.close_pane_mirrored, size: 20),
                title: Text('Proximity Warnings', style: theme.typography.body),
                description: Text(
                  'Enables/Disables Proximity warnings',
                  style: theme.typography.caption,
                ),
                trailing: ToggleSwitch(
                  checked: appSettings.proximitySetting.enabled,
                  onChanged: (value) async {
                    appSettingsNotifier.setProximitySetting(enabled: value);
                  },
                ),
              ),
              if (secrets.firebaseValid)
                Text('Misc', style: theme.typography.bodyStrong),
              if (secrets.firebaseValid)
                CardHighlight(
                  leading: const Icon(FluentIcons.account_management, size: 20),
                  title: Text('Update nickname', style: theme.typography.body),
                  description: Text(
                    'Your game nickname: Used for providing help/support when needed',
                    style: theme.typography.caption,
                  ),
                  onPressed: () async {
                    await Message.getUserNameCustom(context, null);
                  },
                ),
              Text('About', style: theme.typography.bodyStrong),
              Card(
                borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                padding: const EdgeInsets.only(bottom: 5, top: 5),
                margin: const EdgeInsets.only(right: 30),
                child: Expander(
                  animationDuration: const Duration(milliseconds: 150),
                  onStateChanged: (state) async {
                    if (state) {
                      await Future.delayed(const Duration(milliseconds: 151));
                      scrollController.animateTo(
                        scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  leading: Image.asset(
                    'assets/app_icon.ico',
                    height: 25,
                    filterQuality: FilterQuality.high,
                    isAntiAlias: true,
                  ),
                  headerBackgroundColor: WidgetStateProperty.resolveWith(
                    (_) => Colors.transparent,
                  ),
                  contentBackgroundColor: Colors.transparent,
                  header: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WTbgA', style: theme.typography.body),
                      Text('2025 Vonarian 😎', style: theme.typography.caption),
                    ],
                  ),
                  trailing: Text(appVersion.toString()),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'WTbgA is an open-source program voluntarily developed by Vonarian.\nFeel free to contact me via the following methods:',
                      ),
                      const Gap(5),
                      Tooltip(
                        message:
                            'Open https://github.com/Vonarian/WTbgA in browser',
                        child: ListTile(
                          leading: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(FluentIcons.open_source, size: 20),
                          ),
                          title: const Text('Github'),
                          subtitle: Text(
                            'Issues, feedback and feature requests can be discussed here.',
                            style: theme.typography.caption,
                          ),
                          onPressed: () {
                            launchUrlString(
                              'https://github.com/Vonarian/WTbgA',
                            );
                          },
                        ),
                      ),
                      Tooltip(
                        message:
                            'Open https://forum.warthunder.com/u/Vonarian/ in browser',
                        child: ListTile(
                          leading: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(FluentIcons.office_chat, size: 20),
                          ),
                          title: const Text('WT Forums'),
                          subtitle: Text(
                            'Contact me in the forums.',
                            style: theme.typography.caption,
                          ),
                          onPressed: () {
                            launchUrlString(
                              'https://forum.warthunder.com/u/Vonarian/',
                            );
                          },
                        ),
                      ),
                      Tooltip(
                        message:
                            'Open https://discord.gg/8HfGR3mubx in browser',
                        child: ListTile(
                          leading: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(FluentIcons.chat, size: 20),
                          ),
                          title: const Text('Discord Server'),
                          subtitle: Text(
                            'Vonarian\'s Chilling Zone! 🙂 You can share feedback and discuss stuff easier here.',
                            style: theme.typography.caption,
                          ),
                          onPressed: () {
                            launchUrlString('https://discord.gg/8HfGR3mubx');
                          },
                        ),
                      ),
                    ].withDividerBetween(context),
                  ),
                ),
              ),
            ].withSpaceBetween(6.0),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderEngine(AppSettings appSettings) {
    return Row(
      children: [
        Slider(
          value: appSettings.engineWarning.volume,
          min: 0,
          max: 100,
          divisions: 100,
          label: '${appSettings.engineWarning.volume.toInt()} %',
          onChanged: (value) async {
            ref
                .read(provider.appSettingsProvider.notifier)
                .setEngineWarning(volume: value);
          },
          vertical: true,
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(FluentIcons.play),
          onPressed: () async {
            await audio1.play(
              DeviceFileSource(appSettings.engineWarning.path),
              volume: appSettings.engineWarning.volume / 100,
              mode: PlayerMode.lowLatency,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSliderOverHeat(AppSettings appSettings) {
    return Row(
      children: [
        Slider(
          value: appSettings.overHeatWarning.volume,
          min: 0,
          max: 100,
          divisions: 100,
          label: '${appSettings.overHeatWarning.volume.toInt()} %',
          onChanged: (value) async {
            ref
                .read(provider.appSettingsProvider.notifier)
                .setOverHeatWarning(volume: value);
          },
          vertical: true,
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(FluentIcons.play),
          onPressed: () async {
            await audio1.play(
              DeviceFileSource(appSettings.overHeatWarning.path),
              volume: appSettings.overHeatWarning.volume / 100,
              mode: PlayerMode.lowLatency,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSliderOverG(AppSettings appSettings) {
    return Row(
      children: [
        Slider(
          value: appSettings.overGWarning.volume,
          min: 0,
          max: 100,
          divisions: 100,
          label: '${appSettings.overGWarning.volume.toInt()} %',
          onChanged: (value) async {
            ref
                .read(provider.appSettingsProvider.notifier)
                .setOverGWarning(volume: value);
          },
          vertical: true,
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(FluentIcons.play),
          onPressed: () async {
            await audio1.play(
              DeviceFileSource(appSettings.overGWarning.path),
              volume: appSettings.overGWarning.volume / 100,
              mode: PlayerMode.lowLatency,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSliderPullUP(AppSettings appSettings) {
    return Row(
      children: [
        Slider(
          value: appSettings.pullUpSetting.volume,
          min: 0,
          max: 100,
          divisions: 100,
          label: '${appSettings.pullUpSetting.volume.toInt()} %',
          onChanged: (value) async {
            ref
                .read(provider.appSettingsProvider.notifier)
                .setPullUpSetting(volume: value);
          },
          vertical: true,
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(FluentIcons.play),
          onPressed: () async {
            await audio1.play(
              DeviceFileSource(appSettings.pullUpSetting.path),
              volume: appSettings.pullUpSetting.volume / 100,
              mode: PlayerMode.lowLatency,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSliderProxy(AppSettings appSettings) {
    return Row(
      children: [
        Slider(
          value: appSettings.proximitySetting.volume,
          min: 0,
          max: 100,
          divisions: 100,
          label: '${appSettings.proximitySetting.volume.toInt()} %',
          onChanged: (value) async {
            ref
                .read(provider.appSettingsProvider.notifier)
                .setProximitySetting(volume: value);
          },
          vertical: true,
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(FluentIcons.play),
          onPressed: () async {
            await audio1.play(
              DeviceFileSource(appSettings.proximitySetting.path),
              volume: appSettings.proximitySetting.volume / 100,
              mode: PlayerMode.lowLatency,
            );
          },
        ),
      ],
    );
  }

  Widget _distance(BuildContext context, AppSettings appSettings) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(FluentIcons.add),
          onPressed: () async {
            ref
                .read(provider.appSettingsProvider.notifier)
                .setProximitySetting(
                  distance:
                      ref
                          .read(provider.appSettingsProvider)
                          .proximitySetting
                          .distance +
                      100,
                );
          },
        ),
        IconButton(
          icon: const Icon(FluentIcons.remove),
          onPressed: () async {
            ref
                .read(provider.appSettingsProvider.notifier)
                .setProximitySetting(
                  distance:
                      ref
                          .read(provider.appSettingsProvider)
                          .proximitySetting
                          .distance -
                      100,
                );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return settings(context);
  }
}
