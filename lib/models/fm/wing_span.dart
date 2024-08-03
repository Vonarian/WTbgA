class WingSpan {
  final double span;
  final List<double> states;
  final List<double> spans;

  const WingSpan({
    required this.span,
    this.states = const [],
    this.spans = const [],
  });

  bool get isVariable => spans.isNotEmpty && states.isEmpty;

  factory WingSpan.load(String value, {required bool isSweptWing}) {
    if (!isSweptWing) {
      return WingSpan(
        span: double.parse(value),
      );
    } else {
      final split = value.split(',');
      final states = <double>[];
      final spans = <double>[];
      for (int i = 0; i < split.length; i++) {
        if (i.isEven) {
          states.add(double.parse(split[i]));
        } else {
          spans.add(double.parse(split[i]));
        }
      }
      return WingSpan(
        span: 0,
        states: states,
        spans: spans,
      );
    }
  }

  @override
  String toString() {
    return 'WingSpan{span: $span, states: $states, spans: $spans}';
  }
}
