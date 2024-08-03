class CritAirSpeedMach {
  final double critMach;
  final List<double> states;
  final List<double> critSpeeds;

  const CritAirSpeedMach({
    required this.critMach,
    this.states = const [],
    this.critSpeeds = const [],
  });

  factory CritAirSpeedMach.load(String data, {required bool isSweptWing}) {
    if (!isSweptWing) {
      return CritAirSpeedMach(
        critMach: double.parse(data),
      );
    }
    final List<String> valuesSplit = data.split(',');

    final List<double> states = [];
    final List<double> critSpeeds = [];
    for (int i = 0; i < valuesSplit.length; i++) {
      if (i.isEven) {
        states.add(double.parse(valuesSplit[i]));
      }
      if (i.isOdd) {
        critSpeeds.add(double.parse(valuesSplit[i]));
      }
    }
    return CritAirSpeedMach(
      critMach: 0,
      states: states,
      critSpeeds: critSpeeds,
    );
  }
}
