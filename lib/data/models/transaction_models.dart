
class HourlyTransaction {
  final String label;
  final double success;
  final double failed;

  HourlyTransaction({
    required this.label,
    required this.success,
    required this.failed,
  });
}

class SchemeReport {
  final String name;
  final int totalTxns;
  final int success;
  final int failed;
  final double successAmount;
  final double failedAmount;

  SchemeReport({
    required this.name,
    required this.totalTxns,
    required this.success,
    required this.failed,
    required this.successAmount,
    required this.failedAmount,
  });
}
