import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;


class ChatEvents {
  int? id;
  String? msg;
  String? sender;
  bool? enemy;
  String? mode;
  static Future<List<ChatEvents>> getChat() async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:8111/gamechat?lastId=%27+lastChatRecId'));
      final chatEvents = jsonDecode(response.body)
          .map<ChatEvents>((model) => ChatEvents.fromMap(model))
          .toList();
      return chatEvents;
    } catch (e, stackTrace) {
      log('Encountered error: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  ChatEvents.fromJson(Map<String, dynamic> json) {
    id = json["id"]?.toInt();
    msg = json["msg"]?.toString();
    sender = json["sender"]?.toString();
    enemy = json["enemy"];
    mode = json["mode"]?.toString();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["id"] = id;
    data["msg"] = msg;
    data["sender"] = sender;
    data["enemy"] = enemy;
    data["mode"] = mode;
    return data;
  }

//<editor-fold desc="Data Methods">

  ChatEvents({
    this.id,
    this.msg,
    this.sender,
    this.enemy,
    this.mode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatEvents &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          msg == other.msg &&
          sender == other.sender &&
          enemy == other.enemy &&
          mode == other.mode);

  @override
  int get hashCode =>
      id.hashCode ^
      msg.hashCode ^
      sender.hashCode ^
      enemy.hashCode ^
      mode.hashCode;

  @override
  String toString() {
    return 'ChatEvents{' +
        ' id: $id,' +
        ' msg: $msg,' +
        ' sender: $sender,' +
        ' enemy: $enemy,' +
        ' mode: $mode,' +
        '}';
  }

  ChatEvents copyWith({
    int? id,
    String? msg,
    String? sender,
    bool? enemy,
    String? mode,
  }) {
    return ChatEvents(
      id: id ?? this.id,
      msg: msg ?? this.msg,
      sender: sender ?? this.sender,
      enemy: enemy ?? this.enemy,
      mode: mode ?? this.mode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'msg': this.msg,
      'sender': this.sender,
      'enemy': this.enemy,
      'mode': this.mode,
    };
  }

  factory ChatEvents.fromMap(Map<String, dynamic> map) {
    return ChatEvents(
      id: map['id'] as int,
      msg: map['msg'] as String,
      sender: map['sender'] as String,
      enemy: map['enemy'] as bool,
      mode: map['mode'] as String,
    );
  }

//</editor-fold>
}
