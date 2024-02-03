import 'dart:developer';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

import '../main.dart';
import '../services/presence.dart';
import '../services/utility.dart';

class Message {
  final String title;
  final String subtitle;
  final int id;
  final String? url;
  final String? operation;
  final String? device;

  @override
  const Message(
      {required this.title,
      required this.subtitle,
      required this.id,
      this.url,
      this.operation,
      this.device});

  @override
  String toString() {
    return 'Message{title: $title, subtitle: $subtitle, id: $id, url: $url, operation: $operation, device: $device}';
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'id': id,
      'url': url,
      'operation': operation,
      'device': device,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      id: map['id'] as int,
      url: map['url'] as String?,
      operation: map['operation'] as String?,
      device: map['device'] as String?,
    );
  }

  static Future<void> getUserName(BuildContext context, data) async {
    if (prefs.getString('userName') == null ||
        prefs.getString('userName') == '') {
      try {
        showDialog(
            context: context,
            builder: (context) => dialogBuilderUserName(context, data));
      } catch (e) {
        return;
      }
    }
  }

  static Future<void> getUserNameCustom(BuildContext context, data) async {
    try {
      showDialog(
          context: context,
          builder: (context) => dialogBuilderUserName(context, data));
    } catch (e, st) {
      log(e.toString(), stackTrace: st);
    }
  }
}

ContentDialog dialogBuilderUserName(BuildContext context, data) {
  TextEditingController userNameController = TextEditingController();
  return ContentDialog(
    content: TextFormBox(
      onChanged: (value) {},
      validator: (value) {
        if (value != null) {
          return 'Username can\'t be empty';
        }
        if (value!.isEmpty) {
          return 'Username can\'t be empty';
        }
        return null;
      },
      controller: userNameController,
    ),
    title: const Text('Set a username (Forum username)'),
    actions: [
      Button(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel')),
      Button(
          onPressed: () async {
            Navigator.of(context).pop();
            await prefs.setString('userName', userNameController.text);
            await PresenceService().configureUserPresence(
                (await deviceInfo.windowsInfo).computerName,
                await File(AppUtil.versionPath).readAsString());
            if (data != null) {
              await prefs.setInt('id', data['id']);
            }
          },
          child: const Text('Save'))
    ],
  );
}

class Performance {
  final double memory;

  final double engine3D;

  final double engineCopy;

  const Performance({
    required this.memory,
    required this.engine3D,
    required this.engineCopy,
  });

  factory Performance.fromMap(Map<String, dynamic> map) {
    return Performance(
      memory: map['memory'] ?? 0,
      engine3D: map['engine3D'] ?? 0,
      engineCopy: map['engineCopy'] ?? 0,
    );
  }
}
