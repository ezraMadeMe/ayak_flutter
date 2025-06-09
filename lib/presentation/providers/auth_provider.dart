import 'package:flutter/material.dart';
import 'package:yakunstructuretest/core/api/auth_api_service.dart';
import 'package:yakunstructuretest/core/storage/secure_storage.dart';

// presentation/providers/auth_provider.dart

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  final AuthApiService _authService = AuthApiService();

  AuthState _authState = AuthState.initial;
  UserModel? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthState get authState => _authState;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authState == AuthState.authenticated;

  /// 앱 시작 시 저장된 로그인 정보 확인
  Future<void> checkAuthStatus() async {
    _setLoading(true);

    try {
      final isLoggedIn = await SecureStorage.isLoggedIn();

      if (isLoggedIn) {
        final userId = await SecureStorage.getUserId();
        final userName = await SecureStorage.getUserName();
        final email = await SecureStorage.getEmail();

        if (userId != null && userName != null) {
          // 서버에서 최신 프로필 정보 가져오기
          final response = await _authService.getUserProfile();

          if (response.success && response.data != null) {
            _currentUser = response.data!;
            _setAuthState(AuthState.authenticated);

            // 로컬 스토리지 업데이트
            await _saveUserDataToStorage(_currentUser!, null, null);
          } else {
            // 서버 조회 실패 시 로컬 데이터로 임시 사용자 생성
            _currentUser = UserModel(
              userId: userId,
              userName: userName,
              email: email,
              pushAgree: false,
              notificationEnabled: true,
              marketingAgree: false,
              joinDate: DateTime.now(),
            );
            _setAuthState(AuthState.authenticated);
          }
        } else {
          await _logout();
        }
      } else {
        _setAuthState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('인증 상태 확인 실패: ${e.toString()}');
      _setAuthState(AuthState.unauthenticated);
    } finally {
      _setLoading(false);
    }
  }

  /// 회원가입
  Future<bool> register({
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
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.registerUser(
        userName: userName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        phoneNumber: phoneNumber,
        birthDate: birthDate,
        gender: gender,
        pushAgree: pushAgree,
        notificationEnabled: notificationEnabled,
        marketingAgree: marketingAgree,
      );

      if (response.success && response.data != null) {
        final authResponse = response.data!;
        _currentUser = authResponse.user;

        // 로컬 스토리지에 저장
        await _saveUserDataToStorage(
          authResponse.user,
          authResponse.accessToken,
          authResponse.refreshToken,
        );

        _setAuthState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('회원가입 실패: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 일반 로그인
  Future<bool> login({
    required String userId,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.loginUser(
        userId: userId,
        password: password,
      );

      if (response.success && response.data != null) {
        final authResponse = response.data!;
        _currentUser = authResponse.user;

        // 로컬 스토리지에 저장
        await _saveUserDataToStorage(
          authResponse.user,
          authResponse.accessToken,
          authResponse.refreshToken,
        );

        _setAuthState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('로그인 실패: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 소셜 로그인
  Future<bool> socialLogin({
    required String socialProvider,
    required String userId,
    required String socialId,
    String? socialToken,
    String? userName,
    String? email,
    String? profileImageUrl,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      print("REUEST : $socialProvider $socialId $socialToken $userName $email $profileImageUrl $userId");
      final response = await _authService.socialLogin(
        socialProvider: socialProvider,
        socialId: socialId,
        socialToken: socialToken,
        userName: userName,
        email: email,
        profileImageUrl: profileImageUrl,
        userId: userId,
      );

      print("RESPONSE : ${response.data}");

      if (response.success && response.data != null) {
        final authResponse = response.data!;
        _currentUser = authResponse.user;

        // 로컬 스토리지에 저장
        await _saveUserDataToStorage(
          authResponse.user,
          authResponse.accessToken,
          authResponse.refreshToken,
        );

        _setAuthState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('소셜 로그인 실패: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 프로필 업데이트
  Future<bool> updateProfile({
    String? userName,
    String? email,
    String? phoneNumber,
    DateTime? birthDate,
    String? gender,
    bool? pushAgree,
    bool? notificationEnabled,
    bool? marketingAgree,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.updateUserProfile(
        userName: userName,
        email: email,
        phoneNumber: phoneNumber,
        birthDate: birthDate,
        gender: gender,
        pushAgree: pushAgree,
        notificationEnabled: notificationEnabled,
        marketingAgree: marketingAgree,
      );

      if (response.success && response.data != null) {
        _currentUser = response.data!;

        // 로컬 스토리지 업데이트
        await SecureStorage.saveUserBasicInfo(
          userId: _currentUser!.userId,
          userName: _currentUser!.userName,
          email: _currentUser!.email,
        );
        await SecureStorage.saveUserProfile(_currentUser!.toJson());

        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('프로필 업데이트 실패: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    _setLoading(true);

    try {
      final refreshToken = await SecureStorage.getRefreshToken();

      // 서버에 로그아웃 요청
      await _authService.logoutUser(refreshToken);

    } catch (e) {
      // 서버 로그아웃 실패해도 로컬 데이터는 삭제
      print('서버 로그아웃 실패: ${e.toString()}');
    }

    await _logout();
  }

  /// 계정 비활성화
  Future<bool> deactivateAccount({
    String? password,
    String? reason,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.deactivateUser(
        password: password,
        reason: reason,
      );

      if (response.success) {
        await _logout();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('계정 비활성화 실패: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Private 메소드들
  Future<void> _saveUserDataToStorage(
      UserModel user,
      String? accessToken,
      String? refreshToken,
      ) async {
    await Future.wait([
      SecureStorage.saveUserBasicInfo(
        userId: user.userId,
        userName: user.userName,
        email: user.email,
      ),
      SecureStorage.saveUserProfile(user.toJson()),
      if (accessToken != null && refreshToken != null)
        SecureStorage.saveAuthTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        ),
    ]);
  }

  Future<void> _logout() async {
    await SecureStorage.clearUserData();
    _currentUser = null;
    _setAuthState(AuthState.unauthenticated);
    _setLoading(false);
  }

  void _setAuthState(AuthState state) {
    _authState = state;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _authState = AuthState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}