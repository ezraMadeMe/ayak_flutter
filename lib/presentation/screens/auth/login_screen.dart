import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yakunstructuretest/presentation/providers/auth_provider.dart';
import 'package:yakunstructuretest/services/auth/kakao_auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고 또는 앱 이름
              const Text(
                '아약!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              
              // 카카오 로그인 버튼
              GestureDetector(
                onTap: () async {
                  final result = await KakaoAuthService.signInWithKakao();
                  if (result.isSuccess) {
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('로그인 실패: ${result.errorMessage}')),
                      );
                    }
                  }
                },
                child: Container(
                  width: 300,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE500),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      '카카오 로그인',
                      style: TextStyle(
                        color: Color(0xFF191919),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 