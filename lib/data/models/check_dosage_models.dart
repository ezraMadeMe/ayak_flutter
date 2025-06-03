
// data/models/check_dosage_models.dart
import 'package:yakunstructuretest/data/models/medication_group_model.dart';
import 'package:yakunstructuretest/data/models/medication_item.dart';
import 'package:yakunstructuretest/data/models/medication_record_model.dart';

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

class MedicationRecordsData {
  final List<MedicationRecordModel> records;
  final DateRange dateRange;
  final int totalCount;
  final Map<String, dynamic>? filters;

  MedicationRecordsData({
    required this.records,
    required this.dateRange,
    required this.totalCount,
    this.filters,
  });

  factory MedicationRecordsData.fromJson(Map<String, dynamic> json) {
    return MedicationRecordsData(
      records: (json['records'] as List)
          .map((e) => MedicationRecordModel.fromJson(e))
          .toList(),
      dateRange: DateRange.fromJson(json['date_range']),
      totalCount: json['total_count'],
      filters: json['filters'],
    );
  }
}

class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  DateRange({required this.startDate, required this.endDate});

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }
}