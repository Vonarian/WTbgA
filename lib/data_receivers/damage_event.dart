import '../main.dart';

class DamageEvents {
  List<Damage> damage;

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
    return 'DamageEvents{damage: $damage}';
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
      'damage': damage,
    };
  }

  factory DamageEvents.fromMap(Map<String, dynamic> map) {
    return DamageEvents(
      damage: map['damage'] as List<Damage>,
    );
  }
}

class Damage {
  int? id;
  String? msg;

  static Future<List<Damage>> getDamage() async {
    try {
      final response =
          await dio.get('http://localhost:8111/hudmsg?lastEvt=0&lastDmg=0');
      final damageEvents = response.data['damage']
          .map<Damage>((model) => Damage.fromMap(model))
          .toList();
      return damageEvents;
    } catch (e) {
      // log('Encountered error: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

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
    return 'Damage{id: $id, msg: $msg}';
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
      'id': id,
      'msg': msg,
    };
  }

  factory Damage.fromMap(Map<String, dynamic> map) {
    return Damage(
      id: map['id'],
      msg: map['msg'].toString(),
    );
  }
}
