// api_service.dart
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yakunstructuretest/data/models/medication_record_model.dart';
import 'package:yakunstructuretest/presentation/screens/home/PillGrid.dart';

class ApiService {
  static const String baseUrl = 'https://your-api-domain.com/api';
  static const String _tokenKey = 'auth_token';

  // 싱글톤 패턴
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // 인증 토큰 관리
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // HTTP 요청 래퍼
  Future<ApiResponse<T>> _makeRequest<T>({
    required String method,
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, String>? queryParams,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: data != null ? json.encode(data) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: data != null ? json.encode(data) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('지원되지 않는 HTTP 메소드: $method');
      }

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(
          data: fromJson(responseData['data']),
          message: responseData['message'] ?? 'Success',
        );
      } else {
        return ApiResponse.error(
          message: responseData['message'] ?? 'Unknown error',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: '네트워크 오류: ${e.toString()}',
        statusCode: -1,
      );
    }
  }
}

// API 응답 래퍼 클래스
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final int? statusCode;

  ApiResponse._({
    required this.success,
    this.data,
    required this.message,
    this.statusCode,
  });

  factory ApiResponse.success({
    required T data,
    required String message,
  }) {
    return ApiResponse._(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error({
    required String message,
    required int statusCode,
  }) {
    return ApiResponse._(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}


// 약물 기본 정보 모델
class MedicationBasic {
  final int itemSeq;
  final String itemName;
  final String entpName;
  final String? itemImage;
  final String className;
  final String dosageForm;
  final bool isPrescription;

  MedicationBasic({
    required this.itemSeq,
    required this.itemName,
    required this.entpName,
    this.itemImage,
    required this.className,
    required this.dosageForm,
    required this.isPrescription,
  });

  factory MedicationBasic.fromJson(Map<String, dynamic> json) {
    return MedicationBasic(
      itemSeq: json['item_seq'],
      itemName: json['item_name'],
      entpName: json['entp_name'],
      itemImage: json['item_image'],
      className: json['class_name'],
      dosageForm: json['dosage_form'],
      isPrescription: json['is_prescription'],
    );
  }
}


class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  DateRange({required this.startDate, required this.endDate});

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }
}