// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yakunstructuretest/core/storage/secure_storage.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? meta;

  ApiResponse({
    required this.success,
    this.message = '',
    this.data,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJson(json['data']) : null,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  factory ApiResponse.error(String message) {
    return ApiResponse(
      success: false,
      message: message,
    );
  }
}

class ApiService {
  static const String baseUrl = 'http://172.30.1.57:8000/api/v1'; // 실제 API 서버 주소로 변경 필요
  static const int timeoutDuration = 30; // 초 단위

  // 인증이 필요하지 않은 엔드포인트 목록
  static const List<String> _noAuthEndpoints = [
    '/user/auth/login',
    '/user/auth/register',
    '/user/auth/social-login',
    'user/auth/login',  // auth_api_service.dart에서 사용하는 엔드포인트
  ];

  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<ApiResponse<T>> makeRequest<T>({
    required String method,
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? data,
    Map<String, String>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      // 인증 토큰 가져오기
      String? token;
      // 인증이 필요하고, 현재 엔드포인트가 인증 예외 목록에 없는 경우에만 토큰 검사
      if (requiresAuth && !_noAuthEndpoints.any((e) => endpoint.endsWith(e))) {
        token = await SecureStorage.getAccessToken();
        if (token == null) {
          return ApiResponse.error('인증 토큰이 없습니다.');
        }
        _defaultHeaders['Authorization'] = 'Bearer $token';
      }

      // URL 생성
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      // HTTP 요청 준비
      http.Response response;
      final headers = Map<String, String>.from(_defaultHeaders);

      // HTTP 메소드에 따른 요청 실행
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(uri, headers: headers)
              .timeout(Duration(seconds: timeoutDuration));
          break;

        case 'POST':
          response = await http
              .post(
                uri,
                headers: headers,
                body: data != null ? json.encode(data) : null,
              )
              .timeout(Duration(seconds: timeoutDuration));
          break;

        case 'PUT':
          response = await http
              .put(
                uri,
                headers: headers,
                body: data != null ? json.encode(data) : null,
              )
              .timeout(Duration(seconds: timeoutDuration));
          break;

        case 'DELETE':
          response = await http
              .delete(
                uri,
                headers: headers,
                body: data != null ? json.encode(data) : null,
              )
              .timeout(Duration(seconds: timeoutDuration));
          break;

        default:
          throw Exception('지원하지 않는 HTTP 메소드입니다.');
      }

      // 응답 처리
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = json.decode(response.body);
        return ApiResponse.fromJson(jsonResponse, fromJson);
      }

      // 에러 응답 처리
      if (response.statusCode == 401) {
        // 토큰 만료 처리
        if (requiresAuth && !_noAuthEndpoints.any((e) => endpoint.endsWith(e))) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            // 토큰 갱신 성공 시 요청 재시도
            return makeRequest(
              method: method,
              endpoint: endpoint,
              fromJson: fromJson,
              data: data,
              queryParams: queryParams,
              requiresAuth: requiresAuth,
            );
          }
        }
        return ApiResponse.error('인증이 만료되었습니다.');
      }

      return ApiResponse.error(_parseErrorMessage(response));
    } catch (e) {
      return ApiResponse.error('요청 처리 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: _defaultHeaders,
        body: json.encode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final newAccessToken = jsonResponse['data']['access_token'];
        final newRefreshToken = jsonResponse['data']['refresh_token'];

        await SecureStorage.saveAuthTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        return true;
      }

      // 리프레시 토큰도 만료된 경우
      await SecureStorage.clearAuthTokens();
      return false;
    } catch (e) {
      return false;
    }
  }

  String _parseErrorMessage(http.Response response) {
    try {
      final body = json.decode(response.body);
      return body['message'] ?? '알 수 없는 오류가 발생했습니다.';
    } catch (e) {
      return '서버 오류가 발생했습니다. (${response.statusCode})';
    }
  }
}
