class CritAirSpeed {
  final int critAirSpeed;
  final List<double> states;
  final List<int> critAirSpeeds;

  CritAirSpeed({
    required this.critAirSpeed,
    this.states = const [],
    this.critAirSpeeds = const [],
  });

  factory CritAirSpeed.load(String data) {
    final List<String> valuesSplit = data.split(',');
    if (valuesSplit.length == 1) {
      return CritAirSpeed(
        critAirSpeed: int.parse(valuesSplit[0]),
      );
    }
    final List<double> states = [];
    final List<int> critAirSpeeds = [];
    for (int i = 0; i < valuesSplit.length; i++) {
      if (i.isEven) {
        states.add(double.parse(valuesSplit[i]));
      }
      if (i.isOdd) {
        critAirSpeeds.add(int.parse(valuesSplit[i]));
      }
    }
    return CritAirSpeed(
      critAirSpeed: 0,
      states: states,
      critAirSpeeds: critAirSpeeds,
    );
  }

  bool get isVariable => critAirSpeeds.isNotEmpty && states.isNotEmpty;
  bool get notVariable => !isVariable;
}
