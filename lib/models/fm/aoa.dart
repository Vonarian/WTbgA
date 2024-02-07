// Two pairs: No Flaps and Full flaps
// From 19.5,-16,22.5,-15

class CritAoA {
  final List<double> noFlaps; // Positive
  final List<double> fullFlaps; // Negative

  const CritAoA({required this.noFlaps, required this.fullFlaps});

  factory CritAoA.load(String values) {
    final List<String> valuesSplit = values.split(',');
    final noFlaps = valuesSplit.take(2).map((e) => double.parse(e)).toList();
    final fullFlaps = valuesSplit.skip(2).map((e) => double.parse(e)).toList();
    return CritAoA(noFlaps: noFlaps, fullFlaps: fullFlaps);
  }

  @override
  String toString() {
    return 'CritAoA{noFlaps: $noFlaps, fullFlaps: $fullFlaps}';
  }
}
