class Flap {
  final int combatFlaps;
  final int takeoffFlaps;
  final List<double> states;
  final List<double> criticalSpeeds;

  const Flap({
    required this.combatFlaps,
    required this.takeoffFlaps,
    required this.states,
    required this.criticalSpeeds,
  });

  factory Flap.load(String combat, String takeoff, String critSpeeds) {
    final int combatFlaps = int.parse(combat);
    final int takeoffFlaps = int.parse(takeoff);
    final List<String> critSpeedsSplit = critSpeeds.split(',');
    final states = <double>[];
    final speeds = <double>[];
    for (int i = 0; i < critSpeedsSplit.length; i++) {
      final value = critSpeedsSplit[i];
      if (i.isEven) {
        states.add(double.parse(value));
      } else {
        speeds.add(double.parse(value));
      }
    }

    return Flap(
        combatFlaps: combatFlaps,
        takeoffFlaps: takeoffFlaps,
        criticalSpeeds: speeds,
        states: states);
  }

  @override
  String toString() {
    return 'Flap{combatFlaps: $combatFlaps, takeoffFlaps: $takeoffFlaps, states: $states, criticalSpeeds: $criticalSpeeds}';
  }
}
