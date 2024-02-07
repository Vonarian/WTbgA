class RPM {
  final int low;
  final int high;
  final int max;

  const RPM({required this.low, required this.high, required this.max});

  factory RPM.load(String values) {
    final List<String> valuesSplit = values.split(',');
    final lowRpm = int.parse(valuesSplit[0]);
    final high = int.parse(valuesSplit[1]);
    final maxRpm = int.parse(valuesSplit[2]);
    return RPM(low: lowRpm, high: high, max: maxRpm);
  }

  @override
  String toString() {
    return 'RPM{low: $low, high: $high, max: $max}';
  }
}
