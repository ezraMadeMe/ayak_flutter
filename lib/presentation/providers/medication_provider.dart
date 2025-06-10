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

enum ScheduleType {
  prescription,     // 처방전 갱신
  hospital,        // 병원 내원
  medication,      // 약물 관련
  stock,          // 재고 부족
  record,         // 기록/패턴
  goal           // 목표 달성
}

class HomeProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get urgentNotifications => [];
   List<dynamic> get upcomingSchedules => [
     ScheduleItem(
         id: 'prescription_001',
         type: ScheduleType.prescription,
         title: '다가오는 처방 종료일',
         subtitle: '다음 진료 예약 필요',
         scheduledDate: DateTime.parse("2025-06-03"),
         progress: 0.5,
         additionalData: {
           'prescriptionInfo': {
             'hospitalName': '병원명',
             'doctorName': '의사명',
             'prescriptionId': '처방전ID',
             'prescriptionDate': '2024-03-20', // ISO 8601 형식
             'status': 'ACTIVE' // 'ACTIVE', 'NEEDS_RENEWAL', 'EXPIRED' 중 하나
           }
         }
     ),
     // 1. 처방전 갱신 (가장 중요 - 의료 연속성)
     ScheduleItem(
         id: 'prescription_renewal_001',
         type: ScheduleType.prescription,
         title: '처방전 갱신 필요',
         subtitle: '서울대병원 내분비내과 - 김의사',
         scheduledDate: DateTime.parse("2025-06-15"),
         progress: 0.8, // 처방 기간 중 80% 경과
         additionalData: {
           'prescriptionInfo': {
             'hospitalName': '서울대학교병원',
             'doctorName': '김의사',
             'department': '내분비내과',
             'prescriptionId': 'PR123456789012',
             'prescriptionDate': '2025-05-15',
             'status': 'NEEDS_RENEWAL',
             'medicationCount': 3,
             'illnessName': '고혈압, 당뇨병'
           }
         }
     ),

     // 2. 약물 재고 부족 (복약 연속성 보장)
     ScheduleItem(
         id: 'medication_stock_001',
         type: ScheduleType.stock,
         title: '아모잘탄정 재고 부족',
         subtitle: '5일분 남음 - 처방전 갱신 필요',
         scheduledDate: DateTime.parse("2025-06-15"), // 재고 소진 예정일
         progress: 0.9, // 재고 10% 남음
         additionalData: {
           'medicationInfo': {
             'medicationName': '아모잘탄정 5/50mg',
             'manufacturer': '한독',
             'remainingQuantity': 5,
             'dailyDosage': 1,
             'groupName': '아침약',
             'urgencyLevel': 'HIGH'
           }
         }
     ),

     // 3. 병원 내원 일정
     ScheduleItem(
         id: 'hospital_appointment_001',
         type: ScheduleType.hospital,
         title: '연세병원 내원 예정',
         subtitle: '소화기내과 - 박의사 (위염 진료)',
         scheduledDate: DateTime.parse("2025-06-20"),
         progress: null,
         additionalData: {
           'appointmentInfo': {
             'hospitalName': '연세세브란스병원',
             'doctorName': '박의사',
             'department': '소화기내과',
             'appointmentTime': '14:30',
             'illnessName': '위염',
             'address': '서울 서대문구 연세로 50-1',
             'phone': '02-2228-5800',
             'visitType': 'FOLLOW_UP' // 'INITIAL', 'FOLLOW_UP', 'EMERGENCY'
           }
         }
     ),

     // 4. 복약 패턴 개선 목표
     ScheduleItem(
         id: 'medication_goal_001',
         type: ScheduleType.goal,
         title: '주간 복약률 90% 목표',
         subtitle: '현재 85% - 5% 부족',
         scheduledDate: DateTime.parse("2025-06-16"), // 주간 마감일
         progress: 0.85, // 현재 달성률
         additionalData: {
           'goalInfo': {
             'targetRate': 90,
             'currentRate': 85,
             'remainingDays': 6,
             'missedMedications': 2,
             'totalMedications': 42, // 이번 주 총 복용해야 할 약물 수
             'improvementSuggestion': '점심약 알림 시간을 30분 앞당겨 보세요'
           }
         }
     ),

     // 5. 복용 기록 누락 알림
     ScheduleItem(
         id: 'medication_record_001',
         type: ScheduleType.record,
         title: '어제 저녁약 복용 기록 없음',
         subtitle: '메트포민정 2정 - 기록 확인 필요',
         scheduledDate: DateTime.parse("2025-06-10"), // 어제 날짜
         progress: 0.8, // 어제 전체 복용률
         additionalData: {
           'recordInfo': {
             'medicationName': '메트포민정 500mg',
             'missedTime': '19:00',
             'quantity': 2,
             'groupName': '저녁약',
             'recordType': 'MISSING', // 'MISSING', 'LATE', 'SIDE_EFFECT'
             'actionRequired': 'CONFIRM_OR_RECORD'
           }
         }
     ),

     // 6. 다음 처방전 만료 예정 (장기 계획)
     ScheduleItem(
         id: 'prescription_expiry_002',
         type: ScheduleType.prescription,
         title: '위염약 처방 만료 예정',
         subtitle: '연세병원 - 2주 처방분',
         scheduledDate: DateTime.parse("2025-06-25"),
         progress: 0.6, // 처방 기간 중 60% 경과
         additionalData: {
           'prescriptionInfo': {
             'hospitalName': '연세세브란스병원',
             'doctorName': '박의사',
             'prescriptionId': 'PR123456789014',
             'prescriptionDate': '2025-06-01',
             'status': 'ACTIVE',
             'medicationCount': 2,
             'illnessName': '위염',
             'isShortTerm': true // 단기 처방 여부
           }
         }
     ),

     // 7. 복약 습관 개선 제안
     ScheduleItem(
         id: 'habit_improvement_001',
         type: ScheduleType.goal,
         title: '점심약 복용률 개선 필요',
         subtitle: '최근 7일 평균 70% - 개선 방법 제안',
         scheduledDate: DateTime.parse("2025-06-17"), // 1주일 후 재평가
         progress: 0.7, // 현재 점심약 복용률
         additionalData: {
           'improvementInfo': {
             'timeSlot': 'LUNCH',
             'currentRate': 70,
             'targetRate': 90,
             'frequentlyMissed': ['소화제', '유산균정'],
             'suggestions': [
               '점심 알림을 30분 일찍 설정',
               '휴대용 약통 사용',
               '점심시간 고정화'
             ],
             'analysisDate': '2025-06-10'
           }
         }
     )
  //   ScheduleItem(id: 'hospital_001', type: ScheduleType.hospital, title: '서울대학교병원 내원', subtitle: '정신건강의학과 - 김민수 교수', scheduledDate: DateTime.parse("2025-05-20"),progress: 0.3),
  //   ScheduleItem(id: 'hospital_001', type: ScheduleType.medication, title: '정신과 약물 복약 그룹', subtitle: '9월 16일자 처방', scheduledDate: DateTime.parse("2025-09-16"), progress: 0.7),
   ];

  Future<void> loadHomeData() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await Future.delayed(Duration(milliseconds: 500));
      // 여기에 실제 데이터 로딩 로직 추가

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshHomeData() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await Future.delayed(Duration(milliseconds: 300));
      // 여기에 실제 데이터 새로고침 로직 추가

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
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
          actualDosagePattern: Map(),
          patientAdjustments: Map(),
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