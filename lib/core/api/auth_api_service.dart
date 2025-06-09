// core/api/auth_api_service.dart
import 'package:yakunstructuretest/core/api/api_service.dart';
import 'package:yakunstructuretest/core/storage/secure_storage.dart';

class AuthApiService extends ApiService {
  static final AuthApiService _instance = AuthApiService._internal();
  factory AuthApiService() => _instance;
  AuthApiService._internal() : super();

  /// 회원가입
  Future<ApiResponse<AuthResponse>> registerUser({
    required String userName,
    String? email,
    String? password,
    String? confirmPassword,
    String? phoneNumber,
    DateTime? birthDate,
    String? gender,
    bool pushAgree = false,
    bool notificationEnabled = true,
    bool marketingAgree = false,
  }) async {
    final data = {
      'user_name': userName,
      'email': email,
      'password': confirmPassword,
      'phone_number': phoneNumber,
      'birth_date': birthDate,
      'gender': gender,
      'push_agree': pushAgree,
      'notification_enabled': notificationEnabled,
      'marketing_agree': marketingAgree
    };

    return makeRequest<AuthResponse>(
      method: 'POST',
      endpoint: '/auth/register/',
      data: data,
      fromJson: (json) => AuthResponse.fromJson(json),
    );
  }

  /// 일반 로그인
  Future<ApiResponse<AuthResponse>> loginUser({
    required String userId,
    required String password,
  }) async {
    final data = {
      'user_id': userId,
      'password': password,
    };

    return makeRequest<AuthResponse>(
      method: 'POST',
      endpoint: 'user/auth/login/',
      data: data,
      fromJson: (json) => AuthResponse.fromJson(json),
      requiresAuth: false,
    );
  }

  /// 소셜 로그인
  Future<ApiResponse<AuthResponse>> socialLogin({
    required String socialProvider,
    required String userId,
    required String socialId,
    String? socialToken,
    String? userName,
    String? email,
    String? profileImageUrl,
  }) async {
    final data = {
      'user_id': userId,
      'password': socialToken,
      'social_provider': socialProvider,
      'social_id': socialId,
      'social_token': socialToken,
      'user_name': userName,
      'email': email,
      'profile_image_url': profileImageUrl,
    };

    print("DATA : $data");

    return makeRequest<AuthResponse>(
      method: 'POST',
      endpoint: '/user/auth/login/',
      data: data,
      fromJson: (json) => AuthResponse.fromJson(json),
      requiresAuth: false,
    );
  }

  /// 사용자 프로필 조회
  Future<ApiResponse<UserModel>> getUserProfile() async {
    return makeRequest<UserModel>(
      method: 'GET',
      endpoint: '/user/auth/profile/',
      fromJson: (json) => UserModel.fromJson(json),
    );
  }

  /// 사용자 프로필 업데이트
  Future<ApiResponse<UserModel>> updateUserProfile({
    String? userName,
    String? email,
    String? phoneNumber,
    DateTime? birthDate,
    String? gender,
    bool? pushAgree,
    bool? notificationEnabled,
    bool? marketingAgree,
  }) async {
    final data = <String, dynamic>{};

    if (userName != null) data['user_name'] = userName;
    if (email != null) data['email'] = email;
    if (phoneNumber != null) data['phone_number'] = phoneNumber;
    if (birthDate != null) data['birth_date'] = birthDate.toIso8601String().split('T')[0];
    if (gender != null) data['gender'] = gender;
    if (pushAgree != null) data['push_agree'] = pushAgree;
    if (notificationEnabled != null) data['notification_enabled'] = notificationEnabled;
    if (marketingAgree != null) data['marketing_agree'] = marketingAgree;

    return makeRequest<UserModel>(
      method: 'PUT',
      endpoint: '/user/auth/profile/update',
      data: data,
      fromJson: (json) => UserModel.fromJson(json),
    );
  }

  /// 로그아웃
  Future<ApiResponse<void>> logoutUser(String? refreshToken) async {
    final data = {
      if (refreshToken != null) 'refresh_token': refreshToken,
    };

    return makeRequest<void>(
      method: 'POST',
      endpoint: '/user/auth/logout',
      data: data,
      fromJson: (_) => null,
    );
  }

  /// 계정 비활성화
  Future<ApiResponse<void>> deactivateUser({
    String? password,
    String? reason,
  }) async {
    final data = {
      if (password != null) 'password': password,
      if (reason != null) 'reason': reason,
    };

    return makeRequest<void>(
      method: 'DELETE',
      endpoint: '/user/auth/deactivate',
      data: data,
      fromJson: (_) => null,
    );
  }

  /// 사용자 존재 확인
  Future<ApiResponse<Map<String, bool>>> checkUserExists({
    String? email,
    String? socialProvider,
    String? socialId,
  }) async {
    final data = {
      if (email != null) 'email': email,
      if (socialProvider != null) 'social_provider': socialProvider,
      if (socialId != null) 'social_id': socialId,
    };

    return makeRequest<Map<String, bool>>(
      method: 'POST',
      endpoint: '/user/auth/check-exists',
      data: data,
      fromJson: (json) => Map<String, bool>.from(json),
    );
  }
}
