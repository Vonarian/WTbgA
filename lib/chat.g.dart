// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatEvents _$ChatEventsFromJson(Map<String, dynamic> json) {
  return ChatEvents(
    id: json['id'] as int?,
    msg: json['msg'] as String?,
    sender: json['sender'] as String?,
    enemy: json['enemy'] as bool?,
    mode: json['mode'] as String?,
  );
}

Map<String, dynamic> _$ChatEventsToJson(ChatEvents instance) =>
    <String, dynamic>{
      'id': instance.id,
      'msg': instance.msg,
      'sender': instance.sender,
      'enemy': instance.enemy,
      'mode': instance.mode,
    };
