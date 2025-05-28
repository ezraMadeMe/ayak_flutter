# yakunstructuretest

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

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