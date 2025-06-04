

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

