import '../main.dart';

class Damage {
  final int id;
  final String msg;

  static Future<Damage> getDamages(int lastDmg) async {
    try {
      final response = await dio.get('http://localhost:8111/hudmsg?lastEvt=0&lastDmg=$lastDmg');
      final damageEvents =
          response.data['damage'].map<Damage>((model) => Damage.fromMap(model)).toList() as List<Damage>;
      final damage = damageEvents.isNotEmpty ? damageEvents.last : const Damage(id: 0, msg: '');
      return damage;
    } catch (e) {
      // log('Encountered error: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  const Damage({
    required this.id,
    required this.msg,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Damage && runtimeType == other.runtimeType && id == other.id && msg == other.msg);

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
      msg: map['msg'],
    );
  }
}
