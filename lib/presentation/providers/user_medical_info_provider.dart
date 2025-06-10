import 'package:flutter/material.dart';

class UserMedicalInfoProvider with ChangeNotifier {
  // 선택된 데이터 상태 관리
  Map<String, dynamic>? _selectedHospital;
  Map<String, dynamic>? _selectedIllness;
  Map<String, dynamic>? _selectedPrescription;
  DateTime? _prescriptionDate;
  bool _isCreatingNew = false;
  String _searchQuery = '';

  // Getters
  Map<String, dynamic>? get selectedHospital => _selectedHospital;
  Map<String, dynamic>? get selectedIllness => _selectedIllness;
  Map<String, dynamic>? get selectedPrescription => _selectedPrescription;
  DateTime? get prescriptionDate => _prescriptionDate;
  bool get isCreatingNew => _isCreatingNew;
  String get searchQuery => _searchQuery;

  // 병원 데이터
  final List<Map<String, dynamic>> hospitals = [
    {
      'hospital_id': 'HOSP_001',
      'hosp_name': '서울대학교병원',
      'hosp_type': '종합병원',
      'address': '서울특별시 종로구 대학로 101',
      'phone_number': '02-2072-2114',
      'doctor_name': '김의사',
      'departments': ['내과', '외과', '정형외과', '신경과'],
    },
    {
      'hospital_id': 'HOSP_002',
      'hosp_name': '연세세브란스병원',
      'hosp_type': '종합병원',
      'address': '서울특별시 서대문구 연세로 50-1',
      'phone_number': '02-2228-5800',
      'doctor_name': '박의사',
      'departments': ['내과', '외과', '정형외과', '신경과'],
    },
  ];

  // 질병 데이터
  final List<Map<String, dynamic>> illnesses = [
    {
      'illness_id': 'ILL_001',
      'ill_name': '고혈압',
      'ill_code': 'I10',
      'ill_type': 'DISEASE',
      'is_chronic': true,
      'description': '혈압이 정상보다 높은 상태가 지속되는 만성질환',
      'common_medications': ['아모잘탄', '노바스크', '디오반'],
    },
    {
      'illness_id': 'ILL_002',
      'ill_name': '당뇨병',
      'ill_code': 'E11',
      'ill_type': 'DISEASE',
      'is_chronic': true,
      'description': '혈당이 높은 상태가 지속되는 대사성 질환',
      'common_medications': ['메트포민', '글리메피리드', '아마릴'],
    },
    {
      'illness_id': 'ILL_003',
      'ill_name': '위염',
      'ill_code': 'K29.7',
      'ill_type': 'DISEASE',
      'is_chronic': false,
      'description': '위 점막의 염증성 질환',
      'common_medications': ['란소프라졸', '판토프라졸', '에소메프라졸'],
    },
  ];

  // 처방전 템플릿 데이터
  final List<Map<String, dynamic>> prescriptionTemplates = [
    {
      'template_id': 'PRES_001',
      'template_name': '고혈압 기본 처방',
      'illness_id': 'ILL_001',
      'duration_weeks': 4,
      'medications': [
        {
          'med_name': '아모잘탄',
          'dosage': '1정',
          'frequency': '1일 1회',
          'timing': '아침 식후',
        },
      ],
    },
    {
      'template_id': 'PRES_002',
      'template_name': '당뇨병 기본 처방',
      'illness_id': 'ILL_002',
      'duration_weeks': 4,
      'medications': [
        {
          'med_name': '메트포민',
          'dosage': '1정',
          'frequency': '1일 2회',
          'timing': '아침, 저녁 식후',
        },
      ],
    },
  ];

  // Actions
  void selectHospital(Map<String, dynamic> hospital) {
    _selectedHospital = hospital;
    notifyListeners();
  }

  void selectIllness(Map<String, dynamic> illness) {
    _selectedIllness = illness;
    notifyListeners();
  }

  void selectPrescription(Map<String, dynamic> prescription) {
    _selectedPrescription = prescription;
    notifyListeners();
  }

  void setPrescriptionDate(DateTime date) {
    _prescriptionDate = date;
    notifyListeners();
  }

  void setCreatingNew(bool value) {
    _isCreatingNew = value;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void resetSelections() {
    _selectedHospital = null;
    _selectedIllness = null;
    _selectedPrescription = null;
    _prescriptionDate = null;
    _isCreatingNew = false;
    _searchQuery = '';
    notifyListeners();
  }

  // 검색 기능
  List<Map<String, dynamic>> searchHospitals(String query) {
    if (query.isEmpty) return hospitals;
    return hospitals.where((hospital) =>
        hospital['hosp_name'].toLowerCase().contains(query.toLowerCase()) ||
        hospital['doctor_name'].toLowerCase().contains(query.toLowerCase())).toList();
  }

  List<Map<String, dynamic>> searchIllnesses(String query) {
    if (query.isEmpty) return illnesses;
    return illnesses.where((illness) =>
        illness['ill_name'].toLowerCase().contains(query.toLowerCase()) ||
        illness['ill_code'].toLowerCase().contains(query.toLowerCase())).toList();
  }

  // 처방전 템플릿 필터링
  List<Map<String, dynamic>> getPrescriptionTemplatesForIllness(String illnessId) {
    return prescriptionTemplates.where((template) => 
        template['illness_id'] == illnessId).toList();
  }

  // 의료정보 저장
  Future<bool> saveMedicalInfo() async {
    if (_selectedHospital == null || _selectedIllness == null || 
        _selectedPrescription == null || _prescriptionDate == null) {
      return false;
    }

    try {
      // TODO: API 호출로 데이터 저장
      // 임시로 성공 반환
      return true;
    } catch (e) {
      print('Error saving medical info: $e');
      return false;
    }
  }
} 