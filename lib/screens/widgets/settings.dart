import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:ffmpeg_cli/ffmpeg_cli.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:win_toast/win_toast.dart';
import 'package:wtbgassistant/screens/widgets/loading_widget.dart';
import 'package:wtbgassistant/screens/widgets/settings_list_custom.dart';

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
        showSnackbar(context, Snackbar(content: Text(e.toString())));
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
                  ref.read(provider.engineOHNotifProvider.notifier).state =
                      value;
                  ref.read(provider.engineDeathNotifProvider.notifier).state =
                      value;
                  ref.read(provider.waterNotifProvider.notifier).state = value;
                },
              ),
              SettingsTile(
                title: const Text('Start Streaming Mode'),
                onPressed: (ctx) async {
                  if (!isStreaming) {
                    Directory docDir = await getApplicationDocumentsDirectory();
                    String docPath = docDir.path;
                    Directory docWTbgA =
                        await Directory('$docPath\\WTbgA\\stream')
                            .create(recursive: true);
                    String docWTbgAPath = docWTbgA.path;
                    File fileFFMPEG = File('$docWTbgAPath\\out\\ffmpeg.exe');
                    File fileMona = File('$docWTbgAPath\\out\\MonaTiny.exe');
                    bool ffmpegExists = await fileFFMPEG.exists();
                    bool monaExists = await fileMona.exists();
                    if (ffmpegExists && monaExists) {
                      monaProcess = await Process.start(
                          'cmd.exe', ['/c', fileMona.path],
                          runInShell: true);
                      monaProcess?.stdout
                          .transform(utf8.decoder)
                          .listen((event) {
                        if (kDebugMode) {
                          print(event);
                        }
                      });
                      monaProcess?.stderr
                          .transform(utf8.decoder)
                          .listen((event) {
                        if (kDebugMode) {
                          print(event);
                        }
                      });
                      final deviceIP =
                          await AppUtil.runPowerShellScript(deviceIPPath, []);
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
                            await Ffmpeg().run(command, path: fileFFMPEG.path);
                        outerProcess?.stderr
                            .transform(utf8.decoder)
                            .listen((event) {
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
                            future:
                                downloadFfmpegMona(monaExists, ffmpegExists),
                            message: 'Downloading FFMPEG / Mona');
                        if (!mounted) return;

                        showSnackbar(
                            context,
                            const Snackbar(
                                content: Text(
                                    'Downloaded FFMPEG / Mona, click again to start streaming')));
                      } catch (e, st) {
                        if (!mounted) return;
                        showSnackbar(
                            context,
                            const Snackbar(
                                content:
                                    Text('Failed to download FFMPEG / Mona')));
                        log(e.toString(), stackTrace: st);
                      }
                    }
                  } else {
                    isStreaming = false;
                    setState(() {});
                    Process.run('taskkill', ['/F', '/IM', 'ffmpeg.exe']);
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

  bool isStreaming = false;
  Process? outerProcess;
  Process? monaProcess;
  @override
  Widget build(BuildContext context) {
    final ipValue = ref.watch(provider.deviceIPProvider);
    return ScaffoldPage(
      content: Column(
        children: [
          GestureDetector(
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
          Expanded(child: settings(context)),
        ],
      ),
    );
  }
}
