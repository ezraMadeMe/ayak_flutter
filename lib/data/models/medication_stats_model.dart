// 복약 통계 관련 모델
class CompletionStatus {
  final int total;
  final int taken;
  final double completionRate;

  CompletionStatus({
    required this.total,
    required this.taken,
    required this.completionRate,
  });

  factory CompletionStatus.fromJson(Map<String, dynamic> json) {
    return CompletionStatus(
      total: json['total'],
      taken: json['taken'],
      completionRate: json['completion_rate'].toDouble(),
    );
  }
}

class OverallStats {
  final int totalMedications;
  final int totalTaken;
  final int totalMissed;
  final double overallCompletionRate;

  OverallStats({
    required this.totalMedications,
    required this.totalTaken,
    required this.totalMissed,
    required this.overallCompletionRate,
  });

  factory OverallStats.fromJson(Map<String, dynamic> json) {
    return OverallStats(
      totalMedications: json['total_medications'],
      totalTaken: json['total_taken'],
      totalMissed: json['total_missed'],
      overallCompletionRate: json['overall_completion_rate'].toDouble(),
    );
  }
}


