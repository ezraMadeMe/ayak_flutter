
// services/prescription_service.dart
import 'dart:convert';
import 'package:yakunstructuretest/data/models/prescription_renewal_model.dart';
import 'package:http/http.dart' as http;

class PrescriptionService {
  static const String baseUrl = 'YOUR_API_BASE_URL';

  static Future<Map<String, dynamic>> renewPrescription(
      PrescriptionRenewalRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/prescriptions/renew/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN', // 실제 토큰으로 교체
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('처방전 갱신 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  static Future<CycleExpirationInfo> checkCycleExpiration(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cycles/expiration-check/$userId/'),
        headers: {
          'Authorization': 'Bearer YOUR_TOKEN', // 실제 토큰으로 교체
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CycleExpirationInfo.fromJson(data);
      } else {
        throw Exception('주기 만료 확인 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }
}
