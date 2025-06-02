import 'package:yakunstructuretest/core/api/api_service.dart';
import 'package:yakunstructuretest/data/models/medication_detail_model.dart';
import 'package:yakunstructuretest/data/models/medication_group_model.dart';
import 'package:yakunstructuretest/data/models/medication_item.dart';

class MedicationRecordModel {
  final int id;
  final int cycleId;
  final MedicationDetailModel medicationDetail;
  final String recordType;
  final DateTime recordDate;
  final double quantityTaken;
  final String notes;
  final String symptoms;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicationRecordModel({
    required this.id,
    required this.cycleId,
    required this.medicationDetail,
    required this.recordType,
    required this.recordDate,
    required this.quantityTaken,
    required this.notes,
    required this.symptoms,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicationRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicationRecordModel(
      id: json['id'],
      cycleId: json['cycle_id'],
      medicationDetail: MedicationDetailModel.fromJson(json['medication_detail']),
      recordType: json['record_type'],
      recordDate: DateTime.parse(json['record_date']),
      quantityTaken: json['quantity_taken'].toDouble(),
      notes: json['notes'] ?? '',
      symptoms: json['symptoms'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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

  Map<String, dynamic> toJson() => {
    'medication_detail_id': medicationDetailId,
    'record_type': recordType,
    'quantity_taken': quantityTaken,
    'notes': notes,
  };
}

// 복수 기록 응답 모델
class BulkRecordResponse {
  final List<MedicationRecordModel> createdRecords;
  final List<Map<String, dynamic>> failedRecords;
  final int totalRequested;
  final int totalCreated;
  final int totalFailed;

  BulkRecordResponse({
    required this.createdRecords,
    required this.failedRecords,
    required this.totalRequested,
    required this.totalCreated,
    required this.totalFailed,
  });

  factory BulkRecordResponse.fromJson(Map<String, dynamic> json) {
    return BulkRecordResponse(
      createdRecords: (json['created_records'] as List)
          .map((e) => MedicationRecordModel.fromJson(e))
          .toList(),
      failedRecords: List<Map<String, dynamic>>.from(json['failed_records']),
      totalRequested: json['total_requested'],
      totalCreated: json['total_created'],
      totalFailed: json['total_failed'],
    );
  }
}

// 오늘 복약 데이터 모델
class TodayMedicationData {
  final String userId;
  final DateTime todayDate;
  final List<MedicationGroupModel> medicationGroups;
  final OverallStats overallStats;

  TodayMedicationData({
    required this.userId,
    required this.todayDate,
    required this.medicationGroups,
    required this.overallStats,
  });

  factory TodayMedicationData.fromJson(Map<String, dynamic> json) {
    return TodayMedicationData(
      userId: json['user_id'],
      todayDate: DateTime.parse(json['today_date']),
      medicationGroups: (json['medication_groups'] as List)
          .map((e) => MedicationGroupModel.fromJson(e))
          .toList(),
      overallStats: OverallStats.fromJson(json['overall_stats']),
    );
  }
}

// 복약 기록 데이터 모델
class MedicationRecordsData {
  final List<MedicationRecordModel> records;
  final DateRange dateRange;
  final int totalCount;

  MedicationRecordsData({
    required this.records,
    required this.dateRange,
    required this.totalCount,
  });

  factory MedicationRecordsData.fromJson(Map<String, dynamic> json) {
    return MedicationRecordsData(
      records: (json['records'] as List)
          .map((e) => MedicationRecordModel.fromJson(e))
          .toList(),
      dateRange: DateRange.fromJson(json['date_range']),
      totalCount: json['total_count'],
    );
  }
}