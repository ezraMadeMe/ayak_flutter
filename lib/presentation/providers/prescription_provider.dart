// providers/prescription_provider.dart
import 'package:flutter/material.dart';
import 'package:yakunstructuretest/data/models/prescription_renewal_model.dart';
import 'package:yakunstructuretest/services/prescription_service.dart';

class PrescriptionProvider extends ChangeNotifier {
  CycleExpirationInfo? _expirationInfo;
  bool _isLoading = false;
  String? _error;

  CycleExpirationInfo? get expirationInfo => _expirationInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasExpiredCycles => _expirationInfo?.expired.isNotEmpty ?? false;
  bool get hasExpiringSoon => _expirationInfo?.expiringSoon.isNotEmpty ?? false;

  Future<void> checkExpirations(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expirationInfo = await PrescriptionService.checkCycleExpiration(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> renewPrescription(PrescriptionRenewalRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await PrescriptionService.renewPrescription(request);

      if (result['success'] == true) {
        // 갱신 성공 후 만료 정보 다시 확인
        await checkExpirations(request.userId);
        return true;
      } else {
        _error = result['message'] ?? '처방전 갱신에 실패했습니다.';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
