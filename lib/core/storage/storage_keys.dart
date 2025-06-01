
// lib/core/storage/storage_keys.dart
class StorageKeys {
  // 인증 정보 (보안 저장소)
  static const String kakaoUserId = 'kakao_user_id';
  static const String userName = 'user_name';
  static const String accessToken = 'access_token';

  // 의료 정보 (일반 저장소)
  static const String activeHospitalId = 'active_hospital_id';
  static const String activePrescriptionId = 'active_prescription_id';
  static const String medicationGroups = 'medication_groups';
  static const String recentRecords = 'recent_records';

  // 사용자 설정
  static const String notificationEnabled = 'notification_enabled';
  static const String lastSyncTime = 'last_sync_time';

  // 추가 확장용 키들
  static const String userPreferences = 'user_preferences';
  static const String medicationAlarms = 'medication_alarms';
  static const String emergencyContacts = 'emergency_contacts';
  static const String medicalHistory = 'medical_history';
}