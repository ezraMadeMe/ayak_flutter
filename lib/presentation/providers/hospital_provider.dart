
// providers/hospital_provider.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:yakunstructuretest/data/models/hospital_model.dart';
import 'package:yakunstructuretest/services/hospital_service.dart';


class HospitalProvider extends ChangeNotifier {
  List<Hospital> _searchResults = [];
  List<Hospital> _myHospitals = [];
  Hospital? _selectedHospital;
  bool _isLoading = false;
  bool _isManualInput = false;
  String? _error;

  List<Hospital> get searchResults => _searchResults;
  List<Hospital> get myHospitals => _myHospitals;
  Hospital? get selectedHospital => _selectedHospital;
  bool get isLoading => _isLoading;
  bool get isManualInput => _isManualInput;
  String? get error => _error;

  void setManualInput(bool value) {
    _isManualInput = value;
    if (value) {
      _selectedHospital = null;
    }
    notifyListeners();
  }

  void selectHospital(Hospital? hospital) {
    _selectedHospital = hospital;
    _isManualInput = false;
    notifyListeners();
  }

  Future<void> searchHospitals(String keyword) async {
    if (keyword.trim().isEmpty) return;

    _isLoading = true;
    _error = null;
    _searchResults = [];
    _selectedHospital = null;
    _isManualInput = false;
    notifyListeners();

    try {
      _searchResults = await HospitalService.searchHospitals(keyword);
    } catch (e) {
      _error = e.toString();
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerHospital(String userId, String hospName, String doctorName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Hospital hospitalToRegister;

      if (_isManualInput) {
        hospitalToRegister = Hospital(
          userId: userId,
          hospName: hospName,
          doctorName: doctorName,
          hospType: '기타',
        );
      } else if (_selectedHospital != null) {
        hospitalToRegister = Hospital(
          userId: userId,
          hospCode: _selectedHospital!.hospCode,
          hospName: _selectedHospital!.hospName,
          hospType: _selectedHospital!.hospType,
          doctorName: doctorName,
          address: _selectedHospital!.address,
          phoneNumber: _selectedHospital!.phoneNumber,
        );
      } else {
        throw Exception('등록할 병원 정보가 없습니다');
      }

      await HospitalService.registerHospital(hospitalToRegister);
      await loadMyHospitals(userId); // 등록 후 목록 새로고침
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyHospitals(String userId) async {
    try {
      _myHospitals = await HospitalService.getMyHospitals(userId);
      notifyListeners();
    } catch (e) {
      print('내 병원 목록 로드 실패: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _searchResults = [];
    _selectedHospital = null;
    _isManualInput = false;
    _error = null;
    notifyListeners();
  }
}