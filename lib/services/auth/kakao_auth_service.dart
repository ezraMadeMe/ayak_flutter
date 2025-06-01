
// lib/services/auth/kakao_auth_service.dart
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:yakunstructuretest/core/storage/storage_manager.dart';
import 'package:yakunstructuretest/data/models/auth_model.dart';

class KakaoAuthService {
  static final StorageManager _storage = StorageManager.instance;

  // 카카오 로그인
  static Future<AuthResult> signInWithKakao() async {
    try {
      OAuthToken token;

      // 카카오톡 앱이 설치되어 있는지 확인
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      // 사용자 정보 가져오기
      User user = await UserApi.instance.me();

      // 스토리지에 저장
      await _storage.setKakaoUserId(user.id.toString());
      await _storage.setUserName(user.kakaoAccount?.profile?.nickname ?? '사용자');

      return AuthResult.success(
        userId: user.id.toString(),
        userName: user.kakaoAccount?.profile?.nickname ?? '사용자',
        profileImage: user.kakaoAccount?.profile?.profileImageUrl,
      );

    } catch (error) {
      print('카카오 로그인 실패: $error');
      return AuthResult.failure(error.toString());
    }
  }

  // 로그아웃
  static Future<void> signOut() async {
    try {
      await UserApi.instance.unlink();
      await _storage.clearAllData();
    } catch (error) {
      print('로그아웃 실패: $error');
      // 로컬 데이터는 삭제
      await _storage.clearAllData();
    }
  }

  // 현재 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    try {
      // 저장된 사용자 ID가 있는지 확인
      final userId = await _storage.getKakaoUserId();
      if (userId == null) return false;

      // 카카오 토큰 유효성 확인
      await UserApi.instance.accessTokenInfo();
      return true;
    } catch (error) {
      return false;
    }
  }

  // 저장된 사용자 정보 가져오기
  static Future<UserInfo?> getCurrentUser() async {
    final userId = await _storage.getKakaoUserId();
    final userName = await _storage.getUserName();

    if (userId == null) return null;

    return UserInfo(
      userId: userId,
      userName: userName ?? '사용자',
    );
  }
}
