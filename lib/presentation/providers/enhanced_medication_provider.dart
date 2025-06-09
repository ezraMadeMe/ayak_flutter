// enhanced_medication_provider.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yakunstructuretest/core/api/medication_api_service.dart';
import 'package:yakunstructuretest/data/models/check_dosage_models.dart';
import 'package:yakunstructuretest/data/models/medication_group_model.dart';
import 'package:yakunstructuretest/data/models/medication_item.dart' hide NextDosageData;



class EnhancedMedicationProvider with ChangeNotifier {
  final MedicationApiService _apiService = MedicationApiService();

  // 상태 관리
  TodayMedicationData? _todayMedicationData;
  List<MedicationGroupModel> _medicationGroups = [];
  OverallStats? _overallStats;
  bool _isLoading = false;
  String? _errorMessage;
  final Set<PillData> _selectedMedications = {};

  // Getters
  TodayMedicationData? get todayMedicationData => _todayMedicationData;
  List<MedicationGroupModel> get medicationGroups => _medicationGroups;
  OverallStats? get overallStats => _overallStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Set<PillData> get selectedMedications => _selectedMedications;

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

  /// 홈화면 - 복약이 도래한 가장 가까운 복약 스케줄
  MedicationGroupTimeData? getFirstDosageTimeData(MedicationGroupModel group) {
    MedicationGroupModel? firstGroup;
    Map<String, List<MedicationItemData>>? medications;
    CompletionStatus? completionStatus;
    String? firstTime;

    if (_medicationGroups.isEmpty || group.dosageTimes.isEmpty) {
      return null;
    } else if (_medicationGroups.length == 1) {
      firstGroup = _medicationGroups.first;
      firstTime = firstGroup.dosageTimes.first;
      medications = firstGroup.medicationsByTime;
      completionStatus = firstGroup.completionStatus[firstTime];
      if (firstGroup.dosageTimes.isEmpty) return null;
    } else if (group.dosageTimes.length > 0) {
      firstGroup = _medicationGroups.first;
      firstTime = group.dosageTimes.first;
      medications = group.medicationsByTime;
      completionStatus = group.completionStatus[firstTime];
    }

    return MedicationGroupTimeData(
      groupId: firstGroup!.groupId,
      groupName: firstGroup.groupName,
      dosageTime: firstTime!,
      medications: medications![firstTime]!,
      completionStatus: completionStatus,
      pillDataList: firstGroup.toPillDataList(firstTime),
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
            record.medicationDetail.cycleId,
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


            MedicationGroupTimeData? timeData = getFirstDosageTimeData(group);

            // 완료 상태 재계산
            _recalculateCompletionStatus(timeData!, timeKey);
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
  void _recalculateCompletionStatus(MedicationGroupTimeData group, String timeKey) {
    final medications = group.medications ?? [];
    final total = medications.length;
    final taken = medications.where((m) => m.isTakenToday).length;

    group.completionStatus = CompletionStatus(
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
      for (final status in group.completionStatus.values) {
        totalMedications += status.total;
        totalTaken += status.taken;
      }
    }

    _overallStats = OverallStats(
      totalMedications: totalMedications,
      totalTaken: totalTaken,
      totalMissed: totalMedications - totalTaken,
      overallCompletionRate: totalMedications > 0 ? totalTaken / totalMedications : 0.0,
    );
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

  void addMedication(PillData medication) {
    _selectedMedications.add(medication);
    notifyListeners();
  }

  void removeMedication(PillData medication) {
    _selectedMedications.remove(medication);
    notifyListeners();
  }

  void clearSelection() {
    _selectedMedications.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    // 필요시 리소스 정리
    super.dispose();
  }
}

// === 추가 데이터 모델들 ===

/// 복약그룹의 특정 시간대 데이터
class MedicationGroupTimeData {
  final String groupId;
  final String groupName;
  final String dosageTime;
  final List<MedicationItemData> medications;
  late final CompletionStatus? completionStatus;
  final List<PillData> pillDataList;

  MedicationGroupTimeData({
    required this.groupId,
    required this.groupName,
    required this.dosageTime,
    required this.medications,
    this.completionStatus,
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

// === PillData 모델 (기존 PillGrid.dart에서 이동) ===
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