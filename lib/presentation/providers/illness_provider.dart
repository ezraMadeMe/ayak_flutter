// providers/illness_provider.dart
import 'package:flutter/material.dart';
import 'package:yakunstructuretest/data/models/illness_model.dart';
import 'package:yakunstructuretest/services/illness_service.dart';

enum IllnessInputType {
  disease,    // 질병 (API 검색 또는 직접 입력)
  symptom,    // 증상 (직접 입력만)
}

class IllnessProvider extends ChangeNotifier {
  List<Illness> _searchResults = [];
  List<Illness> _myIllnesses = [];
  Illness? _selectedIllness;
  IllnessInputType _inputType = IllnessInputType.disease;
  bool _isLoading = false;
  bool _isManualInput = false;
  String? _error;

  List<Illness> get searchResults => _searchResults;
  List<Illness> get myIllnesses => _myIllnesses;
  Illness? get selectedIllness => _selectedIllness;
  IllnessInputType get inputType => _inputType;
  bool get isLoading => _isLoading;
  bool get isManualInput => _isManualInput;
  String? get error => _error;

  bool get isSymptomMode => _inputType == IllnessInputType.symptom;
  bool get isDiseaseMode => _inputType == IllnessInputType.disease;

  void setInputType(IllnessInputType type) {
    _inputType = type;
    _searchResults = [];
    _selectedIllness = null;
    _isManualInput = type == IllnessInputType.symptom; // 증상 모드는 항상 직접 입력
    notifyListeners();
  }

  void setManualInput(bool value) {
    _isManualInput = value;
    if (value) {
      _selectedIllness = null;
    }
    notifyListeners();
  }

  void selectIllness(Illness? illness) {
    _selectedIllness = illness;
    _isManualInput = false;
    notifyListeners();
  }

  Future<void> searchDiseases(String keyword) async {
    if (keyword.trim().isEmpty || isSymptomMode) return;

    _isLoading = true;
    _error = null;
    _searchResults = [];
    _selectedIllness = null;
    _isManualInput = false;
    notifyListeners();

    try {
      _searchResults = await IllnessService.searchDiseases(keyword);
    } catch (e) {
      _error = e.toString();
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerIllness({
    required String userId,
    required String illnessName,
    required DateTime startDate,
    DateTime? endDate,
    bool isChronic = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Illness illnessToRegister;

      if (isSymptomMode || _isManualInput) {
        // 증상 모드이거나 직접 입력인 경우
        illnessToRegister = Illness(
          userId: userId,
          illType: isSymptomMode ? 'SYMPTOM' : 'DISEASE',
          illName: illnessName,
          illStart: startDate,
          illEnd: endDate,
          isChronic: isChronic,
        );
      } else if (_selectedIllness != null) {
        // API에서 선택한 질병인 경우
        illnessToRegister = Illness(
          userId: userId,
          illType: 'DISEASE',
          illName: _selectedIllness!.illName,
          illCode: _selectedIllness!.illCode,
          illStart: startDate,
          illEnd: endDate,
          isChronic: isChronic,
        );
      } else {
        throw Exception('등록할 질병/증상 정보가 없습니다');
      }

      await IllnessService.registerIllness(illnessToRegister);
      await loadMyIllnesses(userId); // 등록 후 목록 새로고침
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyIllnesses(String userId) async {
    try {
      _myIllnesses = await IllnessService.getMyIllnesses(userId);
      notifyListeners();
    } catch (e) {
      print('내 질병/증상 목록 로드 실패: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _searchResults = [];
    _selectedIllness = null;
    _isManualInput = false;
    _inputType = IllnessInputType.disease;
    _error = null;
    notifyListeners();
  }
}
