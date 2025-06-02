

// 복약 아이템 데이터 모델
import 'package:yakunstructuretest/core/api/api_service.dart';

class MedicationItemData {
  final int medicationDetailId;
  final MedicationBasic medication;
  final String dosageTime;
  final double quantityPerDose;
  final String unit;
  final String specialInstructions;
  final bool isTakenToday;
  final DateTime? takenAt;
  final String? recordType;

  MedicationItemData({
    required this.medicationDetailId,
    required this.medication,
    required this.dosageTime,
    required this.quantityPerDose,
    required this.unit,
    required this.specialInstructions,
    required this.isTakenToday,
    this.takenAt,
    this.recordType,
  });

  factory MedicationItemData.fromJson(Map<String, dynamic> json) {
    return MedicationItemData(
      medicationDetailId: json['medication_detail_id'],
      medication: MedicationBasic.fromJson(json['medication']),
      dosageTime: json['dosage_time'],
      quantityPerDose: json['quantity_per_dose'].toDouble(),
      unit: json['unit'],
      specialInstructions: json['special_instructions'],
      isTakenToday: json['is_taken_today'],
      takenAt: json['taken_at'] != null ? DateTime.parse(json['taken_at']) : null,
      recordType: json['record_type'],
    );
  }
}


// 완료 상태 모델
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

// 전체 통계 모델
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

// 다음 복약 시간 모델
class NextDosageData {
  final String nextDosageTime;
  final DateTime targetDate;
  final List<MedicationItemData> medications;
  final int totalCount;

  NextDosageData({
    required this.nextDosageTime,
    required this.targetDate,
    required this.medications,
    required this.totalCount,
  });

  factory NextDosageData.fromJson(Map<String, dynamic> json) {
    return NextDosageData(
      nextDosageTime: json['next_dosage_time'],
      targetDate: DateTime.parse(json['target_date']),
      medications: (json['medications'] as List)
          .map((e) => MedicationItemData.fromJson(e))
          .toList(),
      totalCount: json['total_count'],
    );
  }
}
