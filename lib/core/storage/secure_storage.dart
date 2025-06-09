// core/storage/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  // 키 상수
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _emailKey = 'email';
  static const String _userProfileKey = 'user_profile';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _lastLoginKey = 'last_login';

  // 토큰 관리
  static Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<void> clearAuthTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }

  // 사용자 기본 정보 관리
  static Future<void> saveUserBasicInfo({
    required String userId,
    required String userName,
    String? email,
  }) async {
    await Future.wait([
      _storage.write(key: _userIdKey, value: userId),
      _storage.write(key: _userNameKey, value: userName),
      if (email != null) _storage.write(key: _emailKey, value: email),
      _storage.write(key: _isLoggedInKey, value: 'true'),
      _storage.write(key: _lastLoginKey, value: DateTime.now().toIso8601String()),
    ]);
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  static Future<String?> getUserName() async {
    return await _storage.read(key: _userNameKey);
  }

  static Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }

  // 사용자 프로필 관리
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await _storage.write(key: _userProfileKey, value: json.encode(profile));
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    final profileJson = await _storage.read(key: _userProfileKey);
    if (profileJson != null) {
      return json.decode(profileJson);
    }
    return null;
  }

  // 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }

  // 마지막 로그인 시간 조회
  static Future<DateTime?> getLastLoginTime() async {
    final lastLogin = await _storage.read(key: _lastLoginKey);
    if (lastLogin != null) {
      return DateTime.parse(lastLogin);
    }
    return null;
  }

  // 모든 데이터 삭제
  static Future<void> clearUserData() async {
    await _storage.deleteAll();
  }
}

// data/models/user_model.dart
class UserModel {
  final String userId;
  final String userName;
  final String? email;
  final String? profileImageUrl;
  final String? phoneNumber;
  final DateTime? birthDate;
  final String? gender;
  final bool? pushAgree;
  final bool? notificationEnabled;
  final bool? marketingAgree;
  final DateTime joinDate;
  final DateTime? lastLoginDate;
  final String? socialProvider;

  UserModel({
    required this.userId,
    required this.userName,
    this.email,
    this.profileImageUrl,
    this.phoneNumber,
    this.birthDate,
    this.gender,
    this.pushAgree,
    this.notificationEnabled,
    this.marketingAgree,
    required this.joinDate,
    this.lastLoginDate,
    this.socialProvider,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print("FACTORY JSON : $json");
    return UserModel(
      userId: json['user_id'],
      userName: json['user_name'],
      email: json['email'],
      profileImageUrl: json['profile_image_url'],
      phoneNumber: json['phone_number'],
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date']) : null,
      gender: json['gender'],
      pushAgree: json['push_agree'] ?? false,
      notificationEnabled: json['notification_enabled'] ?? true,
      marketingAgree: json['marketing_agree'] ?? false,
      joinDate: DateTime.parse(json['join_date']),
      lastLoginDate: json['last_login_date'] != null ? DateTime.parse(json['last_login_date']) : null,
      socialProvider: json['social_provider'],
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'user_name': userName,
    'email': email,
    'profile_image_url': profileImageUrl,
    'phone_number': phoneNumber,
    'birth_date': birthDate?.toIso8601String(),
    'gender': gender,
    'push_agree': pushAgree,
    'notification_enabled': notificationEnabled,
    'marketing_agree': marketingAgree,
    'join_date': joinDate.toIso8601String(),
    'last_login_date': lastLoginDate?.toIso8601String(),
    'social_provider': socialProvider,
  };

  // 로컬 저장용 기본 정보만 추출
  Map<String, dynamic> toBasicInfo() => {
    'user_id': userId,
    'user_name': userName,
    'email': email,
  };
}

class AuthResponse {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    print("FROM JSON : $json");
    return AuthResponse(
      user: UserModel.fromJson(json['user']),
      accessToken: json['tokens']['access'],
      refreshToken: json['tokens']['refresh'],
    );
  }
}
