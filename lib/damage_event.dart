import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'damage_event.g.dart';

Future<DamageEvents> getDamageEvents() async {
  try {
    final response = await http
        .get(Uri.parse('http://localhost:8111/hudmsg?lastEvt=0&lastDmg=0'));
    final damageEvents = DamageEvents.fromJson(jsonDecode(response.body));
    return damageEvents;
  } catch (e, stackTrace) {
    log('Encountered error: $e', stackTrace: stackTrace);
    rethrow;
  }
}

@JsonSerializable(includeIfNull: false, createToJson: false)
class DamageEvents {
  List<Damage> damage;

  factory DamageEvents.fromJson(Map<String, dynamic> json) =>
      _$DamageEventsFromJson(json);

//<editor-fold desc="Data Methods">

  DamageEvents({
    required this.damage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DamageEvents &&
          runtimeType == other.runtimeType &&
          damage == other.damage);

  @override
  int get hashCode => damage.hashCode;

  @override
  String toString() {
    return 'DamageEvents{' + ' damage: $damage,' + '}';
  }

  DamageEvents copyWith({
    List<Damage>? damage,
  }) {
    return DamageEvents(
      damage: damage ?? this.damage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'damage': this.damage,
    };
  }

  factory DamageEvents.fromMap(Map<String, dynamic> map) {
    return DamageEvents(
      damage: map['damage'] as List<Damage>,
    );
  }

//</editor-fold>
}

@JsonSerializable(includeIfNull: false, createToJson: false)
class Damage {
  int? id;
  String? msg;
  static Future<List<Damage>> getDamage() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:8111/hudmsg?lastEvt=0&lastDmg=0'));
      final damageEvents = jsonDecode(response.body)["damage"]
          .map<Damage>((model) => Damage.fromMap(model))
          .toList();
      return damageEvents;
    } catch (e, stackTrace) {
      log('Encountered error: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  factory Damage.fromJson(Map<String, dynamic> json) => _$DamageFromJson(json);

//<editor-fold desc="Data Methods">

  Damage({
    required this.id,
    required this.msg,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Damage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          msg == other.msg);

  @override
  int get hashCode => id.hashCode ^ msg.hashCode;

  @override
  String toString() {
    return 'Damage{' + ' id: $id,' + ' msg: $msg,' + '}';
  }

  Damage copyWith({
    int? id,
    String? msg,
  }) {
    return Damage(
      id: id ?? this.id,
      msg: msg ?? this.msg,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'msg': this.msg,
    };
  }

  factory Damage.fromMap(Map<String, dynamic> map) {
    return Damage(
      id: map['id'] as int,
      msg: map['msg'] as String,
    );
  }

//</editor-fold>
}
