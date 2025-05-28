import 'package:flutter/material.dart';

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

class AnalyticsProvider with ChangeNotifier {
  AnalyticsDataModel? _analyticsData;
  bool _isLoading = false;
  String? _error;

  AnalyticsDataModel? get analyticsData => _analyticsData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAnalyticsData({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? groupId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // API 호출 시뮬레이션
      await Future.delayed(Duration(milliseconds: 800));

      // 테스트 데이터
      _analyticsData = AnalyticsDataModel(
        medicationAdherence: {
          '제프람': 0.85,
          '알프람': 0.92,
          '부스피론': 0.78,
        },
        prescriptionChanges: [
          {
            'medication': '제프람',
            'change_type': 'increased',
            'date': '2024-06-01',
            'previous_dose': '10mg',
            'new_dose': '20mg',
          },
          {
            'medication': '알프람',
            'change_type': 'decreased',
            'date': '2024-07-01',
            'previous_dose': '0.5mg',
            'new_dose': '0.25mg',
          },
        ],
        medicationCounts: {
          'active': 3,
          'discontinued': 1,
          'new': 2,
        },
        overallAdherence: 0.85,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = 'Failed to load analytics data: $e';
      print('Error loading analytics data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAnalyticsData({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? groupId,
  }) async {
    await loadAnalyticsData(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      groupId: groupId,
    );
  }

  List<Map<String, dynamic>> getPrescriptionChanges() {
    return _analyticsData?.prescriptionChanges ?? [];
  }

  Map<String, double> getMedicationAdherence() {
    return _analyticsData?.medicationAdherence ?? {};
  }

  double getOverallAdherence() {
    return _analyticsData?.overallAdherence ?? 0.0;
  }

  Map<String, int> getMedicationCounts() {
    return _analyticsData?.medicationCounts ?? {};
  }
}
