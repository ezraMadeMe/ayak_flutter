// pubspec.yaml 의존성 추가 필요:
// dependencies:
//   kakao_flutter_sdk: ^1.9.1+2
//   shared_preferences: ^2.2.2
//   flutter_secure_storage: ^9.0.0

// lib/core/storage/storage_manager.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yakunstructuretest/core/storage/storage_keys.dart';

class StorageManager {
  static StorageManager? _instance;
  static StorageManager get instance => _instance ??= StorageManager._();
  StorageManager._();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ========== 사용자 인증 정보 (보안 저장소) ==========

  // 카카오 사용자 ID 저장/조회
  Future<void> setKakaoUserId(String userId) async {
    await _secureStorage.write(key: StorageKeys.kakaoUserId, value: userId);
  }

  Future<String?> getKakaoUserId() async {
    return await _secureStorage.read(key: StorageKeys.kakaoUserId);
  }

  // 사용자 이름 저장/조회
  Future<void> setUserName(String name) async {
    await _secureStorage.write(key: StorageKeys.userName, value: name);
  }

  Future<String?> getUserName() async {
    return await _secureStorage.read(key: StorageKeys.userName);
  }

  // 액세스 토큰 저장/조회 (추후 JWT 토큰용)
  Future<void> setAccessToken(String token) async {
    await _secureStorage.write(key: StorageKeys.accessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: StorageKeys.accessToken);
  }

  // ========== 의료 정보 캐시 (일반 저장소) ==========

  // 현재 활성 병원 ID
  Future<void> setActiveHospitalId(String hospitalId) async {
    await _prefs?.setString(StorageKeys.activeHospitalId, hospitalId);
  }

  Future<String?> getActiveHospitalId() async {
    return _prefs?.getString(StorageKeys.activeHospitalId);
  }

  // 현재 활성 처방전 ID
  Future<void> setActivePrescriptionId(String prescriptionId) async {
    await _prefs?.setString(StorageKeys.activePrescriptionId, prescriptionId);
  }

  Future<String?> getActivePrescriptionId() async {
    return _prefs?.getString(StorageKeys.activePrescriptionId);
  }

  // 복약 그룹 목록 캐시
  Future<void> setMedicationGroups(List<Map<String, dynamic>> groups) async {
    final jsonString = jsonEncode(groups);
    await _prefs?.setString(StorageKeys.medicationGroups, jsonString);
  }

  Future<List<Map<String, dynamic>>> getMedicationGroups() async {
    final jsonString = _prefs?.getString(StorageKeys.medicationGroups);
    if (jsonString == null) return [];

    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.cast<Map<String, dynamic>>();
  }

  // 최근 복용 기록 캐시
  Future<void> setRecentRecords(List<Map<String, dynamic>> records) async {
    final jsonString = jsonEncode(records);
    await _prefs?.setString(StorageKeys.recentRecords, jsonString);
  }

  Future<List<Map<String, dynamic>>> getRecentRecords() async {
    final jsonString = _prefs?.getString(StorageKeys.recentRecords);
    if (jsonString == null) return [];

    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.cast<Map<String, dynamic>>();
  }

  // ========== 사용자 설정 ==========

  // 알림 설정
  Future<void> setNotificationEnabled(bool enabled) async {
    await _prefs?.setBool(StorageKeys.notificationEnabled, enabled);
  }

  Future<bool> getNotificationEnabled() async {
    return _prefs?.getBool(StorageKeys.notificationEnabled) ?? true;
  }

  // 마지막 동기화 시간
  Future<void> setLastSyncTime(DateTime time) async {
    await _prefs?.setString(StorageKeys.lastSyncTime, time.toIso8601String());
  }

  Future<DateTime?> getLastSyncTime() async {
    final timeString = _prefs?.getString(StorageKeys.lastSyncTime);
    if (timeString == null) return null;
    return DateTime.parse(timeString);
  }

  // ========== 유틸리티 메서드 ==========

  // 로그아웃 시 모든 데이터 삭제
  Future<void> clearAllData() async {
    await _secureStorage.deleteAll();
    await _prefs?.clear();
  }

  // 캐시 데이터만 삭제 (로그인 정보는 유지)
  Future<void> clearCache() async {
    final keys = [
      StorageKeys.activeHospitalId,
      StorageKeys.activePrescriptionId,
      StorageKeys.medicationGroups,
      StorageKeys.recentRecords,
      StorageKeys.lastSyncTime,
    ];

    for (String key in keys) {
      await _prefs?.remove(key);
    }
  }

  // 특정 키 존재 여부 확인
  Future<bool> hasKey(String key) async {
    if (_secureStorageKeys.contains(key)) {
      final value = await _secureStorage.read(key: key);
      return value != null;
    } else {
      return _prefs?.containsKey(key) ?? false;
    }
  }

  static const _secureStorageKeys = [
    StorageKeys.kakaoUserId,
    StorageKeys.userName,
    StorageKeys.accessToken,
  ];
}
