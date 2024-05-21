import 'dart:developer';

import '../main.dart';

class GameChat {
  final int id;
  final String message;
  final String sender;
  final bool enemy;
  final String mode;

  const GameChat({
    required this.id,
    required this.message,
    required this.sender,
    required this.enemy,
    required this.mode,
  });

  static Future<GameChat> getChat(int lastId) async {
    try {
      final response =
          await dio.get('http://localhost:8111/gamechat?lastId=$lastId');
      return GameChat.fromMap(response.data.last);
    } catch (e, st) {
      log(e.toString(), stackTrace: st);
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'msg': message,
      'sender': sender,
      'enemy': enemy,
      'mode': mode,
    };
  }

  factory GameChat.fromMap(Map<String, dynamic> map) {
    return GameChat(
      id: map['id'] as int,
      message: map['msg'] as String,
      sender: map['sender'] as String,
      enemy: map['enemy'] as bool,
      mode: map['mode'] as String,
    );
  }
}
