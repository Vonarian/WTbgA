import 'dart:developer';
import 'dart:io';

import 'package:blinking_text/blinking_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:wtbgassistant/data_receivers/github.dart';

import '../main.dart';
import 'downloader.dart';
import 'home.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  LoadingState createState() => LoadingState();
}

class LoadingState extends State<Loading> {
  Future<String> checkVersion() async {
    try {
      final File file = File(versionPath);
      final String version = await file.readAsString();
      return version;
    } catch (e, st) {
      log(e.toString(), stackTrace: st);
      rethrow;
    }
  }

  Future<void> checkGitVersion(String version) async {
    try {
      Data data = await Data.getData();
      if (int.parse(data.tagName.replaceAll('.', '')) >
          int.parse(version.replaceAll('.', ''))) {
        if (!mounted) return;
        showSnackbar(
            context,
            Snackbar(
              content: Text(
                  'Version: $version. Status: Proceeding to update in 4 seconds!'),
              action: TextButton(
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
            ));

        Future.delayed(const Duration(seconds: 4), () async {
          Navigator.of(context)
              .pushReplacement(FluentPageRoute(builder: (context) {
            return const Downloader();
          }));
        });
      } else {
        if (!mounted) return;

        showSnackbar(
            context,
            Snackbar(
                content: Text('Version: $version ___ Status: Up-to-date!')));
        Future.delayed(const Duration(microseconds: 500), () async {
          Navigator.pushReplacement(
            context,
            FluentPageRoute(builder: (context) => const Home()),
          );
        });
      }
    } catch (e, st) {
      showSnackbar(
          context,
          Snackbar(
              content: Text(
                  'Version: $version ___ Status: Error checking for update!')));
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
      await checkGitVersion(await checkVersion());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ScaffoldPage(
          content: Center(
        child: Stack(children: [
          Center(
            child: BlinkText(
              '..: Loading :..',
              style: TextStyle(
                  color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
              endColor: Colors.purple,
            ),
          ),
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
