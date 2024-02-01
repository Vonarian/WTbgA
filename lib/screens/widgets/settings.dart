import 'dart:developer';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openrgb/data/rgb_controller.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:win_toast/win_toast.dart';

import '../../main.dart';
import '../../models/app_settings.dart';
import '../downloader.dart';
import 'card_highlight.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends ConsumerState<Settings> {
  Future<void> downloadFfmpegMona(bool mona, bool ffmpeg) async {
    bool monaMissing = !mona;
    bool ffmpegMissing = !ffmpeg;
    await WinToast.instance().showToast(
        type: ToastType.text04,
        title: 'Downloading FFMPEG...',
        subtitle:
            'Do not close the application until the download process is finished');
    Directory docDir = await getApplicationDocumentsDirectory();
    String docPath = docDir.path;
    Directory docWTbgA =
        await Directory('$docPath\\WTbgA\\stream').create(recursive: true);
    if (ffmpegMissing && monaMissing) {
      try {
        await dio.download(
            'https://github.com/Vonarian/WTbgA/releases/download/2.4.0.0/ffmpeg.zip',
            '${docWTbgA.path}\\ffmpeg.zip',
            onReceiveProgress: (downloaded, full) {
          setState(() {});
        }, deleteOnError: true).whenComplete(() async {
          final File filePath = File('${docWTbgA.path}\\ffmpeg.zip');
          final Uint8List bytes =
              await File('${docWTbgA.path}\\ffmpeg.zip').readAsBytes();
          final archive = ZipDecoder().decodeBytes(bytes);
          for (final file in archive) {
            final filename = file.name;
            if (file.isFile) {
              final data = file.content as List<int>;
              File('${p.dirname(filePath.path)}\\out\\$filename')
                ..createSync(recursive: true)
                ..writeAsBytesSync(data);
            } else {
              Directory('${p.dirname(filePath.path)}\\out\\$filename')
                  .create(recursive: true);
            }
          }
        });
        await dio
            .download(
                'https://github.com/Vonarian/WTbgA/releases/download/2.4.0.0/mona.zip',
                '${docWTbgA.path}\\mona.zip',
                deleteOnError: true)
            .whenComplete(() async {
          final File filePath = File('${docWTbgA.path}\\mona.zip');
          final Uint8List bytes =
              await File('${docWTbgA.path}\\mona.zip').readAsBytes();
          final archive = ZipDecoder().decodeBytes(bytes);
          for (final file in archive) {
            final filename = file.name;
            if (file.isFile) {
              final data = file.content as List<int>;
              File('${p.dirname(filePath.path)}\\out\\$filename')
                ..createSync(recursive: true)
                ..writeAsBytesSync(data);
            } else {
              Directory('${p.dirname(filePath.path)}\\out\\$filename')
                  .create(recursive: true);
            }
          }
        });
      } catch (e, st) {
        if (!mounted) return;
        log(e.toString(), stackTrace: st);
        displayInfoBar(
          context,
          builder: (context, close) =>
              InfoBar(title: const Text('Error!'), content: Text(e.toString())),
        );
        setState(() {});
      }
    } else if (monaMissing && !ffmpegMissing) {
      await dio
          .download(
              'https://github.com/Vonarian/WTbgA/releases/download/2.4.0.0/mona.zip',
              '${docWTbgA.path}\\mona.zip',
              deleteOnError: true)
          .whenComplete(() async {
        final File filePath = File('${docWTbgA.path}\\mona.zip');
        final Uint8List bytes =
            await File('${docWTbgA.path}\\mona.zip').readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        for (final file in archive) {
          final filename = file.name;
          if (file.isFile) {
            final data = file.content as List<int>;
            File('${p.dirname(filePath.path)}\\out\\$filename')
              ..createSync(recursive: true)
              ..writeAsBytesSync(data);
          } else {
            Directory('${p.dirname(filePath.path)}\\out\\$filename')
                .create(recursive: true);
          }
        }
      });
    } else if (!monaMissing && ffmpegMissing) {
      await dio
          .download(
        'https://github.com/Vonarian/WTbgA/releases/download/2.4.0.0/ffmpeg.zip',
        '${docWTbgA.path}\\ffmpeg.zip',
      )
          .whenComplete(() async {
        final File filePath = File('${docWTbgA.path}\\ffmpeg.zip');
        final Uint8List bytes =
            await File('${docWTbgA.path}\\ffmpeg.zip').readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        for (final file in archive) {
          final filename = file.name;
          if (file.isFile) {
            final data = file.content as List<int>;
            File('${p.dirname(filePath.path)}\\out\\$filename')
              ..createSync(recursive: true)
              ..writeAsBytesSync(data);
          } else {
            Directory('${p.dirname(filePath.path)}\\out\\$filename')
                .create(recursive: true);
          }
        }
      });
    }
  }

  List<RGBController>? controllersData;

  Widget updateWidget(String version, {required FluentThemeData theme}) {
    return CardHighlight(
      leading: const Icon(FluentIcons.update_restore),
      title: Text(
        'New Update!',
        style: theme.typography.bodyStrong
            ?.copyWith(color: theme.accentColor.lightest),
      ),
      description: Text('$version is available to download'),
      trailing: Button(
          style: ButtonStyle(
              backgroundColor:
                  ButtonState.resolveWith((_) => theme.accentColor.lighter)),
          onPressed: () {
            Navigator.of(context)
                .pushReplacement(FluentPageRoute(builder: (context) {
              return const Downloader();
            }));
          },
          child: const Text('Update')),
    );
  }

  Widget settings(BuildContext context) {
    final appSettings = ref.watch(provider.appSettingsProvider);
    final appSettingsNotifier = ref.read(provider.appSettingsProvider.notifier);
    final firebaseVersion = ref.watch(provider.versionFBProvider);
    final theme = FluentTheme.of(context);
    return ScaffoldPage(
      header: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Text(
          'Settings',
          style: theme.typography.title,
        ),
      ),
      content: SingleChildScrollView(
        child: Card(
          backgroundColor: Colors.transparent,
          child: Column(
            children: [
              firebaseVersion.when(
                  data: (data) => data != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Updates',
                              style: theme.typography.bodyStrong,
                            ),
                            const SizedBox(height: 6.0),
                            updateWidget(data, theme: theme),
                          ],
                        )
                      : const SizedBox(),
                  error: (_, __) => const SizedBox(),
                  loading: () => const SizedBox()),
              Text(
                'Main',
                style: theme.typography.bodyStrong,
              ),
              CardHighlight(
                leading: const Icon(
                  FluentIcons.important,
                  size: 20,
                ),
                title: Text('Toggle All', style: theme.typography.body),
                description: Text(
                  'Toggles all notifiers at once',
                  style: theme.typography.caption,
                ),
                trailing: ToggleSwitch(
                    checked: appSettings.fullNotif,
                    onChanged: (value) async {
                      appSettingsNotifier.setFullNotif(value);
                      appSettingsNotifier.setEngineWarning(enabled: value);
                      appSettingsNotifier.setOverHeatWarning(enabled: value);
                      appSettingsNotifier.setOverGWarning(enabled: value);
                      appSettingsNotifier.setPullUpSetting(enabled: value);
                      appSettingsNotifier.setProximitySetting(enabled: value);
                      await appSettingsNotifier.save();
                    },
                    leadingContent: true,
                    content: Text(
                        'All Notifications: ${appSettings.fullNotif ? 'Enabled' : 'Disabled'}')),
              ),
              CardHighlight(
                title: const Text('Reset App Data'),
                description: Text(
                  'Resets ALL app data including preferences and settings',
                  style: TextStyle(color: Colors.red),
                ),
                leading: const Icon(FluentIcons.update_restore),
                trailing: IconButton(
                    icon: Icon(
                      FluentIcons.update_restore,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      // TODO: Implement full reset
                    }),
              ),
              Text(
                'Notifiers',
                style: theme.typography.bodyStrong,
              ),
            ],
          ),
        ),
      ),

      //       SettingsTile.switchTile(
      //         initialValue: appSettings.fullNotif,
      //         title: const Text('All Notifications'),
      //         onToggle: (bool value) async {
      //           appSettingsNotifier
      //               .update(appSettings.copyWith(fullNotif: value));
      //           appSettingsNotifier.setFullNotif(value);
      //           appSettingsNotifier.setEngineWarning(enabled: value);
      //           appSettingsNotifier.setOverHeatWarning(enabled: value);
      //           appSettingsNotifier.setOverGWarning(enabled: value);
      //           appSettingsNotifier.setPullUpSetting(enabled: value);
      //           appSettingsNotifier.setProximitySetting(enabled: value);
      //           await appSettingsNotifier.save();
      //         },
      //         activeSwitchColor: theme.accentColor.lightest,
      //       ),
      //       SettingsTile.switchTile(
      //         initialValue: appSettings.startup,
      //         description:
      //             const Text('Run WTbgA on startup (Needs VonAssistant)'),
      //         onToggle: (value) async {
      //           try {
      //             final von = await showLoading<VonAssistant>(
      //                 context: context,
      //                 future: VonAssistant.initialize(),
      //                 message: 'Getting Startup Service ready!');
      //             if (von.installed) {
      //               await von.setStartup(value);
      //               appSettingsNotifier.setStartup(value);
      //               await appSettingsNotifier.save();
      //             }
      //           } catch (e, st) {
      //             log(e.toString(), stackTrace: st);
      //             if (!mounted) return;
      //             showLoading(
      //                 context: context,
      //                 future: Future.delayed(const Duration(seconds: 2)),
      //                 message: 'Error: $e');
      //           }
      //         },
      //         title: const Text('Run at Startup'),
      //         leading:
      //             Icon(FluentIcons.app_icon_default, color: theme.accentColor),
      //         activeSwitchColor: theme.accentColor.lightest,
      //       ),
      //       firebaseVersion.when(data: (data) {
      //         int fbVersion = int.parse(data?.replaceAll('.', '') ?? '0000');
      //         int currentVersion = int.parse(appVersion.replaceAll('.', ''));
      //         final bool updateAvailable = fbVersion > currentVersion;
      //         if (updateAvailable) {
      //           return SettingsTile(
      //             description: Text('v$data available'),
      //             title: BlinkText(
      //               'Download & Install Update',
      //               style: TextStyle(
      //                 fontSize: 20,
      //                 fontWeight: FontWeight.bold,
      //                 color: Colors.red,
      //               ),
      //               duration: const Duration(seconds: 2),
      //             ),
      //             leading:
      //                 Icon(FluentIcons.update_restore, color: theme.accentColor),
      //             onPressed: (ctx) {
      //               Navigator.pushReplacement(
      //                   context,
      //                   FluentPageRoute(
      //                       builder: (context) => const Downloader()));
      //             },
      //           );
      //         } else {
      //           return SettingsTile(
      //             description: const Text('There is no update available'),
      //             title: const Text(
      //               'Download & Install Update',
      //               style: TextStyle(decoration: TextDecoration.lineThrough),
      //             ),
      //             leading:
      //                 Icon(FluentIcons.update_restore, color: theme.accentColor),
      //             onPressed: (ctx) {
      //               showDialog(
      //                   context: ctx,
      //                   builder: (ctx) => ContentDialog(
      //                         title: const Text('Update'),
      //                         content: const Text(
      //                             'There is no update available at this time.'),
      //                         actions: <Widget>[
      //                           HyperlinkButton(
      //                             child: const Text('OK'),
      //                             onPressed: () => Navigator.pop(ctx),
      //                           ),
      //                         ],
      //                       ));
      //             },
      //           );
      //         }
      //       }, error: (e, st) {
      //         return SettingsTile(
      //           description: const Text('Error fetching version'),
      //           title: const Text(
      //             'Download & Install Update',
      //             style: TextStyle(decoration: TextDecoration.lineThrough),
      //           ),
      //           leading:
      //               Icon(FluentIcons.update_restore, color: theme.accentColor),
      //           onPressed: (ctx) {
      //             showDialog(
      //                 context: ctx,
      //                 builder: (ctx) => ContentDialog(
      //                       title: const Text('Update'),
      //                       content: const Text(
      //                           'Error fetching version. Please try again later.'),
      //                       actions: <Widget>[
      //                         HyperlinkButton(
      //                           child: const Text('OK'),
      //                           onPressed: () => Navigator.pop(ctx),
      //                         ),
      //                       ],
      //                     ));
      //           },
      //         );
      //       }, loading: () {
      //         return SettingsTile(
      //           description: const Text('Fetching version...'),
      //           title: const Text(
      //             'Download & Install Update',
      //             style: TextStyle(decoration: TextDecoration.lineThrough),
      //           ),
      //           leading:
      //               Icon(FluentIcons.update_restore, color: theme.accentColor),
      //           onPressed: (ctx) {
      //             showDialog(
      //                 context: ctx,
      //                 builder: (ctx) => ContentDialog(
      //                       title: const Text('Update'),
      //                       content: const Text('Fetching version...'),
      //                       actions: <Widget>[
      //                         HyperlinkButton(
      //                           child: const Text('OK'),
      //                           onPressed: () => Navigator.pop(ctx),
      //                         ),
      //                       ],
      //                     ));
      //           },
      //         );
      //       }),
      //       SettingsTile(
      //         title: const Text('Reset App Data'),
      //         description: Text(
      //           'Resets ALL app data including preferences and settings',
      //           style: TextStyle(color: Colors.red),
      //         ),
      //         leading: const Icon(FluentIcons.update_restore),
      //         onPressed: (context) async {
      //           showDialog(
      //             context: context,
      //             builder: (context) => ContentDialog(
      //               title: const Text('Reset app'),
      //               content:
      //                   const Text('Are you sure you want to reset app data?'),
      //               actions: [
      //                 HyperlinkButton(
      //                   child: const Text('Cancel'),
      //                   onPressed: () => Navigator.of(context).pop(),
      //                 ),
      //                 HyperlinkButton(
      //                   child: const Text('Restart'),
      //                   onPressed: () async {
      //                     await prefs.clear();
      //                     if (!mounted) return;
      //                     Navigator.pushReplacement(
      //                         context,
      //                         FluentPageRoute(
      //                             builder: (context) => const Loading(
      //                                   minimize: false,
      //                                   startup: false,
      //                                 )));
      //                   },
      //                 ),
      //               ],
      //             ),
      //           );
      //         },
      //       ),
      //   SettingsSection(title: const Text('Notifiers'), tiles: [
      //     SettingsTile.switchTile(
      //       initialValue: appSettings.engineWarning.enabled,
      //       onToggle: (bool value) async {
      //         appSettingsNotifier.update(appSettings.copyWith(
      //             engineWarning:
      //                 appSettings.engineWarning.copyWith(enabled: value)));
      //         await appSettingsNotifier.save();
      //       },
      //       title: const Text('Engine Sound'),
      //       description: const Text('Click to change file'),
      //       leading: SizedBox(height: 55, child: _buildSliderEngine(appSettings)),
      //       onPressed: (context) async {
      //         final file = await FilePicker.platform.pickFiles(
      //             dialogTitle: 'Select audio file for engine',
      //             type: FileType.audio);
      //         if (file != null) {
      //           String docFilePath =
      //               await AppUtil.saveInDocs(file.files.first.path!);
      //
      //           appSettingsNotifier.update(appSettings.copyWith(
      //               engineWarning:
      //                   appSettings.engineWarning.copyWith(path: docFilePath)));
      //           await appSettingsNotifier.save();
      //         }
      //       },
      //       activeSwitchColor: theme.accentColor.lightest,
      //     ),
      //     SettingsTile.switchTile(
      //       initialValue: appSettings.overHeatWarning.enabled,
      //       onToggle: (bool value) async {
      //         appSettingsNotifier.update(appSettings.copyWith(
      //             overHeatWarning:
      //                 appSettings.overHeatWarning.copyWith(enabled: value)));
      //         await appSettingsNotifier.save();
      //       },
      //       title: const Text('Overheat Sound'),
      //       description: const Text('Click to change file'),
      //       leading:
      //           SizedBox(height: 55, child: _buildSliderOverHeat(appSettings)),
      //       onPressed: (context) async {
      //         final file = await FilePicker.platform.pickFiles(
      //             dialogTitle: 'Select audio file for overheat',
      //             type: FileType.audio);
      //         if (file != null) {
      //           String docFilePath =
      //               await AppUtil.saveInDocs(file.files.first.path!);
      //
      //           appSettingsNotifier.update(appSettings.copyWith(
      //               overHeatWarning:
      //                   appSettings.overHeatWarning.copyWith(path: docFilePath)));
      //           await appSettingsNotifier.save();
      //         }
      //       },
      //       activeSwitchColor: theme.accentColor.lightest,
      //     ),
      //     SettingsTile.switchTile(
      //       initialValue: appSettings.overGWarning.enabled,
      //       onToggle: (value) async {
      //         appSettingsNotifier.update(appSettings.copyWith(
      //             overGWarning:
      //                 appSettings.overGWarning.copyWith(enabled: value)));
      //         await appSettingsNotifier.save();
      //       },
      //       title: const Text('OverG Sound'),
      //       description: const Text('Click to change file'),
      //       leading: SizedBox(height: 55, child: _buildSliderOverG(appSettings)),
      //       onPressed: (context) async {
      //         final file = await FilePicker.platform.pickFiles(
      //             dialogTitle: 'Select audio file for high G-Load',
      //             type: FileType.audio);
      //         if (file != null) {
      //           String docFilePath =
      //               await AppUtil.saveInDocs(file.files.first.path!);
      //
      //           appSettingsNotifier.update(appSettings.copyWith(
      //               overGWarning:
      //                   appSettings.overGWarning.copyWith(path: docFilePath)));
      //           await appSettingsNotifier.save();
      //         }
      //       },
      //       activeSwitchColor: theme.accentColor.lightest,
      //     ),
      //     SettingsTile.switchTile(
      //       initialValue: appSettings.pullUpSetting.enabled,
      //       onToggle: (value) async {
      //         appSettingsNotifier.update(appSettings.copyWith(
      //             pullUpSetting:
      //                 appSettings.pullUpSetting.copyWith(enabled: value)));
      //         await appSettingsNotifier.save();
      //       },
      //       title: const Text('Pull up Sound'),
      //       description: const Text('Click to change file'),
      //       leading: SizedBox(height: 55, child: _buildSliderPullUP(appSettings)),
      //       onPressed: (context) async {
      //         final file = await FilePicker.platform.pickFiles(
      //             dialogTitle: 'Select audio file for pull up',
      //             type: FileType.audio);
      //         if (file != null) {
      //           String docFilePath =
      //               await AppUtil.saveInDocs(file.files.first.path!);
      //
      //           appSettingsNotifier.update(appSettings.copyWith(
      //               pullUpSetting:
      //                   appSettings.pullUpSetting.copyWith(path: docFilePath)));
      //           await appSettingsNotifier.save();
      //         }
      //       },
      //       activeSwitchColor: theme.accentColor.lightest,
      //     ),
      //     SettingsTile.switchTile(
      //       initialValue: appSettings.proximitySetting.enabled,
      //       onToggle: (value) async {
      //         appSettingsNotifier.setProximitySetting(enabled: value);
      //         await appSettingsNotifier.save();
      //       },
      //       title: const Text('Enemy Proximity Sound'),
      //       description: const Text('Click to change file'),
      //       leading: SizedBox(height: 55, child: _buildSliderProxy(appSettings)),
      //       onPressed: (context) async {
      //         final file = await FilePicker.platform.pickFiles(
      //             dialogTitle: 'Select audio file for enemy proximity warning',
      //             type: FileType.audio);
      //         if (file != null) {
      //           String docFilePath =
      //               await AppUtil.saveInDocs(file.files.first.path!);
      //
      //           appSettingsNotifier.setProximitySetting(path: docFilePath);
      //           await appSettingsNotifier.save();
      //         }
      //       },
      //       activeSwitchColor: theme.accentColor.lightest,
      //       trailing: Row(
      //         children: [
      //           distance(context, appSettings),
      //           const SizedBox(width: 8),
      //           Text('${appSettings.proximitySetting.distance}m'),
      //         ],
      //       ),
      //     ),
      //   ]),
      //   SettingsSection(title: const Text('Misc'), tiles: [
      //     SettingsTile.switchTile(
      //       initialValue: ref.watch(provider.needPremiumProvider),
      //       onToggle: (value) async {
      //         ref.read(provider.needPremiumProvider.notifier).state = value;
      //         await PresenceService().needPremium(
      //             (await deviceInfo.windowsInfo).computerName, value);
      //         await prefs.setBool('needPremium', value);
      //       },
      //       title: const Text('Gib Premium!'),
      //       description: const Text(
      //           'This is a way to notify me (Vonarian) if you need premium features and you can\'t get one :)'),
      //       activeSwitchColor: theme.accentColor.lightest,
      //     ),
      //     SettingsTile(
      //       title: const Text('Set a Username'),
      //       onPressed: (context) async {
      //         await Message.getUserNameCustom(context, null);
      //       },
      //     ),
      //   ]),
      // ]
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
            await ref.read(provider.appSettingsProvider.notifier).save();
          },
          vertical: true,
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(FluentIcons.play),
          onPressed: () async {
            await audio1.play(DeviceFileSource(appSettings.engineWarning.path),
                volume: appSettings.engineWarning.volume / 100,
                mode: PlayerMode.lowLatency);
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
            await ref.read(provider.appSettingsProvider.notifier).save();
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
                mode: PlayerMode.lowLatency);
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
            await ref.read(provider.appSettingsProvider.notifier).save();
          },
          vertical: true,
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(FluentIcons.play),
          onPressed: () async {
            await audio1.play(DeviceFileSource(appSettings.overGWarning.path),
                volume: appSettings.overGWarning.volume / 100,
                mode: PlayerMode.lowLatency);
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
            await ref.read(provider.appSettingsProvider.notifier).save();
          },
          vertical: true,
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(FluentIcons.play),
          onPressed: () async {
            await audio1.play(DeviceFileSource(appSettings.pullUpSetting.path),
                volume: appSettings.pullUpSetting.volume / 100,
                mode: PlayerMode.lowLatency);
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
            await ref.read(provider.appSettingsProvider.notifier).save();
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
                mode: PlayerMode.lowLatency);
          },
        ),
      ],
    );
  }

  Widget distance(BuildContext context, AppSettings appSettings) {
    return Column(
      children: [
        IconButton(
            icon: const Icon(FluentIcons.add),
            onPressed: () async {
              ref
                  .read(provider.appSettingsProvider.notifier)
                  .setProximitySetting(
                      distance: ref
                              .read(provider.appSettingsProvider)
                              .proximitySetting
                              .distance +
                          100);
              await ref.read(provider.appSettingsProvider.notifier).save();
            }),
        IconButton(
            icon: const Icon(FluentIcons.remove),
            onPressed: () async {
              ref
                  .read(provider.appSettingsProvider.notifier)
                  .setProximitySetting(
                      distance: ref
                              .read(provider.appSettingsProvider)
                              .proximitySetting
                              .distance -
                          100);
              await ref.read(provider.appSettingsProvider.notifier).save();
            }),
      ],
    );
  }

  bool isStreaming = false;
  Process? outerProcess;
  Process? monaProcess;

  @override
  Widget build(BuildContext context) {
    return settings(context);
  }
}
