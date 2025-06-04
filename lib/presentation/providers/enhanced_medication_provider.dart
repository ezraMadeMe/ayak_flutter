// enhanced_medication_provider.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yakunstructuretest/core/api/medication_api_service.dart';
import 'package:yakunstructuretest/data/models/medication_group_model.dart';
import 'package:yakunstructuretest/data/models/medication_item.dart';
import 'package:yakunstructuretest/data/models/medication_record_model.dart';
import 'package:yakunstructuretest/data/models/medication_stats_model.dart';
import 'package:yakunstructuretest/data/models/pill_data_model.dart';

class EnhancedMedicationProvider with ChangeNotifier {
  final MedicationApiService _apiService = MedicationApiService();

  // 상태 관리
  TodayMedicationData? _todayMedicationData;
  List<MedicationGroupModel> _medicationGroups = [];
  OverallStats? _overallStats;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  TodayMedicationData? get todayMedicationData => _todayMedicationData;
  List<MedicationGroupModel> get medicationGroups => _medicationGroups;
  OverallStats? get overallStats => _overallStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 오늘의 복약 데이터 로드
  Future<void> loadTodayMedications({String? date, String? groupId}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.getTodayMedications(
        date: date,
        groupId: groupId,
      );

      if (response.success && response.data != null) {
        _todayMedicationData = response.data!;
        _medicationGroups = response.data!.medicationGroups;
        _overallStats = response.data!.overallStats;

        notifyListeners();
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('복약 데이터 로드 실패: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 특정 복약그룹의 특정 시간대 약물 리스트 조회
  List<PillData> getMedicationsForTime(String groupId, String dosageTime) {
    final group = _medicationGroups.firstWhere(
          (g) => g.groupId == groupId,
      orElse: () => throw Exception('복약그룹을 찾을 수 없습니다: $groupId'),
    );

    return group.toPillDataList(dosageTime);
  }

  /// 현재 시간 기준 다음 복약 시간 조회
  Future<NextDosageData?> getNextDosageTime() async {
    try {
      final response = await _apiService.getNextDosageTime();

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        _setError(response.message);
        return null;
      }
    } catch (e) {
      _setError('다음 복약 시간 조회 실패: ${e.toString()}');
      return null;
    }
  }

  /// 홈화면용 첫 번째 복약 시간대 데이터 조회
  MedicationGroupTimeData? getFirstDosageTimeData() {
    if (_medicationGroups.isEmpty) return null;

    final firstGroup = _medicationGroups.first;
    if (firstGroup.dosageTimes.isEmpty) return null;

    return MedicationGroupTimeData(
      groupId: firstGroup.groupId,
      groupName: firstGroup.groupName,
      dosageTime: firstGroup.dosageTimes.first,
      medicationsByTime: firstGroup.medicationsByTime,
      pillDataList: firstGroup.toPillDataList(firstGroup.dosageTimes.first),
      completionStatus: {
        firstGroup.dosageTimes.first: CompletionStatus(
          total: firstGroup.medicationsByTime[firstGroup.dosageTimes.first]?.length ?? 0,
          taken: 0,
          completionRate: 0.0,
        ),
      },
    );
  }

  /// 단일 복약 기록 생성
  Future<bool> createMedicationRecord({
    required int medicationDetailId,
    required String recordType,
    required double quantityTaken,
    String notes = '',
    String symptoms = '',
  }) async {
    try {
      final response = await _apiService.createMedicationRecord(
        medicationDetailId: medicationDetailId,
        recordType: recordType,
        quantityTaken: quantityTaken,
        notes: notes,
        symptoms: symptoms,
      );

      if (response.success) {
        // 성공 시 로컬 데이터 업데이트
        await _updateLocalRecordStatus(medicationDetailId, recordType);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('복약 기록 생성 실패: ${e.toString()}');
      return false;
    }
  }

  /// 복수 복약 기록 생성 (PillGrid용)
  Future<BulkRecordResult> createBulkMedicationRecords({
    required List<PillData> selectedMedications,
    required String recordType,
    required String dosageTime,
    String notes = '',
  }) async {
    try {
      final records = selectedMedications.map((pill) => MedicationRecordRequest(
        medicationDetailId: pill.medicationDetailId,
        recordType: recordType,
        quantityTaken: recordType == 'TAKEN' ? 1.0 : 0.0,
        notes: '$dosageTime - $notes',
      )).toList();

      final response = await _apiService.createBulkMedicationRecords(
        records: records,
      );

      if (response.success && response.data != null) {
        final result = response.data!;

        // 성공한 기록들에 대해 로컬 상태 업데이트
        for (final record in result.createdRecords) {
          await _updateLocalRecordStatus(
            record.medicationDetail.id,
            record.recordType,
          );
        }

        return BulkRecordResult(
          success: true,
          totalRequested: result.totalRequested,
          totalCreated: result.totalCreated,
          totalFailed: result.totalFailed,
          failedRecords: result.failedRecords,
          message: response.message,
        );
      } else {
        return BulkRecordResult(
          success: false,
          message: response.message,
        );
      }
    } catch (e) {
      return BulkRecordResult(
        success: false,
        message: '복수 복약 기록 생성 실패: ${e.toString()}',
      );
    }
  }

  /// 로컬 데이터에서 복약 기록 상태 업데이트
  Future<void> _updateLocalRecordStatus(int medicationDetailId, String recordType) async {
    for (final group in _medicationGroups) {
      for (final timeKey in group.medicationsByTime.keys) {
        final medications = group.medicationsByTime[timeKey]!;

        for (int i = 0; i < medications.length; i++) {
          if (medications[i].medicationDetailId == medicationDetailId) {
            // 로컬 상태 업데이트
            final updatedMedication = MedicationItemData(
              medicationDetailId: medications[i].medicationDetailId,
              medication: medications[i].medication,
              dosageTime: medications[i].dosageTime,
              quantityPerDose: medications[i].quantityPerDose,
              unit: medications[i].unit,
              specialInstructions: medications[i].specialInstructions,
              isTakenToday: recordType == 'TAKEN',
              takenAt: DateTime.now(),
              recordType: recordType,
            );

            medications[i] = updatedMedication;

            // 완료 상태 재계산
            _recalculateCompletionStatus(group, timeKey);
            break;
          }
        }
      }
    }

    // 전체 통계 재계산
    _recalculateOverallStats();
    notifyListeners();
  }

  /// 완료 상태 재계산
  void _recalculateCompletionStatus(MedicationGroupModel group, String timeKey) {
    final medications = group.medicationsByTime[timeKey] ?? [];
    final total = medications.length;
    final taken = medications.where((m) => m.isTakenToday).length;

    group.completionStatus[timeKey] = CompletionStatus(
      total: total,
      taken: taken,
      completionRate: total > 0 ? taken / total : 0.0,
    );
  }

  /// 전체 통계 재계산
  void _recalculateOverallStats() {
    int totalMedications = 0;
    int totalTaken = 0;

    for (final group in _medicationGroups) {
      for (final timeKey in group.medicationsByTime.keys) {
        final status = group.completionStatus[timeKey];
        if (status != null) {
          totalMedications += status.total;
          totalTaken += status.taken;
        }
      }
    }

    _overallStats = OverallStats(
      totalMedications: totalMedications,
      totalTaken: totalTaken,
      totalMissed: totalMedications - totalTaken,
      overallCompletionRate: totalMedications > 0 ? totalTaken / totalMedications : 0.0,
    );

    notifyListeners();
  }

  /// 오늘의 복약 현황 요약 (HomeScreen용)
  TodayMedicationStatus get todayMedicationStatus {
    if (_overallStats == null) {
      return TodayMedicationStatus(
        taken: 0,
        missed: 0,
        pending: 0,
        completionRate: 0.0,
      );
    }

    return TodayMedicationStatus(
      taken: _overallStats!.totalTaken,
      missed: _overallStats!.totalMissed,
      pending: _overallStats!.totalMedications - _overallStats!.totalTaken,
      completionRate: _overallStats!.overallCompletionRate,
    );
  }

  /// 데이터 새로고침
  Future<void> refreshData() async {
    await loadTodayMedications();
  }

  /// 특정 날짜의 데이터 로드
  Future<void> loadDataForDate(DateTime date) async {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    await loadTodayMedications(date: dateString);
  }

  // 상태 관리 헬퍼 메소드들
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    // 필요시 리소스 정리
    super.dispose();
  }
}



