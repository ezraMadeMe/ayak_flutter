import 'package:flutter/material.dart';
import 'package:yakunstructuretest/data/models/medication_group_model.dart';
import 'package:yakunstructuretest/data/models/medication_item.dart';
import 'package:yakunstructuretest/data/models/medication_record_model.dart';
import 'package:yakunstructuretest/data/models/medication_stats_model.dart';

class PillData {
  final String name;
  final Color color;
  final String shape;
  final int medicationDetailId;
  final String? imageUrl;

  PillData({
    required this.name,
    required this.color,
    required this.shape,
    required this.medicationDetailId,
    this.imageUrl,
  });
}


// 오늘의 복약 데이터 모델
class TodayMedicationData {
  final List<MedicationGroupModel> medicationGroups;
  final OverallStats overallStats;
  final DateTime date;

  TodayMedicationData({
    required this.medicationGroups,
    required this.overallStats,
    required this.date,
  });

  factory TodayMedicationData.fromJson(Map<String, dynamic> json) {
    return TodayMedicationData(
      medicationGroups: (json['medication_groups'] as List)
          .map((e) => MedicationGroupModel.fromJson(e))
          .toList(),
      overallStats: OverallStats.fromJson(json['overall_stats']),
      date: DateTime.parse(json['date']),
    );
  }
}



/// 복약그룹의 특정 시간대 데이터
class MedicationGroupTimeData {
  final String groupId;
  final String groupName;
  final String dosageTime;
  final Map<String, List<MedicationItemData>> medicationsByTime;
  final Map<String, CompletionStatus> completionStatus;
  final List<PillData> pillDataList;

  MedicationGroupTimeData({
    required this.groupId,
    required this.groupName,
    required this.dosageTime,
    required this.medicationsByTime,
    required this.completionStatus,
    required this.pillDataList,
  });

  String get dosageTimeDisplayName {
    switch (dosageTime) {
      case 'morning':
        return '아침';
      case 'lunch':
        return '점심';
      case 'evening':
        return '저녁';
      case 'bedtime':
        return '취침전';
      case 'prn':
        return '필요시';
      default:
        return dosageTime;
    }
  }

  CompletionStatus? getCompletionStatus(String timeKey) {
    return completionStatus[timeKey];
  }
}



/// 복수 기록 생성 결과
class BulkRecordResult {
  final bool success;
  final int? totalRequested;
  final int? totalCreated;
  final int? totalFailed;
  final List<Map<String, dynamic>>? failedRecords;
  final String message;

  BulkRecordResult({
    required this.success,
    this.totalRequested,
    this.totalCreated,
    this.totalFailed,
    this.failedRecords,
    required this.message,
  });

  bool get hasPartialFailure => totalFailed != null && totalFailed! > 0;

  String get summaryMessage {
    if (!success) return message;

    if (totalCreated == totalRequested) {
      return '$totalCreated개 복약 기록이 모두 성공적으로 저장되었습니다.';
    } else {
      return '$totalCreated개 성공, $totalFailed개 실패';
    }
  }
}

/// HomeScreen에서 사용하는 오늘의 복약 현황
class TodayMedicationStatus {
  final int taken;
  final int missed;
  final int pending;
  final double completionRate;

  TodayMedicationStatus({
    required this.taken,
    required this.missed,
    required this.pending,
    required this.completionRate,
  });

  int get total => taken + missed + pending;
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

// 복약 기록 요청 모델
class MedicationRecordRequest {
  final int medicationDetailId;
  final String recordType;
  final double quantityTaken;
  final String notes;

  MedicationRecordRequest({
    required this.medicationDetailId,
    required this.recordType,
    required this.quantityTaken,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'medication_detail_id': medicationDetailId,
      'record_type': recordType,
      'quantity_taken': quantityTaken,
      'notes': notes,
    };
  }
}

// 복수 복약 기록 응답 모델
class BulkRecordResponse {
  final int totalRequested;
  final int totalCreated;
  final int totalFailed;
  final List<MedicationRecordModel> createdRecords;
  final List<Map<String, dynamic>> failedRecords;

  BulkRecordResponse({
    required this.totalRequested,
    required this.totalCreated,
    required this.totalFailed,
    required this.createdRecords,
    required this.failedRecords,
  });

  factory BulkRecordResponse.fromJson(Map<String, dynamic> json) {
    return BulkRecordResponse(
      totalRequested: json['total_requested'],
      totalCreated: json['total_created'],
      totalFailed: json['total_failed'],
      createdRecords: (json['created_records'] as List)
          .map((e) => MedicationRecordModel.fromJson(e))
          .toList(),
      failedRecords: List<Map<String, dynamic>>.from(json['failed_records']),
    );
  }
}

// 복약 기록 조회 응답 모델
class MedicationRecordsData {
  final List<MedicationRecordModel> records;
  final Map<String, int> recordTypeCounts;
  final DateTime startDate;
  final DateTime endDate;

  MedicationRecordsData({
    required this.records,
    required this.recordTypeCounts,
    required this.startDate,
    required this.endDate,
  });

  factory MedicationRecordsData.fromJson(Map<String, dynamic> json) {
    return MedicationRecordsData(
      records: (json['records'] as List)
          .map((e) => MedicationRecordModel.fromJson(e))
          .toList(),
      recordTypeCounts: Map<String, int>.from(json['record_type_counts']),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }
}

