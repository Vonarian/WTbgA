class WingArea {
  final double area;
  final List<double> states;
  final List<double> wingAreas;

  const WingArea({
    required this.area,
    this.states = const [],
    this.wingAreas = const [],
  });

  factory WingArea.load(String value, {required bool isSweptWing}) {
    if (!isSweptWing) {
      return WingArea(
        area: double.parse(value),
      );
    } else {
      final split = value.split(',');

      final states = <double>[];
      final wingAreas = <double>[];
      for (int i = 0; i < split.length; i++) {
        final value = split[i];
        if (i.isEven) {
          states.add(double.parse(value));
        } else {
          wingAreas.add(double.parse(value));
        }
      }
      return WingArea(area: 0, states: states, wingAreas: wingAreas);
    }
  }

  bool get isVariable => states.isNotEmpty && wingAreas.isNotEmpty;

  double areaFromState(double state) {
    final index = states.indexOf(state);
    if (index == -1) {
      return 0;
    }
    return wingAreas[index];
  }

  @override
  String toString() {
    return 'WingArea{area: $area, states: $states, wingAreas: $wingAreas}';
  }
}
