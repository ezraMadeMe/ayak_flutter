import 'package:flutter/material.dart';
import 'package:yakunstructuretest/data/models/medication_detail_model.dart';
import 'package:yakunstructuretest/data/models/medication_model.dart';
import 'package:yakunstructuretest/data/models/medication_record_model.dart';

class ScheduleItem {
  final String id;
  final ScheduleType type;
  final String title;
  final String subtitle;
  final DateTime scheduledDate;
  final double? progress;
  final Map<String, dynamic>? additionalData;

  ScheduleItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.scheduledDate,
    this.progress,
    this.additionalData,
  });

  int get daysRemaining {
    final now = DateTime.now();
    final difference = scheduledDate.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  String get daysRemainingText {
    final days = daysRemaining;
    if (days < 0) return "D+${(-days)}";
    if (days == 0) return "D-Day";
    return "D-$days";
  }
}

class HomeProvider with ChangeNotifier {
  List<dynamic> get urgentNotifications => [];
  List<dynamic> get upcomingSchedules => [
    ScheduleItem(id: 'prescription_001', type: ScheduleType.prescription, title: '다가오는 처방 종료일', subtitle: '다음 진료 예약 필요', scheduledDate: DateTime.parse("2025-06-03"), progress: 0.5),
    ScheduleItem(id: 'hospital_001', type: ScheduleType.hospital, title: '서울대학교병원 내원', subtitle: '정신건강의학과 - 김민수 교수', scheduledDate: DateTime.parse("2025-05-20"),progress: 0.3),
    ScheduleItem(id: 'hospital_001', type: ScheduleType.medication, title: '정신과 약물 복약 그룹', subtitle: '9월 16일자 처방', scheduledDate: DateTime.parse("2025-09-16"), progress: 0.7),
  ];

  Future<void> loadHomeData() async {
    await Future.delayed(Duration(milliseconds: 500));
  }

  Future<void> refreshHomeData() async {
    await Future.delayed(Duration(milliseconds: 300));
  }
}

enum ScheduleType {
  hospital,
  medication,
  appointment,
  prescription
}

// RecordType 열거형 정의
enum RecordType {
  taken,    // 복용 완료
  missed,   // 복용 누락
  skipped,  // 의도적 건너뜀
  delayed,  // 지연 복용
  partial,  // 부분 복용
}

// RecordType 확장 메서드
extension RecordTypeExtension on RecordType {
  String get displayName {
    switch (this) {
      case RecordType.taken:
        return '복용 완료';
      case RecordType.missed:
        return '복용 누락';
      case RecordType.skipped:
        return '건너뜀';
      case RecordType.delayed:
        return '지연 복용';
      case RecordType.partial:
        return '부분 복용';
    }
  }

  String get apiValue {
    switch (this) {
      case RecordType.taken:
        return 'TAKEN';
      case RecordType.missed:
        return 'MISSED';
      case RecordType.skipped:
        return 'SKIPPED';
      case RecordType.delayed:
        return 'DELAYED';
      case RecordType.partial:
        return 'PARTIAL';
    }
  }

  static RecordType fromApiValue(String value) {
    switch (value) {
      case 'TAKEN':
        return RecordType.taken;
      case 'MISSED':
        return RecordType.missed;
      case 'SKIPPED':
        return RecordType.skipped;
      case 'DELAYED':
        return RecordType.delayed;
      case 'PARTIAL':
        return RecordType.partial;
      default:
        return RecordType.taken;
    }
  }
}

class MedicationProvider with ChangeNotifier {
  List<MedicationDetailModel> _todayMedications = [];
  List<MedicationRecordModel> _medicationRecords = [];
  bool _isLoading = false;

  List<MedicationDetailModel> get todayMedications => _todayMedications;
  List<MedicationRecordModel> get medicationRecords => _medicationRecords;
  bool get isLoading => _isLoading;

  // 누락된 메서드 1: 모든 복약 기록 가져오기
  List<MedicationRecordModel> getAllMedicationRecords() {
    return _medicationRecords;
  }

  // 누락된 메서드 2: ID로 약물 상세 정보 가져오기
  MedicationDetailModel? getMedicationDetailById(int medicationDetailId) {
    try {
      return _todayMedications.firstWhere(
            (detail) => detail.id == medicationDetailId,
      );
    } catch (e) {
      // firstWhere가 요소를 찾지 못한 경우
      return null;
    }
  }

  TodayMedicationStatus get todayMedicationStatus {
    final today = DateTime.now();
    final todayRecords = _medicationRecords.where((record) =>
    record.recordDate.year == today.year &&
        record.recordDate.month == today.month &&
        record.recordDate.day == today.day
    ).toList();

    final taken = todayRecords.where((r) => r.recordType == 'TAKEN').length;
    final missed = todayRecords.where((r) => r.recordType == 'MISSED').length;
    final total = _todayMedications.length;
    final pending = total - taken - missed;

    return TodayMedicationStatus(
      taken: taken > 0 ? taken : 3,
      missed: missed > 0 ? missed : 1,
      pending: pending > 0 ? pending : 2,
      completionRate: total > 0 ? taken / total : 0.6,
    );
  }

  Future<void> loadTodayMedications() async {
    _isLoading = true;
    notifyListeners();

    try {
      // API 호출 시뮬레이션
      await Future.delayed(Duration(milliseconds: 500));

      // 테스트 데이터
      _todayMedications = [
        MedicationDetailModel(
          id: 1,
          cycleId: 1,
          medication: MedicationModel(
            itemSeq: 1,
            itemName: "제프람",
            entpName: "한국제약",
            className: "SSRI",
            dosageForm: "정제",
            isPrescription: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          dosageInterval: "DAILY",
          frequencyPerInterval: 1,
          quantityPerDose: 10.0,
          totalPrescribed: 30,
          remainingQuantity: 20,
          unit: "mg",
          specialInstructions: "식후 복용",
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      print('Error loading today medications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMedicationRecords() async {
    _isLoading = true;
    notifyListeners();

    try {
      // API 호출 시뮬레이션
      await Future.delayed(Duration(milliseconds: 500));
      _medicationRecords = []; // 테스트 데이터로 채울 수 있음
    } catch (e) {
      print('Error loading medication records: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createMedicationRecord({
    required int cycleId,
    required int medicationDetailId,
    required String recordType,
    required DateTime recordDate,
    required double quantityTaken,
    String notes = '',
    String symptoms = '',
  }) async {
    try {
      // API 호출 시뮬레이션
      await Future.delayed(Duration(milliseconds: 300));

      // 로컬 상태 업데이트
      final newRecord = MedicationRecordModel(
        id: DateTime.now().millisecondsSinceEpoch,
        cycleId: cycleId,
        medicationDetail: _todayMedications.firstWhere((m) => m.id == medicationDetailId),
        recordType: recordType,
        recordDate: recordDate,
        quantityTaken: quantityTaken,
        notes: notes,
        symptoms: symptoms,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _medicationRecords.add(newRecord);
      notifyListeners();
    } catch (e) {
      print('Error creating medication record: $e');
    }
  }

  List<MedicationDetailModel> getTodayMedications(DateTime date) {
    // 실제 구현에서는 날짜 기반 필터링
    return _todayMedications;
  }

  MedicationRecordModel? getMedicationRecord(DateTime date, int medicationDetailId) {
    return _medicationRecords.where((record) =>
    record.medicationDetail.id == medicationDetailId &&
        record.recordDate.year == date.year &&
        record.recordDate.month == date.month &&
        record.recordDate.day == date.day
    ).firstOrNull;
  }
}

class AnalyticsDataModel {
  final Map<String, double> medicationAdherence;
  final List<Map<String, dynamic>> prescriptionChanges;
  final Map<String, int> medicationCounts;
  final double overallAdherence;
  final DateTime startDate;
  final DateTime endDate;

  AnalyticsDataModel({
    required this.medicationAdherence,
    required this.prescriptionChanges,
    required this.medicationCounts,
    required this.overallAdherence,
    required this.startDate,
    required this.endDate,
  });

  factory AnalyticsDataModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsDataModel(
      medicationAdherence: Map<String, double>.from(json['medication_adherence'] ?? {}),
      prescriptionChanges: List<Map<String, dynamic>>.from(json['prescription_changes'] ?? []),
      medicationCounts: Map<String, int>.from(json['medication_counts'] ?? {}),
      overallAdherence: json['overall_adherence']?.toDouble() ?? 0.0,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }
}