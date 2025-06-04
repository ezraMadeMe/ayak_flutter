
// 복약 그룹 모델
import 'dart:ui';


import 'package:yakunstructuretest/data/models/medication_item.dart';
import 'package:yakunstructuretest/data/models/medication_stats_model.dart';
import 'package:yakunstructuretest/data/models/pill_data_model.dart';
import 'package:yakunstructuretest/presentation/providers/enhanced_medication_provider.dart';

// 복약 그룹 데이터 모델
class MedicationGroupModel {
  final String groupId;
  final String groupName;
  final int cycleId;
  final int cycleNumber;
  final List<String> dosageTimes;
  final Map<String, List<MedicationItemData>> medicationsByTime;
  final Map<String, CompletionStatus> completionStatus;

  MedicationGroupModel({
    required this.groupId,
    required this.groupName,
    required this.cycleId,
    required this.cycleNumber,
    required this.dosageTimes,
    required this.medicationsByTime,
    required this.completionStatus,
  });

  factory MedicationGroupModel.fromJson(Map<String, dynamic> json) {
    final medicationsByTimeMap = <String, List<MedicationItemData>>{};
    final medicationsByTimeJson = json['medications_by_time'] as Map<String, dynamic>;

    for (final entry in medicationsByTimeJson.entries) {
      medicationsByTimeMap[entry.key] = (entry.value as List)
          .map((e) => MedicationItemData.fromJson(e))
          .toList();
    }

    final completionStatusMap = <String, CompletionStatus>{};
    final completionStatusJson = json['completion_status'] as Map<String, dynamic>;

    for (final entry in completionStatusJson.entries) {
      completionStatusMap[entry.key] = CompletionStatus.fromJson(entry.value);
    }

    return MedicationGroupModel(
      groupId: json['group_id'],
      groupName: json['group_name'],
      cycleId: json['cycle_id'],
      cycleNumber: json['cycle_number'],
      dosageTimes: List<String>.from(json['dosage_times']),
      medicationsByTime: medicationsByTimeMap,
      completionStatus: completionStatusMap,
    );
  }

  // PillGrid에서 사용할 PillData로 변환
  List<PillData> toPillDataList(String dosageTime) {
    final medications = medicationsByTime[dosageTime] ?? [];
    return medications.map((medication) => PillData(
      name: medication.medication.itemName,
      color: _getMedicationColor(medication.medication.className),
      shape: _getMedicationShape(medication.medication.dosageForm),
      medicationDetailId: medication.medicationDetailId,
      imageUrl: medication.medication.itemImage,
    )).toList();
  }

  // 약물 분류에 따른 색상 매핑
  Color _getMedicationColor(String className) {
    switch (className.toLowerCase()) {
      case 'ssri':
        return Color(0xFF4ECDC4);
      case 'nsaid':
        return Color(0xFF96CEB4);
      case 'analgesic':
        return Color(0xFFFF6B35);
      case 'ppi':
        return Color(0xFFDDA0DD);
      default:
        return Color(0xFF45B7D1);
    }
  }

  // 제형에 따른 모양 매핑
  String _getMedicationShape(String dosageForm) {
    switch (dosageForm.toLowerCase()) {
      case '정제':
      case 'tablet':
        return 'round';
      case '캡슐':
      case 'capsule':
        return 'capsule';
      case '필름정':
        return 'oval';
      default:
        return 'round';
    }
  }
}