import 'package:flutter/material.dart';
import 'package:yakunstructuretest/data/models/medication_detail_model.dart';
import 'package:yakunstructuretest/data/models/medication_model.dart';
import 'package:yakunstructuretest/data/models/medication_record_model.dart';

class HomeProvider with ChangeNotifier {
  List<dynamic> get urgentNotifications => [];
  List<dynamic> get upcomingSchedules => [
    {'title': '서울대학교병원 내원', 'date': 'D-8'},
    {'title': '처방전 갱신', 'date': 'D-15'},
  ];

  Future<void> loadHomeData() async {
    await Future.delayed(Duration(milliseconds: 500));
  }

  Future<void> refreshHomeData() async {
    await Future.delayed(Duration(milliseconds: 300));
  }
}

class MedicationProvider with ChangeNotifier {
  List<MedicationDetailModel> _todayMedications = [];
  List<MedicationRecordModel> _medicationRecords = [];
  bool _isLoading = false;

  List<MedicationDetailModel> get todayMedications => _todayMedications;
  List<MedicationRecordModel> get medicationRecords => _medicationRecords;
  bool get isLoading => _isLoading;

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
      taken: taken > 0 ? taken : 3, // 테스트 데이터
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