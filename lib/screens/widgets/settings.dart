import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:blinking_text/blinking_text.dart';
import 'package:ffmpeg_cli/ffmpeg_cli.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openrgb/data/rgb_controller.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:win_toast/win_toast.dart';
import 'package:wtbgassistant/data/app_settings.dart';
import 'package:wtbgassistant/screens/downloader.dart';
import 'package:wtbgassistant/screens/widgets/loading_widget.dart';
import 'package:wtbgassistant/screens/widgets/settings_list_custom.dart';
import 'package:wtbgassistant/services/presence.dart';

import '../../data/data_class.dart';
import '../../main.dart';
import '../../services/utility.dart';
import '../loading.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({Key? key}) : super(key: key);

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
        subtitle: 'Do not close the application until the download process is finished');
    Directory docDir = await getApplicationDocumentsDirectory();
    String docPath = docDir.path;
    Directory docWTbgA = await Directory('$docPath\\WTbgA\\stream').create(recursive: true);
    if (ffmpegMissing && monaMissing) {
      try {
        await dio.download(
            'https://github.com/Vonarian/WTbgA/releases/download/2.4.0.0/ffmpeg.zip', '${docWTbgA.path}\\ffmpeg.zip',
            onReceiveProgress: (downloaded, full) {
          setState(() {});
        }, deleteOnError: true).whenComplete(() async {
          final File filePath = File('${docWTbgA.path}\\ffmpeg.zip');
          final Uint8List bytes = await File('${docWTbgA.path}\\ffmpeg.zip').readAsBytes();
          final archive = ZipDecoder().decodeBytes(bytes);
          for (final file in archive) {
            final filename = file.name;
            if (file.isFile) {
              final data = file.content as List<int>;
              File('${p.dirname(filePath.path)}\\out\\$filename')
                ..createSync(recursive: true)
                ..writeAsBytesSync(data);
            } else {
              Directory('${p.dirname(filePath.path)}\\out\\$filename').create(recursive: true);
            }
          }
        });
        await dio
            .download(
                'https://github.com/Vonarian/WTbgA/releases/download/2.4.0.0/mona.zip', '${docWTbgA.path}\\mona.zip',
                deleteOnError: true)
            .whenComplete(() async {
          final File filePath = File('${docWTbgA.path}\\mona.zip');
          final Uint8List bytes = await File('${docWTbgA.path}\\mona.zip').readAsBytes();
          final archive = ZipDecoder().decodeBytes(bytes);
          for (final file in archive) {
            final filename = file.name;
            if (file.isFile) {
              final data = file.content as List<int>;
              File('${p.dirname(filePath.path)}\\out\\$filename')
                ..createSync(recursive: true)
                ..writeAsBytesSync(data);
            } else {
              Directory('${p.dirname(filePath.path)}\\out\\$filename').create(recursive: true);
            }
          }
        });
      } catch (e, st) {
        if (!mounted) return;
        log(e.toString(), stackTrace: st);
        showSnackbar(context, Snackbar(content: Text(e.toString())));
        setState(() {});
      }
    } else if (monaMissing && !ffmpegMissing) {
      await dio
          .download(
              'https://github.com/Vonarian/WTbgA/releases/download/2.4.0.0/mona.zip', '${docWTbgA.path}\\mona.zip',
              deleteOnError: true)
          .whenComplete(() async {
        final File filePath = File('${docWTbgA.path}\\mona.zip');
        final Uint8List bytes = await File('${docWTbgA.path}\\mona.zip').readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        for (final file in archive) {
          final filename = file.name;
          if (file.isFile) {
            final data = file.content as List<int>;
            File('${p.dirname(filePath.path)}\\out\\$filename')
              ..createSync(recursive: true)
              ..writeAsBytesSync(data);
          } else {
            Directory('${p.dirname(filePath.path)}\\out\\$filename').create(recursive: true);
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
        final Uint8List bytes = await File('${docWTbgA.path}\\ffmpeg.zip').readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        for (final file in archive) {
          final filename = file.name;
          if (file.isFile) {
            final data = file.content as List<int>;
            File('${p.dirname(filePath.path)}\\out\\$filename')
              ..createSync(recursive: true)
              ..writeAsBytesSync(data);
          } else {
            Directory('${p.dirname(filePath.path)}\\out\\$filename').create(recursive: true);
          }
        }
      });
    }
  }

  List<RGBController>? controllersData;

  Widget settings(BuildContext context) {
    final appSettings = ref.watch(provider.appSettingsProvider);
    final appSettingsNotifier = ref.read(provider.appSettingsProvider.notifier);
    final firebaseVersion = ref.watch(provider.versionFBProvider);
    final theme = FluentTheme.of(context);
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
            title: const Text('Main'),
            tiles: [
              SettingsTile.switchTile(
                initialValue: appSettings.fullNotif,
                title: const Text('Toggle All Notifications'),
                onToggle: (bool value) async {
                  appSettingsNotifier.update(appSettings.copyWith(fullNotif: value));
                  appSettingsNotifier.setFullNotif(value);
                  appSettingsNotifier.setEngineWarning(enabled: value);
                  appSettingsNotifier.setOverHeatWarning(enabled: value);
                  appSettingsNotifier.setOverGWarning(enabled: value);
                  appSettingsNotifier.setPullUpSetting(enabled: value);
                  appSettingsNotifier.setProximitySetting(enabled: value);
                  await appSettingsNotifier.save();
                },
              ),
              firebaseVersion.when(data: (data) {
                int fbVersion = int.parse(data?.replaceAll('.', '') ?? '0000');
                int currentVersion = int.parse(appVersion.replaceAll('.', ''));
                final bool updateAvailable = fbVersion > currentVersion;
                if (updateAvailable) {
                  return SettingsTile(
                    description: Text('v$data available'),
                    title: BlinkText(
                      'Download & Install Update',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                    leading: Icon(FluentIcons.update_restore, color: theme.accentColor),
                    onPressed: (ctx) {
                      Navigator.pushReplacement(context, FluentPageRoute(builder: (context) => const Downloader()));
                    },
                  );
                } else {
                  return SettingsTile(
                    description: const Text('There is no update available'),
                    title: const Text(
                      'Download & Install Update',
                      style: TextStyle(decoration: TextDecoration.lineThrough),
                    ),
                    leading: Icon(FluentIcons.update_restore, color: theme.accentColor),
                    onPressed: (ctx) {
                      showDialog(
                          context: ctx,
                          builder: (ctx) => ContentDialog(
                                title: const Text('Update'),
                                content: const Text('There is no update available at this time.'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () => Navigator.pop(ctx),
                                  ),
                                ],
                              ));
                    },
                  );
                }
              }, error: (e, st) {
                return SettingsTile(
                  description: const Text('Error fetching version'),
                  title: const Text(
                    'Download & Install Update',
                    style: TextStyle(decoration: TextDecoration.lineThrough),
                  ),
                  leading: Icon(FluentIcons.update_restore, color: theme.accentColor),
                  onPressed: (ctx) {
                    showDialog(
                        context: ctx,
                        builder: (ctx) => ContentDialog(
                              title: const Text('Update'),
                              content: const Text('Error fetching version. Please try again later.'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () => Navigator.pop(ctx),
                                ),
                              ],
                            ));
                  },
                );
              }, loading: () {
                return SettingsTile(
                  description: const Text('Fetching version...'),
                  title: const Text(
                    'Download & Install Update',
                    style: TextStyle(decoration: TextDecoration.lineThrough),
                  ),
                  leading: Icon(FluentIcons.update_restore, color: theme.accentColor),
                  onPressed: (ctx) {
                    showDialog(
                        context: ctx,
                        builder: (ctx) => ContentDialog(
                              title: const Text('Update'),
                              content: const Text('Fetching version...'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () => Navigator.pop(ctx),
                                ),
                              ],
                            ));
                  },
                );
              }),
              SettingsTile.switchTile(
                leading: Image.asset(
                  'assets/icons/iran.png',
                  height: 20,
                  width: 20,
                ),
                description: Row(
                  children: [
                    const Text('Feature developed for '),
                    GradientText('IRANIAN',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        gradient: LinearGradient(colors: [Colors.green, Colors.white, Colors.red])),
                    const Text(' users :)'),
                  ],
                ),
                initialValue: appSettings.windscribeSettings.autoSwitch,
                title: Text(
                    'Toggle Windscribe auto-switch (${appSettings.windscribeSettings.path == null ? 'Click to initiate' : 'Initiated'})'),
                onToggle: (bool value) async {
                  appSettingsNotifier.setWindscribe(autoSwitch: value);
                  await appSettingsNotifier.save();
                },
                onPressed: appSettings.windscribeSettings.autoSwitch
                    ? (context) async {
                        final value = await appSettingsNotifier.setupWindscribePath();
                        if (value == null && mounted) {
                          showSnackbar(
                            context,
                            Snackbar(
                                extended: true,
                                action: Button(
                                    child: const Text('Select Manually'),
                                    onPressed: () async {
                                      final path = await FilePicker.platform
                                          .getDirectoryPath(dialogTitle: 'Pick Windscribe\'s installation folder.');
                                      if (path != null && await File('$path\\windscribe-cli.exe').exists()) {
                                        appSettingsNotifier.setWindscribe(path: '$path\\windscribe-cli.exe');
                                        await appSettingsNotifier.save();
                                        showDialog(
                                            context: context,
                                            builder: (context) => ContentDialog(
                                                  content: const Text('Windscribe path has been updated.'),
                                                  actions: [
                                                    Button(
                                                        child: const Text('Understood.'),
                                                        onPressed: () => Navigator.of(context).pop()),
                                                  ],
                                                ));
                                      }
                                    }),
                                content: const Text(
                                    'Unable to find Windscribe\'s location click on the "Select Manually" to select the folder of Windscribe.')),
                            duration: const Duration(seconds: 10),
                          );
                        } else {
                          await appSettingsNotifier.save();
                        }
                      }
                    : null,
              ),
              SettingsTile(
                title: const Text('Start Streaming Mode'),
                onPressed: (ctx) async {
                  if (!isStreaming) {
                    final Directory docWTbgAStream = Directory('$appDocPath\\stream');
                    if (!(await docWTbgAStream.exists())) {
                      await docWTbgAStream.create(recursive: true);
                    }
                    File fileFFMPEG = File('${docWTbgAStream.path}\\out\\ffmpeg.exe');
                    File fileMona = File('${docWTbgAStream.path}\\out\\MonaTiny.exe');
                    bool ffmpegExists = await fileFFMPEG.exists();
                    bool monaExists = await fileMona.exists();
                    if (ffmpegExists && monaExists) {
                      monaProcess = await Process.start('cmd.exe', ['/c', fileMona.path],
                          runInShell: true, workingDirectory: docWTbgAStream.path);
                      monaProcess?.stdout.transform(utf8.decoder).listen((event) {
                        if (kDebugMode) {
                          print(event);
                        }
                      });
                      monaProcess?.stderr.transform(utf8.decoder).listen((event) {
                        if (kDebugMode) {
                          print(event);
                        }
                      });
                      final deviceIP =
                          await AppUtil.runPowerShellScript(AppUtil.deviceIPPath, ['-ExecutionPolicy', 'Bypass']);
                      final command = FfmpegCommand(
                        inputs: [FfmpegInput.virtualDevice('desktop')],
                        args: [
                          const CliArg(name: 'framerate', value: '45'),
                          const CliArg(name: 'c:v', value: 'libx264'),
                          const CliArg(name: 'b:v', value: '2M'),
                          const CliArg(name: 'bufsize', value: '3M'),
                          const CliArg(name: 'crf', value: '18'),
                          const CliArg(name: 'pix_fmt', value: 'yuv420p'),
                          const CliArg(name: 'tune', value: 'zerolatency'),
                          const CliArg(name: 'f', value: 'flv'),
                        ],
                        filterGraph: null,
                        outputFilepath: 'rtmp://$deviceIP:1935',
                      );
                      isStreaming = true;
                      try {
                        outerProcess =
                            await Ffmpeg().run(command, path: fileFFMPEG.path, workingDir: docWTbgAStream.path);
                        outerProcess?.stderr.transform(utf8.decoder).listen((event) {
                          if (kDebugMode) {
                            print(event);
                          }
                        });
                      } catch (e, st) {
                        log(e.toString(), stackTrace: st);
                      }
                      setState(() {});
                    } else {
                      try {
                        await showLoading(
                            context: context,
                            future: downloadFfmpegMona(monaExists, ffmpegExists),
                            message: 'Downloading FFMPEG / Mona');
                        if (!mounted) return;

                        showSnackbar(context,
                            const Snackbar(content: Text('Downloaded FFMPEG / Mona, click again to start streaming')));
                      } catch (e, st) {
                        if (!mounted) return;
                        showSnackbar(context, const Snackbar(content: Text('Failed to download FFMPEG / Mona')));
                        log(e.toString(), stackTrace: st);
                      }
                    }
                  } else {
                    isStreaming = false;
                    setState(() {});
                    await Process.run('taskkill', ['/F', '/IM', 'ffmpeg.exe']);
                    Process.run('taskkill', ['/F', '/IM', 'MonaTiny.exe']);
                  }
                },
                leading: isStreaming
                    ? Icon(FluentIcons.streaming, color: Colors.green)
                    : Icon(FluentIcons.streaming, color: Colors.red),
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
                      content: const Text('Are you sure you want to reset app data?'),
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
                            Navigator.pushReplacement(context, FluentPageRoute(builder: (context) => const Loading()));
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          SettingsSection(title: const Text('Notifiers'), tiles: [
            SettingsTile.switchTile(
              initialValue: appSettings.engineWarning.enabled,
              onToggle: (bool value) async {
                appSettingsNotifier
                    .update(appSettings.copyWith(engineWarning: appSettings.engineWarning.copyWith(enabled: value)));
                await appSettingsNotifier.save();
              },
              title: const Text('Engine Sound'),
              description: const Text('Click to change file'),
              leading: SizedBox(height: 55, child: _buildSliderEngine(appSettings)),
              onPressed: (context) async {
                final file = await FilePicker.platform
                    .pickFiles(dialogTitle: 'Select audio file for engine', type: FileType.audio);
                if (file != null) {
                  String docFilePath = await AppUtil.saveInDocs(file.files.first.path!);

                  appSettingsNotifier.update(
                      appSettings.copyWith(engineWarning: appSettings.engineWarning.copyWith(path: docFilePath)));
                  await appSettingsNotifier.save();
                }
              },
            ),
            SettingsTile.switchTile(
              initialValue: appSettings.overHeatWarning.enabled,
              onToggle: (bool value) async {
                appSettingsNotifier.update(
                    appSettings.copyWith(overHeatWarning: appSettings.overHeatWarning.copyWith(enabled: value)));
                await appSettingsNotifier.save();
              },
              title: const Text('Overheat Sound'),
              description: const Text('Click to change file'),
              leading: SizedBox(height: 55, child: _buildSliderOverHeat(appSettings)),
              onPressed: (context) async {
                final file = await FilePicker.platform
                    .pickFiles(dialogTitle: 'Select audio file for overheat', type: FileType.audio);
                if (file != null) {
                  String docFilePath = await AppUtil.saveInDocs(file.files.first.path!);

                  appSettingsNotifier.update(
                      appSettings.copyWith(overHeatWarning: appSettings.overHeatWarning.copyWith(path: docFilePath)));
                  await appSettingsNotifier.save();
                }
              },
            ),
            SettingsTile.switchTile(
              initialValue: appSettings.overGWarning.enabled,
              onToggle: (value) async {
                appSettingsNotifier
                    .update(appSettings.copyWith(overGWarning: appSettings.overGWarning.copyWith(enabled: value)));
                await appSettingsNotifier.save();
              },
              title: const Text('OverG Sound'),
              description: const Text('Click to change file'),
              leading: SizedBox(height: 55, child: _buildSliderOverG(appSettings)),
              onPressed: (context) async {
                final file = await FilePicker.platform
                    .pickFiles(dialogTitle: 'Select audio file for high G-Load', type: FileType.audio);
                if (file != null) {
                  String docFilePath = await AppUtil.saveInDocs(file.files.first.path!);

                  appSettingsNotifier
                      .update(appSettings.copyWith(overGWarning: appSettings.overGWarning.copyWith(path: docFilePath)));
                  await appSettingsNotifier.save();
                }
              },
            ),
            SettingsTile.switchTile(
              initialValue: appSettings.pullUpSetting.enabled,
              onToggle: (value) async {
                appSettingsNotifier
                    .update(appSettings.copyWith(pullUpSetting: appSettings.pullUpSetting.copyWith(enabled: value)));
                await appSettingsNotifier.save();
              },
              title: const Text('Pull up Sound'),
              description: const Text('Click to change file'),
              leading: SizedBox(height: 55, child: _buildSliderPullUP(appSettings)),
              onPressed: (context) async {
                final file = await FilePicker.platform
                    .pickFiles(dialogTitle: 'Select audio file for pull up', type: FileType.audio);
                if (file != null) {
                  String docFilePath = await AppUtil.saveInDocs(file.files.first.path!);

                  appSettingsNotifier.update(
                      appSettings.copyWith(pullUpSetting: appSettings.pullUpSetting.copyWith(path: docFilePath)));
                  await appSettingsNotifier.save();
                }
              },
            ),
            SettingsTile.switchTile(
              initialValue: appSettings.proximitySetting.enabled,
              onToggle: (value) async {
                appSettingsNotifier.update(
                    appSettings.copyWith(proximitySetting: appSettings.proximitySetting.copyWith(enabled: value)));
                await appSettingsNotifier.save();
              },
              title: const Text('Enemy Proximity Sound'),
              description: const Text('Click to change file'),
              leading: SizedBox(height: 55, child: _buildSliderProxy(appSettings)),
              onPressed: (context) async {
                final file = await FilePicker.platform
                    .pickFiles(dialogTitle: 'Select audio file for enemy proximity warning', type: FileType.audio);
                if (file != null) {
                  String docFilePath = await AppUtil.saveInDocs(file.files.first.path!);

                  appSettingsNotifier.update(
                      appSettings.copyWith(proximitySetting: appSettings.proximitySetting.copyWith(path: docFilePath)));
                  await appSettingsNotifier.save();
                }
              },
              trailing: Row(
                children: [
                  distance(context, appSettings),
                  const SizedBox(width: 8),
                  Text('${appSettings.proximitySetting.distance}m'),
                ],
              ),
            ),
          ]),
          SettingsSection(title: const Text('Misc'), tiles: [
            SettingsTile.switchTile(
              initialValue: ref.watch(provider.needPremiumProvider),
              onToggle: (value) async {
                ref.read(provider.needPremiumProvider.notifier).state = value;
                await PresenceService().needPremium((await deviceInfo.windowsInfo).computerName, value);
                await prefs.setBool('needPremium', value);
              },
              title: const Text('Gib Premium!'),
              description: const Text(
                  'This is a way to notify me (Vonarian) if you need premium features and you can\'t get one :)'),
            ),
            SettingsTile(
              title: const Text('Set a Username'),
              onPressed: (context) async {
                await Message.getUserNameCustom(context, null);
              },
            ),
          ]),
        ]);
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
          onChanged: (value) {
            ref
                .read(provider.appSettingsProvider.notifier)
                .update(appSettings.copyWith(engineWarning: appSettings.engineWarning.copyWith(volume: value)));
            ref.read(provider.appSettingsProvider.notifier).save();
          },
          vertical: true,
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(FluentIcons.play),
          onPressed: () async {
            await audio1.play(DeviceFileSource(appSettings.engineWarning.path),
                volume: appSettings.engineWarning.volume / 100, mode: PlayerMode.lowLatency);
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
          onChanged: (value) {
            ref
                .read(provider.appSettingsProvider.notifier)
                .update(appSettings.copyWith(overHeatWarning: appSettings.overHeatWarning.copyWith(volume: value)));
            ref.read(provider.appSettingsProvider.notifier).save();
          },
          vertical: true,
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(FluentIcons.play),
          onPressed: () async {
            await audio1.play(DeviceFileSource(appSettings.overHeatWarning.path),
                volume: appSettings.overHeatWarning.volume / 100, mode: PlayerMode.lowLatency);
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
          onChanged: (value) {
            ref
                .read(provider.appSettingsProvider.notifier)
                .update(appSettings.copyWith(overGWarning: appSettings.overGWarning.copyWith(volume: value)));
            ref.read(provider.appSettingsProvider.notifier).save();
          },
          vertical: true,
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(FluentIcons.play),
          onPressed: () async {
            await audio1.play(DeviceFileSource(appSettings.overGWarning.path),
                volume: appSettings.overGWarning.volume / 100, mode: PlayerMode.lowLatency);
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
          onChanged: (value) {
            ref
                .read(provider.appSettingsProvider.notifier)
                .update(appSettings.copyWith(pullUpSetting: appSettings.pullUpSetting.copyWith(volume: value)));
            ref.read(provider.appSettingsProvider.notifier).save();
          },
          vertical: true,
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(FluentIcons.play),
          onPressed: () async {
            await audio1.play(DeviceFileSource(appSettings.pullUpSetting.path),
                volume: appSettings.pullUpSetting.volume / 100, mode: PlayerMode.lowLatency);
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
          onChanged: (value) {
            ref
                .read(provider.appSettingsProvider.notifier)
                .update(appSettings.copyWith(proximitySetting: appSettings.proximitySetting.copyWith(volume: value)));
            ref.read(provider.appSettingsProvider.notifier).save();
          },
          vertical: true,
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(FluentIcons.play),
          onPressed: () async {
            await audio1.play(DeviceFileSource(appSettings.proximitySetting.path),
                volume: appSettings.proximitySetting.volume / 100, mode: PlayerMode.lowLatency);
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
              ref.read(provider.appSettingsProvider.notifier).update(appSettings.copyWith(
                  proximitySetting:
                      appSettings.proximitySetting.copyWith(distance: appSettings.proximitySetting.distance + 100)));
              await ref.read(provider.appSettingsProvider.notifier).save();
            }),
        IconButton(
            icon: const Icon(FluentIcons.remove),
            onPressed: () async {
              ref.read(provider.appSettingsProvider.notifier).update(appSettings.copyWith(
                  proximitySetting:
                      appSettings.proximitySetting.copyWith(distance: appSettings.proximitySetting.distance - 100)));
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
    final ipValue = ref.watch(provider.deviceIPProvider);
    return ScaffoldPage(
      content: Column(
        children: [
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                ref.refresh(provider.deviceIPProvider);
              },
              child: ipValue.when(data: (data) {
                return Text(
                  'Device IP: $data',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                );
              }, error: (e, st) {
                return Text(
                  'Device IP: Error',
                  style: TextStyle(fontSize: 20, color: Colors.red),
                );
              }, loading: () {
                return Text(
                  'Device IP: Loading...',
                  style: TextStyle(fontSize: 20, color: Colors.orange),
                );
              }),
            ),
          ),
          Expanded(flex: 10, child: settings(context)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    required this.gradient,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}
