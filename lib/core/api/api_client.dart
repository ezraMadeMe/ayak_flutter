
// ===== 6. API 서비스들 =====

import 'package:yakunstructuretest/presentation/screens/home/HomeScreen.dart';

class MedicationApiService {
  static const String baseUrl = 'https://api.yourapp.com/api/v1';

  // 복약 그룹 관련 API
  Future<List<MedicationGroupModel>> getMedicationGroups(String userId) async {
    final response = await ApiClient.get('/medication-groups/?user_id=$userId');
    return (response.data as List)
        .map((json) => MedicationGroupModel.fromJson(json))
        .toList();
  }

  Future<MedicationGroupModel> createMedicationGroup(CreateMedicationGroupRequest request) async {
    final response = await ApiClient.post('/medication-groups/', data: request.toJson());
    return MedicationGroupModel.fromJson(response.data);
  }

  // 복약 사이클 관련 API
  Future<List<MedicationCycleModel>> getMedicationCycles(String groupId) async {
    final response = await ApiClient.get('/medication-cycles/?group_id=$groupId');
    return (response.data as List)
        .map((json) => MedicationCycleModel.fromJson(json))
        .toList();
  }

  Future<MedicationCycleModel> createMedicationCycle(CreateMedicationCycleRequest request) async {
    final response = await ApiClient.post('/medication-cycles/', data: request.toJson());
    return MedicationCycleModel.fromJson(response.data);
  }

  // 복약 기록 관련 API
  Future<List<MedicationRecordModel>> getMedicationRecords({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String url = '/medication-records/?user_id=$userId';
    if (startDate != null) url += '&start_date=${startDate.toIso8601String()}';
    if (endDate != null) url += '&end_date=${endDate.toIso8601String()}';

    final response = await ApiClient.get(url);
    return (response.data as List)
        .map((json) => MedicationRecordModel.fromJson(json))
        .toList();
  }

  Future<MedicationRecordModel> createMedicationRecord(CreateMedicationRecordRequest request) async {
    final response = await ApiClient.post('/medication-records/', data: request.toJson());
    return MedicationRecordModel.fromJson(response.data);
  }

  // 검색 API
  Future<List<SearchResultModel>> searchMedications(String query, String filter) async {
    final response = await ApiClient.get('/search/?q=$query&filter=$filter');
    return (response.data as List)
        .map((json) => SearchResultModel.fromJson(json))
        .toList();
  }

  // 통계 API
  Future<AnalyticsDataModel> getAnalyticsData({
  required String userId,
  required DateTime startDate,