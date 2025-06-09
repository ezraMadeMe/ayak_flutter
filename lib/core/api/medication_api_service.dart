// medication_api_service.dart

import 'package:yakunstructuretest/core/api/api_service.dart';
import 'package:yakunstructuretest/data/models/check_dosage_models.dart';
import 'package:yakunstructuretest/data/models/medication_record_model.dart';

class MedicationApiService extends ApiService {
  // 싱글톤 패턴
  static final MedicationApiService _instance = MedicationApiService._internal();
  factory MedicationApiService() => _instance;
  MedicationApiService._internal() : super();

  /// 오늘의 복약 데이터 조회
  Future<ApiResponse<TodayMedicationData>> getTodayMedications({
    String? date, // YYYY-MM-DD
    String? groupId,
  }) async {
    final queryParams = <String, String>{};
    if (date != null) queryParams['date'] = date;
    if (groupId != null) queryParams['group_id'] = groupId;

    return makeRequest<TodayMedicationData>(
      method: 'GET',
      endpoint: '/medications/today',
      queryParams: queryParams,
      fromJson: (json) => TodayMedicationData.fromJson(json),
    );
  }

  /// 다음 복약 시간 조회
  Future<ApiResponse<NextDosageData>> getNextDosageTime() async {
    return makeRequest<NextDosageData>(
      method: 'GET',
      endpoint: '/medications/next-dosage',
      fromJson: (json) => NextDosageData.fromJson(json),
    );
  }

  /// 단일 복약 기록 생성
  Future<ApiResponse<MedicationRecordModel>> createMedicationRecord({
    required int medicationDetailId,
    required String recordType,
    required double quantityTaken,
    String notes = '',
    String symptoms = '',
  }) async {
    final data = {
      'medication_detail_id': medicationDetailId,
      'record_type': recordType,
      'quantity_taken': quantityTaken,
      'notes': notes,
      'symptoms': symptoms,
    };

    return makeRequest<MedicationRecordModel>(
      method: 'POST',
      endpoint: '/medications/records',
      data: data,
      fromJson: (json) => MedicationRecordModel.fromJson(json),
    );
  }

  /// 복수 복약 기록 생성 (PillGrid용)
  Future<ApiResponse<BulkRecordResponse>> createBulkMedicationRecords({
    required List<MedicationRecordRequest> records,
  }) async {
    final data = {
      'records': records.map((r) => r.toJson()).toList(),
    };

    return makeRequest<BulkRecordResponse>(
      method: 'POST',
      endpoint: '/medications/records/bulk',
      data: data,
      fromJson: (json) => BulkRecordResponse.fromJson(json),
    );
  }

  /// 복약 기록 조회
  Future<ApiResponse<MedicationRecordsData>> getMedicationRecords({
    String? startDate,
    String? endDate,
    String? groupId,
    String? recordType,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;
    if (groupId != null) queryParams['group_id'] = groupId;
    if (recordType != null) queryParams['record_type'] = recordType;

    return makeRequest<MedicationRecordsData>(
      method: 'GET',
      endpoint: '/medications/records',
      queryParams: queryParams,
      fromJson: (json) => MedicationRecordsData.fromJson(json),
    );
  }
}