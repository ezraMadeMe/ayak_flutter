
// services/illness_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:yakunstructuretest/data/models/illness_model.dart';

class IllnessService {
  static String domain = 'apis.data.go.kr';
  static String path = 'B551182/diseaseInfoService1/getDissNameCodeList1';
  static String serviceKey = dotenv.get("ILLNESS_DEC");
  static String baseUrl = dotenv.get("HOST");

  // 공공 API에서 질병 검색
  static Future<List<Illness>> searchDiseases(String keyword) async {
    try {
      Map<String, dynamic> params = {
        'serviceKey': serviceKey,
        'sickType': '2',
        'medTp': '1',
        'diseaseType': 'SICK_NM',
        'searchText': keyword,
        'numOfRows': '20',
        'pageNo': '1'
      };

      Uri uri = Uri.https(domain, path, params);
      final result = await http.get(uri);

      if (result.statusCode == 200) {
        final responseBody = utf8.decode(result.bodyBytes);
        final document = XmlDocument.parse(responseBody);
        final items = document.findAllElements('item');

        return items.map((xml) => Illness.fromXml(xml)).toList();
      } else if (result.statusCode == 404) {
        return [];
      } else {
        throw IllnessSearchException('질병 검색 실패: ${result.statusCode}');
      }
    } catch (e) {
      throw IllnessSearchException('네트워크 오류: $e');
    }
  }

  // 질병/증상 등록
  static Future<Illness> registerIllness(Illness illness) async {
    try {
      final response = await http.post(
        Uri.http(baseUrl, 'user/illness_info/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(illness.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Illness.fromJson(data['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw IllnessRegistrationException(errorData['message'] ?? '질병/증상 등록 실패');
      }
    } catch (e) {
      if (e is IllnessRegistrationException) rethrow;
      throw IllnessRegistrationException('네트워크 오류: $e');
    }
  }

  // 등록된 질병/증상 목록 조회
  static Future<List<Illness>> getMyIllnesses(String userId) async {
    try {
      final response = await http.get(
        Uri.http(baseUrl, 'user/illnesses/$userId/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> illnessesJson = data['data'];
        return illnessesJson.map((json) => Illness.fromJson(json)).toList();
      } else {
        throw Exception('등록된 질병/증상 조회 실패');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }
}

class IllnessSearchException implements Exception {
  final String message;
  IllnessSearchException(this.message);

  @override
  String toString() => message;
}

class IllnessRegistrationException implements Exception {
  final String message;
  IllnessRegistrationException(this.message);

  @override
  String toString() => message;
}