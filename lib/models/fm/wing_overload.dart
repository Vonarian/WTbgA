class WingOverload {
  final int positive;
  final int negative;

  const WingOverload({
    required this.positive,
    required this.negative,
  });

  factory WingOverload.load(String values) {
    final split = values.split(',');
    final negative = split[0];
    final positive = split[1];
    return WingOverload(
      positive: int.parse(positive),
      negative: int.parse(negative),
    );
  }

  @override
  String toString() {
    return 'WingOverload{positive: $positive, negative: $negative}';
  }
}
