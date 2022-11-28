import 'dart:async';

import 'package:dio/dio.dart';

import '../main.dart';

class IndicatorData {
  final String? type;
  final double? throttle;
  final double? mach;
  final double? compass;
  final double? engine;
  final double? flap1;
  final double? flap2;
  final double? vertical;
  final bool valid;

  const IndicatorData(
      {required this.type,
      required this.throttle,
      required this.mach,
      required this.compass,
      required this.engine,
      required this.flap1,
      required this.flap2,
      required this.vertical,
      required this.valid});

  static Stream<IndicatorData?> getIndicator() async* {
    final stream =
        Stream.periodic(const Duration(milliseconds: 200), (_) async {
      try {
        final Response response = await dio
            .get('http://localhost:8111/indicators')
            .timeout(const Duration(milliseconds: 200));
        final IndicatorData toolDataState =
            IndicatorData.fromMap(response.data);
        return toolDataState;
      } catch (e) {
        return null;
      }
    }).asBroadcastStream();
    await for (var value in stream) {
      yield await value;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': type,
      'throttle': throttle,
      'mach': mach,
      'compass': compass,
      'engine': engine,
      'flap1': flap1,
      'flap2': flap2,
      'aviahorizon_pitch': vertical,
      'valid': valid,
    };
  }

  factory IndicatorData.fromMap(Map<String, dynamic> map) {
    return IndicatorData(
      type: map['type'],
      throttle: map['throttle'],
      mach: map['mach'],
      compass: map['compass'],
      engine: map['engine'],
      flap1: map['flap1'],
      flap2: map['flap2'],
      vertical: map['aviahorizon_pitch'],
      valid: map['valid'],
    );
  }
}
