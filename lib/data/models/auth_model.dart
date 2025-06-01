
// lib/models/auth_models.dart
class AuthResult {
  final bool isSuccess;
  final String? userId;
  final String? userName;
  final String? profileImage;
  final String? errorMessage;

  AuthResult._({
    required this.isSuccess,
    this.userId,
    this.userName,
    this.profileImage,
    this.errorMessage,
  });

  factory AuthResult.success({
    required String userId,
    required String userName,
    String? profileImage,
  }) {
    return AuthResult._(
      isSuccess: true,
      userId: userId,
      userName: userName,
      profileImage: profileImage,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}

class UserInfo {
  final String userId;
  final String userName;
  final String? profileImage;

  UserInfo({
    required this.userId,
    required this.userName,
    this.profileImage,
  });
}
