import 'dart:developer';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:version/version.dart';
import 'package:window_manager/window_manager.dart';

import '../data_receivers/github.dart';
import '../services/utility.dart';
import 'downloader.dart';
import 'home.dart';

class Loading extends StatefulWidget {
  final bool startup;
  final bool minimize;

  const Loading({super.key, required this.startup, required this.minimize});

  @override
  LoadingState createState() => LoadingState();
}

class LoadingState extends State<Loading> {
  Future<String> checkVersion() async {
    try {
      final File file = File(AppUtil.versionPath);
      final String version = await file.readAsString();
      return version;
    } catch (e, st) {
      log(e.toString(), stackTrace: st);
      rethrow;
    }
  }

  Future<void> checkAndUpdate(String version) async {
    try {
      GHData data = await GHData.getData();
      final ghVersion = Version.parse(data.tagName);
      final currentVersion = Version.parse(version);
      if (ghVersion > currentVersion) {
        if (!mounted) return;
        displayInfoBar(
          context,
          builder: (context, close) => InfoBar(
            severity: InfoBarSeverity.success,
            title: Text('Version: $version.'),
            content: const Text('Proceeding to update in 4 seconds!'),
            action: HyperlinkButton(
                child: const Text('Cancel update'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (c, a1, a2) => const Home(),
                      transitionsBuilder: (c, anim, a2, child) =>
                          FadeTransition(opacity: anim, child: child),
                      transitionDuration: const Duration(milliseconds: 1000),
                    ),
                  );
                }),
          ),
        );

        await Future.delayed(const Duration(seconds: 4), () async {});
        if (!mounted) return;
        Navigator.of(context)
            .pushReplacement(FluentPageRoute(builder: (context) {
          return const Downloader();
        }));
      } else {
        if (!mounted) return;

        displayInfoBar(
          context,
          builder: (context, close) => InfoBar(
            severity: InfoBarSeverity.success,
            title: Text('Version: $version'),
            content: const Text('Status: Up-to-date!'),
          ),
        );
        Navigator.pushReplacement(
          context,
          FluentPageRoute(builder: (context) => const Home()),
        );
      }
    } catch (e, st) {
      displayInfoBar(context,
          builder: (context, close) => const InfoBar(
                title: Text('Error!'),
                severity: InfoBarSeverity.error,
                content: Text('Error checking for update!'),
              ));
      log(e.toString(), stackTrace: st);
      Future.delayed(const Duration(seconds: 2), () async {
        Navigator.pushReplacement(
          context,
          FluentPageRoute(builder: (context) => const Home()),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await checkAndUpdate(await checkVersion());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.startup && widget.minimize) {
        await windowManager.minimize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ScaffoldPage(
          content: Center(
        child: Stack(children: [
          Center(
              child: AnimatedTextKit(
            isRepeatingAnimation: true,
            repeatForever: true,
            animatedTexts: [
              ColorizeAnimatedText(
                '..: Loading :..',
                textStyle: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                colors: [
                  Colors.purple,
                  Colors.white,
                ],
              ),
            ],
          )),
          const Center(
            child: SizedBox(
              height: 400,
              width: 400,
              child: ProgressRing(),
            ),
          ),
        ]),
      )),
    ]);
  }
}
