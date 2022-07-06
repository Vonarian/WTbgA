import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:color/color.dart' as c;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:openrgb/data/data.dart';

import '../main.dart';
import '../services/presence.dart';

class Message {
  final String title;
  final String subtitle;
  final int id;
  final String? url;
  final String? operation;
  final String? device;

  @override
  const Message({required this.title,
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
      } catch (e, st) {
        log(e.toString(), stackTrace: st);
      }
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
                await File(versionPath).readAsString());
            await prefs.setInt('id', data['id']);
          },
          child: const Text('Save'))
    ],
  );
}

class OpenRGBSettings {
  final OverHeatSettings overHeat;
  final FireSettings fireSettings;

  const OpenRGBSettings({
    required this.overHeat,
    required this.fireSettings,
  });

  OpenRGBSettings copyWith({
    OverHeatSettings? overHeat,
    FireSettings? fireSettings,
  }) {
    return OpenRGBSettings(
      overHeat: overHeat ?? this.overHeat,
      fireSettings: fireSettings ?? this.fireSettings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'overHeat': overHeat,
      'fireSettings': fireSettings,
    };
  }

  factory OpenRGBSettings.fromMap(Map<String, dynamic> map) {
    return OpenRGBSettings(
      overHeat: map['overHeat'] as OverHeatSettings,
      fireSettings: map['fireSettings'] as FireSettings,
    );
  }
}

class OverHeatSettings {
  final c.Color color;
  final ModeData? mode;

  const OverHeatSettings({
    required this.color,
    this.mode,
  });

  Map<String, dynamic> toMap() {
    return {
      'color': color,
      'mode': mode,
    };
  }

  factory OverHeatSettings.fromMap(Map<String, dynamic> map) {
    return OverHeatSettings(
      color: map['color'] as c.Color,
      mode: map['mode'] as ModeData?,
    );
  }
}

class FireSettings {
  final c.Color color;
  final ModeData? mode;

  const FireSettings({
    required this.color,
    this.mode,
  });

  Map<String, dynamic> toMap() {
    return {
      'color': color,
      'mode': mode,
    };
  }

  factory FireSettings.fromMap(Map<String, dynamic> map) {
    return FireSettings(
      color: map['color'] as c.Color,
      mode: map['mode'] as ModeData?,
    );
  }
}


extension ToRGB on ui.Color{
  c.Color toRGB() {
    return c.Color.rgb(red, green, blue);
  }
}