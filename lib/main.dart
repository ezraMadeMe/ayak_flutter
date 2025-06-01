import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:yakunstructuretest/core/storage/storage_manager.dart';
import 'package:yakunstructuretest/presentation/providers/analytics_provider.dart';
import 'package:yakunstructuretest/presentation/providers/auth_provider.dart';
import 'package:yakunstructuretest/presentation/providers/hospital_provider.dart';
import 'package:yakunstructuretest/presentation/providers/illness_provider.dart';
import 'package:yakunstructuretest/presentation/providers/medication_provider.dart';
import 'package:yakunstructuretest/presentation/providers/prescription_provider.dart';
import 'package:yakunstructuretest/presentation/providers/search_provider.dart';
import 'package:yakunstructuretest/presentation/screens/home/MainTabView.dart';
import 'package:yakunstructuretest/presentation/screens/medication/MedicationScreen.dart';
import 'package:yakunstructuretest/presentation/screens/prescriptions/PrescriptionRenewalScreen.dart';
import 'package:yakunstructuretest/presentation/screens/search/HospitalSearchScreen.dart';
import 'package:yakunstructuretest/presentation/screens/search/IllnessSearchScreen.dart';
import 'package:yakunstructuretest/presentation/screens/search/SearchScreen.dart';
import 'package:yakunstructuretest/presentation/screens/statistics/StatisticsScreen.dart';


void main() async {

  await dotenv.load(fileName: '.env');
  // 카카오 SDK 초기화
  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!,
    javaScriptAppKey: dotenv.env['KAKAO_JAVASCRIPT_APP_KEY']!,
  );
  // 스토리지 초기화
  await StorageManager.instance.init();
  HttpOverrides.global = MyHttpOverrides();

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
      ],
      child: MaterialApp(
        home: MainTabView(),
        routes: {
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
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