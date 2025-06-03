// presentation/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:yakunstructuretest/core/constants/app_colors.dart';
import 'package:yakunstructuretest/presentation/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLogin = true;  // 로그인/회원가입 모드
  bool _isPasswordVisible = false;
  bool _pushAgree = false;
  bool _marketingAgree = false;

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 60),
                    _buildLogo(),
                    SizedBox(height: 40),
                    _buildToggleButtons(),
                    SizedBox(height: 32),
                    if (_isLogin) ..._buildLoginForm() else ..._buildRegisterForm(),
                    SizedBox(height: 24),
                    _buildSubmitButton(authProvider),
                    SizedBox(height: 16),
                    _buildDivider(),
                    SizedBox(height: 16),
                    _buildSocialLoginButtons(),
                    if (authProvider.errorMessage != null) ...[
                      SizedBox(height: 16),
                      _buildErrorMessage(authProvider.errorMessage!),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.medication,
            color: Colors.white,
            size: 40,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'AYAK',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          '복약 관리의 새로운 시작',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLogin = true),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isLogin ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  '로그인',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isLogin ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLogin = false),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isLogin ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  '회원가입',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !_isLogin ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLoginForm() {
    return [
      TextFormField(
        controller: _userIdController,
        decoration: InputDecoration(
          labelText: '사용자 ID',
          prefixIcon: Icon(Icons.person),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '사용자 ID를 입력해주세요';
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: '비밀번호',
          prefixIcon: Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '비밀번호를 입력해주세요';
          }
          return null;
        },
      ),
    ];
  }

  List<Widget> _buildRegisterForm() {
    return [
      TextFormField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: '이름',
          prefixIcon: Icon(Icons.person),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '이름을 입력해주세요';
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: '이메일 (선택사항)',
          prefixIcon: Icon(Icons.email),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return '올바른 이메일 형식을 입력해주세요';
            }
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: '비밀번호',
          prefixIcon: Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '비밀번호를 입력해주세요';
          }
          if (value.length < 6) {
            return '비밀번호는 6자 이상이어야 합니다';
          }
          return null;
        },
      ),
      SizedBox(height: 20),
      _buildAgreementCheckboxes(),
    ];
  }

  Widget _buildAgreementCheckboxes() {
    return Column(
      children: [
        CheckboxListTile(
          title: Text(
            '푸시 알림 수신 동의',
            style: TextStyle(fontSize: 14),
          ),
          subtitle: Text(
            '복약 시간 알림을 받으시겠습니까?',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          value: _pushAgree,
          onChanged: (value) => setState(() => _pushAgree = value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: Text(
            '마케팅 정보 수신 동의 (선택)',
            style: TextStyle(fontSize: 14),
          ),
          subtitle: Text(
            '건강 정보 및 이벤트 소식을 받으시겠습니까?',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          value: _marketingAgree,
          onChanged: (value) => setState(() => _marketingAgree = value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AuthProvider authProvider) {
    return ElevatedButton(
      onPressed: authProvider.isLoading ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: authProvider.isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              _isLogin ? '로그인' : '회원가입',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '또는',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        _buildSocialButton(
          '구글로 시작하기',
          'assets/logo/google.png',
          Colors.white,
          Colors.black87,
          () => _handleSocialLogin('google'),
        ),
        SizedBox(height: 12),
        _buildSocialButton(
          '카카오로 시작하기',
          'assets/logo/kakao.png',
          Color(0xFFFFE812),
          Color(0xFF3C1E1E),
          () => _handleSocialLogin('kakao'),
        ),
        SizedBox(height: 12),
        _buildSocialButton(
          'Apple로 시작하기',
          'assets/logo/apple.png',
          Colors.black,
          Colors.white,
          () => _handleSocialLogin('apple'),
        ),
      ],
    );
  }

  Widget _buildSocialButton(
    String text,
    String iconPath,
    Color backgroundColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconPath, width: 20, height: 20),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red[800], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    bool success = false;

    if (_isLogin) {
      success = await authProvider.login(
        userId: _userIdController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      success = await authProvider.register(
        userName: _nameController.text.trim(),
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        password: _passwordController.text,
        pushAgree: _pushAgree,
        marketingAgree: _marketingAgree,
      );
    }

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLogin ? '로그인되었습니다!' : '회원가입이 완료되었습니다!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    try {
      final authProvider = context.read<AuthProvider>();
      Map<String, dynamic>? socialResult;

      switch (provider) {
        case 'google':
          socialResult = await _signInWithGoogle();
          break;
        case 'kakao':
          socialResult = await _signInWithKakao();
          break;
        case 'apple':
          socialResult = await _signInWithApple();
          break;
      }

      if (socialResult != null && mounted) {
        final success = await authProvider.socialLogin(
          socialProvider: provider,
          socialId: socialResult['id'],
          userName: socialResult['name'] ?? socialResult['nickname'],
          email: socialResult['email'],
          profileImageUrl: socialResult['picture'] ?? socialResult['profile_image'],
        );

        if (success && mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${provider.toUpperCase()} 로그인 성공!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${provider.toUpperCase()} 로그인 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
      );

      // 기존 로그인 정보가 있다면 로그아웃
      await googleSignIn.signOut();
      
      // 구글 로그인 시도
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) return null;

      // 구글 인증 정보 획득
      final GoogleSignInAuthentication auth = await account.authentication;

      return {
        'id': account.id,
        'name': account.displayName ?? '',
        'email': account.email,
        'picture': account.photoUrl,
        'token': auth.accessToken,  // 서버 인증에 필요할 수 있음
      };
    } catch (e) {
      print('Google Sign-In 실패: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _signInWithKakao() async {
    try {
      print('카카오 로그인 시작');
      // 카카오톡 설치 여부 확인
      if (await isKakaoTalkInstalled()) {
        print('카카오톡 설치됨, 카카오톡으로 로그인 시도');
        try {
          // 카카오톡으로 로그인
          await UserApi.instance.loginWithKakaoTalk();
          print('카카오톡 로그인 성공');
        } catch (error) {
          print('카카오톡 로그인 실패: $error');
          // 사용자가 카카오톡 로그인을 취소한 경우 카카오계정으로 로그인 시도
          if (error is PlatformException && error.code == 'CANCELED') {
            print('카카오톡 로그인 취소됨, 카카오계정으로 로그인 시도');
            await UserApi.instance.loginWithKakaoAccount();
            print('카카오계정 로그인 성공');
          } else {
            rethrow;
          }
        }
      } else {
        print('카카오톡 미설치, 카카오계정으로 로그인 시도');
        // 카카오톡이 설치되어 있지 않은 경우 카카오계정으로 로그인
        await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정 로그인 성공');
      }

      // 사용자 정보 요청
      print('사용자 정보 요청 시작');
      User user = await UserApi.instance.me();
      print('사용자 정보 요청 성공: ${user.id}');

      return {
        'id': user.id.toString(),
        'nickname': user.kakaoAccount?.profile?.nickname,
        'email': user.kakaoAccount?.email,
        'profile_image': user.kakaoAccount?.profile?.profileImageUrl,
        'token': await TokenManagerProvider.instance.manager.getToken(),
      };
    } catch (e) {
      print('Kakao Sign-In 실패 (상세): $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _signInWithApple() async {
    await Future.delayed(Duration(seconds: 1));
    return {
      'id': 'apple_test_${DateTime.now().millisecondsSinceEpoch}',
      'name': 'Apple 테스트',
      'email': 'test@icloud.com',
    };
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(Duration(seconds: 1)); // 스플래시 최소 표시 시간

    final authProvider = context.read<AuthProvider>();
    await authProvider.checkAuthStatus();

    if (mounted) {
      if (authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.medication,
                        color: AppColors.primary,
                        size: 60,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'AYAK',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '복약 관리의 새로운 시작',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 40),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        if (authProvider.isLoading) {
                          return CircularProgressIndicator(
                            color: Colors.white,
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}