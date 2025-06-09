import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:yakunstructuretest/core/storage/storage_manager.dart';
import 'package:yakunstructuretest/presentation/providers/analytics_provider.dart';
import 'package:yakunstructuretest/presentation/providers/auth_provider.dart';
import 'package:yakunstructuretest/presentation/providers/hospital_provider.dart';
import 'package:yakunstructuretest/presentation/providers/illness_provider.dart';
import 'package:yakunstructuretest/presentation/providers/medication_provider.dart';
import 'package:yakunstructuretest/presentation/providers/prescription_provider.dart';
import 'package:yakunstructuretest/presentation/providers/search_provider.dart';
import 'package:yakunstructuretest/presentation/providers/enhanced_medication_provider.dart';
import 'package:yakunstructuretest/presentation/screens/auth/login_screen.dart';
import 'package:yakunstructuretest/presentation/screens/home/MainTabView.dart';
import 'package:yakunstructuretest/presentation/screens/medication/MedicationScreen.dart';
import 'package:yakunstructuretest/presentation/screens/prescriptions/PrescriptionRenewalScreen.dart';
import 'package:yakunstructuretest/presentation/screens/search/HospitalSearchScreen.dart';
import 'package:yakunstructuretest/presentation/screens/search/IllnessSearchScreen.dart';
import 'package:yakunstructuretest/presentation/screens/search/SearchScreen.dart';
import 'package:yakunstructuretest/presentation/screens/statistics/StatisticsScreen.dart';
import 'package:yakunstructuretest/services/auth/kakao_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: '.env');
  // 카카오 SDK 초기화
  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!,
    javaScriptAppKey: dotenv.env['KAKAO_JAVASCRIPT_APP_KEY']!,
  );

  // 키해시 출력
  var keyHash = await KakaoSdk.origin;
  print('Kakao Key Hash: $keyHash');

  // 스토리지 초기화
  await StorageManager.instance.init();
  HttpOverrides.global = MyHttpOverrides();

  // 자동 로그인 체크
  final isKakaoLoggedIn = await KakaoAuthService.isLoggedIn();
  bool isLoggedIn = false;
  try {
    final response = await FlutterNaverLogin.isLoggedIn();
    isLoggedIn = response == true;
  }catch(e){
    print('네이버 로그인 오류: $e');
    isLoggedIn = false; // 오류 시 기본값으로 false 설정
  }


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => PrescriptionProvider()),
        ChangeNotifierProvider(create: (_) => HospitalProvider()),
        ChangeNotifierProvider(create: (_) => IllnessProvider()),
        ChangeNotifierProvider(create: (_) => EnhancedMedicationProvider()),
      ],
      child: MaterialApp(
        //home: MainTabView(),
        home: isLoggedIn ? MainTabView() : LoginScreen(),
        routes: {
          '/home': (context) => MainTabView(),
          '/search': (context) => Scaffold(appBar: AppBar(title: Text('검색')), body: SearchScreen()),
          '/schedule': (context) => Scaffold(appBar: AppBar(title: Text('일정')), body: Center(child: Text('일정 화면'))),
          '/medication-group': (context) => Scaffold(appBar: AppBar(title: Text('그룹 등록')), body: Center(child: Text('그룹 등록 화면'))),
          '/medication-cycle': (context) => Scaffold(appBar: AppBar(title: Text('사이클 등록')), body: Center(child: Text('사이클 등록 화면'))),
          '/medication-record': (context) => Scaffold(appBar: AppBar(title: Text('복약 기록')), body: MedicationScreen()),
          '/statistics': (context) => Scaffold(appBar: AppBar(title: Text('처방 통계')), body: StatisticsScreen()),
          '/prescription-renewal': (context) => Scaffold(appBar: AppBar(title: Text('처방전 갱신')), body: PrescriptionRenewalScreen()),
          '/register-hospital': (context) => Scaffold(appBar: AppBar(title: Text('병원 등록')), body: HospitalSearchScreen()),
          '/register-illness': (context) => Scaffold(appBar: AppBar(title: Text('질병/증상 등록')), body: IllnessSearchScreen()),
        },
      ),
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MaterialApp(
        theme: ThemeData(
          fontFamily: "NEXON",
          buttonTheme: ButtonThemeData(),
          textTheme: TextTheme(
            titleLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            titleMedium: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            labelLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xEDFFB72E)),
            labelMedium: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            bodyLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          colorScheme: ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xB32E0B5A),
            onPrimary: Color(0xECDBB3FF),
            primaryContainer: Color(0xFFFFFDFA),
            secondary: Color(0xFFE7FF75),
            onSecondary: Color(0xB35F2BA8),
            surface: Color(0xFFFFFFFF),
            onSurface: Color(0xB32E0B5A),
            error: Color(0xFFFF6347),
            onError: Color(0xFFFFF8DC),
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme(
            brightness: Brightness.dark,
            primary: Color(0xB32E0B5A),
            onPrimary: Color(0xECDBB3FF),
            primaryContainer: Color(0xFFFFFDFA),
            secondary: Color(0xFFBEF8D0),
            onSecondary: Color(0xB35F2BA8),
            surface: Color(0xFFFFFFFF),
            onSurface: Color(0xB32E0B5A),
            error: Color(0xFFFF6347),
            onError: Color(0xFFFFF8DC),
          ),
        ),
      ),
    );
  }
}
// ===== 프로젝트 구조 =====
/*
lib/
├── main.dart
├── app/
│   ├── app.dart                    // 메인 앱 설정
│   ├── routes.dart                 // 라우팅 설정
│   └── theme.dart                  // 테마 설정
├── core/
│   ├── api/
│   │   ├── api_client.dart         // HTTP 클라이언트
│   │   ├── api_endpoints.dart      // API 엔드포인트 상수
│   │   └── api_interceptor.dart    // 인터셉터 (인증, 로깅)
│   ├── constants/
│   │   ├── app_colors.dart         // 색상 상수
│   │   ├── app_strings.dart        // 문자열 상수
│   │   └── app_dimensions.dart     // 크기 상수
│   ├── utils/
│   │   ├── date_utils.dart         // 날짜 유틸리티
│   │   ├── validator.dart          // 유효성 검사
│   │   └── formatter.dart          // 포맷터
│   └── widgets/
│       ├── custom_app_bar.dart     // 공통 앱바
│       ├── loading_widget.dart     // 로딩 위젯
│       ├── error_widget.dart       // 에러 위젯
│       └── custom_button.dart      // 공통 버튼
├── data/
│   ├── models/
│   │   ├── user_model.dart         // User 모델
│   │   ├── hospital_model.dart     // Hospital 모델
│   │   ├── illness_model.dart      // Illness 모델
│   │   ├── medication_model.dart   // Medication 모델
│   │   ├── medication_group_model.dart
│   │   ├── medication_cycle_model.dart
│   │   ├── medication_detail_model.dart
│   │   ├── medication_record_model.dart
│   │   └── response_wrapper.dart   // API 응답 래퍼
│   ├── repositories/
│   │   ├── auth_repository.dart    // 인증 레포지토리
│   │   ├── user_repository.dart    // 사용자 레포지토리
│   │   ├── medication_repository.dart
│   │   └── analytics_repository.dart
│   └── services/
│       ├── api_service.dart        // API 서비스
│       ├── local_storage_service.dart
│       └── notification_service.dart
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart      // 인증 상태 관리
│   │   ├── medication_provider.dart
│   │   ├── analytics_provider.dart
│   │   └── search_provider.dart
│   └── screens/
│       ├── home/                   // 홈 화면
│       ├── statistics/             // 통계 화면
│       ├── medication/             // 복약 화면
│       ├── search/                 // 검색 화면
│       ├── settings/               // 설정 화면
│       └── auth/                   // 인증 화면
└── generated/
    └── l10n/                       // 다국어 지원
*/