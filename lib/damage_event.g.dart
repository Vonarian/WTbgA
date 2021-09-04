// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'damage_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DamageEvents _$DamageEventsFromJson(Map<String, dynamic> json) {
  return DamageEvents(
    damage: (json['damage'] as List<dynamic>)
        .map((e) => Damage.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Damage _$DamageFromJson(Map<String, dynamic> json) {
  return Damage(
    id: json['id'],
    msg: json['msg'],
  );
}
