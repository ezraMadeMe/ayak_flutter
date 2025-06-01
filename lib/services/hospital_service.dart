// services/hospital_service.dart
import 'dart:convert';
import 'package:http/http.dart' as https;
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:yakunstructuretest/data/models/hospital_model.dart';


class HospitalService {
  static const domain = 'apis.data.go.kr';
  static const path = 'B551182/hospInfoServicev2/getHospBasisList';
  static String serviceKey = dotenv.get("HOSPITAL_DEC");
  static String baseUrl = dotenv.get("HOST");
  static String apiUrl = "/user/hospitals/";

  // 공공 API에서 병원 검색
  static Future<List<Hospital>> searchHospitals(String keyword) async {
    try {
      Map<String, dynamic> params = {
        'ServiceKey': serviceKey,
        'yadmNm': keyword,
        'numOfRows': '20',
        'pageNo': '1'
      };

      Uri uri = Uri.https(domain, path, params);
      final result = await https.get(uri);

      if (result.statusCode == 200) {
        final responseBody = utf8.decode(result.bodyBytes);
        final document = XmlDocument.parse(responseBody);
        final items = document.findAllElements('item');

        return items.map((xml) => Hospital.fromXml(xml)).toList();
      } else if (result.statusCode == 404) {
        return [];
      } else {
        throw HospitalSearchException('병원 검색 실패: ${result.statusCode}');
      }
    } catch (e) {
      throw HospitalSearchException('네트워크 오류: {$e}');
    }
  }

  // 내 병원 정보 등록
  static Future<Hospital> registerHospital(Hospital hospital) async {
    try {
      final response = await http.post(
        Uri.http(baseUrl, apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: utf8.encode(json.encode(hospital.toJson())),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Hospital.fromJson(data['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw HospitalRegistrationException(errorData['message'] ?? '병원 등록 실패');
      }
    } catch (e) {
      if (e is HospitalRegistrationException) rethrow;
      throw HospitalRegistrationException('네트워크 오류: $e');
    }
  }

  // 등록된 병원 목록 조회
  static Future<List<Hospital>> getMyHospitals(String userId) async {
    try {
      final response = await https.get(
        Uri.https(baseUrl, apiUrl, {'userId': userId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> hospitalsJson = data['data'];
        return hospitalsJson.map((json) => Hospital.fromJson(json)).toList();
      } else {
        throw Exception('등록된 병원 조회 실패');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }
}

class HospitalSearchException implements Exception {
  final String message;
  HospitalSearchException(this.message);

  @override
  String toString() => message;
}

class HospitalRegistrationException implements Exception {
  final String message;
  HospitalRegistrationException(this.message);

  @override
  String toString() => message;
}