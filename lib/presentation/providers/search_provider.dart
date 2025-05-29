import 'package:flutter/material.dart';

// 검색 결과 타입 열거형
enum SearchResultType {
  medication,
  record,
  note,
  prescription,
}

// 검색 결과 모델
class SearchResult {
  final String id;
  final SearchResultType type;
  final String title;
  final String? subtitle;
  final String? highlightedContent;
  final DateTime date;
  final Map<String, dynamic>? additionalData;

  SearchResult({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.highlightedContent,
    required this.date,
    this.additionalData,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'],
      type: SearchResultType.values.firstWhere(
            (e) => e.toString().split('.').last == json['type'],
        orElse: () => SearchResultType.medication,
      ),
      title: json['title'],
      subtitle: json['subtitle'],
      highlightedContent: json['highlighted_content'],
      date: DateTime.parse(json['date']),
      additionalData: json['additional_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'subtitle': subtitle,
      'highlighted_content': highlightedContent,
      'date': date.toIso8601String(),
      'additional_data': additionalData,
    };
  }
}

// 검색 데이터 모델
class SearchDataModel {
  final List<SearchResult> results;
  final int totalCount;
  final String query;
  final String filter;
  final DateTime searchTime;

  SearchDataModel({
    required this.results,
    required this.totalCount,
    required this.query,
    required this.filter,
    required this.searchTime,
  });

  factory SearchDataModel.fromJson(Map<String, dynamic> json) {
    return SearchDataModel(
      results: (json['results'] as List)
          .map((item) => SearchResult.fromJson(item))
          .toList(),
      totalCount: json['total_count'] ?? 0,
      query: json['query'] ?? '',
      filter: json['filter'] ?? 'all',
      searchTime: DateTime.parse(json['search_time']),
    );
  }
}

// 검색 제공자 클래스
class SearchProvider with ChangeNotifier {
  SearchDataModel? _searchData;
  bool _isLoading = false;
  String? _error;
  List<String> _recentSearches = [];
  Map<String, List<SearchResult>> _searchCache = {};

  // Getters
  SearchDataModel? get searchData => _searchData;
  List<SearchResult> get searchResults => _searchData?.results ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get recentSearches => _recentSearches;
  int get totalCount => _searchData?.totalCount ?? 0;

  // 검색 수행
  Future<void> search(String query, String filter) async {
    if (query.trim().isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 캐시 확인
      final cacheKey = '${query}_$filter';
      if (_searchCache.containsKey(cacheKey)) {
        _searchData = SearchDataModel(
          results: _searchCache[cacheKey]!,
          totalCount: _searchCache[cacheKey]!.length,
          query: query,
          filter: filter,
          searchTime: DateTime.now(),
        );
        _addToRecentSearches(query);
        _isLoading = false;
        notifyListeners();
        return;
      }

      // API 호출 시뮬레이션
      await Future.delayed(Duration(milliseconds: 600));

      // 테스트 데이터 생성
      final results = _generateTestSearchResults(query, filter);

      _searchData = SearchDataModel(
        results: results,
        totalCount: results.length,
        query: query,
        filter: filter,
        searchTime: DateTime.now(),
      );

      // 캐시에 저장
      _searchCache[cacheKey] = results;
      _addToRecentSearches(query);

    } catch (e) {
      _error = 'Failed to search: $e';
      print('Error during search: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 테스트 검색 결과 생성
  List<SearchResult> _generateTestSearchResults(String query, String filter) {
    final allResults = [
      // 약물 검색 결과
      SearchResult(
        id: 'med_1',
        type: SearchResultType.medication,
        title: '제프람 (에스시탈로프람)',
        subtitle: '10mg • 항우울제',
        highlightedContent: '우울증 및 불안장애 치료에 사용되는 SSRI 계열 약물입니다.',
        date: DateTime.now().subtract(Duration(days: 1)),
        additionalData: {'dosage': '10mg', 'category': '항우울제'},
      ),
      SearchResult(
        id: 'med_2',
        type: SearchResultType.medication,
        title: '알프람 (알프라졸람)',
        subtitle: '0.25mg • 항불안제',
        highlightedContent: '불안장애와 공황장애 치료에 사용되는 벤조디아제핀 계열 약물입니다.',
        date: DateTime.now().subtract(Duration(days: 2)),
        additionalData: {'dosage': '0.25mg', 'category': '항불안제'},
      ),
      // 복약기록 검색 결과
      SearchResult(
        id: 'record_1',
        type: SearchResultType.record,
        title: '제프람 복용 기록',
        subtitle: '오전 8:30 복용 완료',
        highlightedContent: '정시 복용 완료. 부작용 없음.',
        date: DateTime.now().subtract(Duration(hours: 2)),
        additionalData: {'status': 'completed', 'time': '08:30'},
      ),
      SearchResult(
        id: 'record_2',
        type: SearchResultType.record,
        title: '알프람 복용 기록',
        subtitle: '저녁 9:00 복용 완료',
        highlightedContent: '복용 후 약간의 졸음 느낌.',
        date: DateTime.now().subtract(Duration(days: 1)),
        additionalData: {'status': 'completed', 'time': '21:00'},
      ),
      // 메모 검색 결과
      SearchResult(
        id: 'note_1',
        type: SearchResultType.note,
        title: '부작용 메모',
        subtitle: '제프람 관련',
        highlightedContent: '복용 후 첫 주에 약간의 메스꺼움이 있었으나 현재는 사라짐.',
        date: DateTime.now().subtract(Duration(days: 7)),
        additionalData: {'medication': '제프람', 'severity': 'mild'},
      ),
      SearchResult(
        id: 'note_2',
        type: SearchResultType.note,
        title: '수면 패턴 관찰',
        subtitle: '알프람 효과',
        highlightedContent: '알프람 복용 후 수면의 질이 개선되었음. 중간에 깨는 횟수가 줄어들었음.',
        date: DateTime.now().subtract(Duration(days: 3)),
        additionalData: {'medication': '알프람', 'category': '수면'},
      ),
      // 처방전 검색 결과
      SearchResult(
        id: 'prescription_1',
        type: SearchResultType.prescription,
        title: '정신건강의학과 처방전',
        subtitle: '김○○ 의사 • 2024.05.20',
        highlightedContent: '제프람 10mg → 20mg 증량, 알프람 0.5mg → 0.25mg 감량',
        date: DateTime.now().subtract(Duration(days: 9)),
        additionalData: {'doctor': '김○○', 'hospital': '○○병원'},
      ),
    ];

    // 쿼리와 필터에 따른 결과 필터링
    List<SearchResult> filteredResults = allResults;

    // 필터 적용
    if (filter != 'all') {
      SearchResultType? filterType;
      switch (filter) {
        case 'medications':
          filterType = SearchResultType.medication;
          break;
        case 'records':
          filterType = SearchResultType.record;
          break;
        case 'notes':
          filterType = SearchResultType.note;
          break;
      }
      if (filterType != null) {
        filteredResults = filteredResults.where((result) => result.type == filterType).toList();
      }
    }

    // 검색어 필터링 (제목, 부제목, 내용에서 검색)
    final queryLower = query.toLowerCase();
    filteredResults = filteredResults.where((result) {
      return result.title.toLowerCase().contains(queryLower) ||
          (result.subtitle?.toLowerCase().contains(queryLower) ?? false) ||
          (result.highlightedContent?.toLowerCase().contains(queryLower) ?? false);
    }).toList();

    // 날짜순 정렬 (최신순)
    filteredResults.sort((a, b) => b.date.compareTo(a.date));

    return filteredResults;
  }

  // 최근 검색어에 추가
  void _addToRecentSearches(String query) {
    _recentSearches.remove(query); // 중복 제거
    _recentSearches.insert(0, query); // 맨 앞에 추가
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.take(10).toList(); // 최대 10개 유지
    }
  }

  // 검색 결과 초기화
  void clearSearch() {
    _searchData = null;
    _error = null;
    notifyListeners();
  }

  // 최근 검색어 삭제
  void removeRecentSearch(String query) {
    _recentSearches.remove(query);
    notifyListeners();
  }

  // 모든 최근 검색어 삭제
  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
  }

  // 캐시 초기화
  void clearCache() {
    _searchCache.clear();
  }

  // 특정 타입의 검색 결과만 가져오기
  List<SearchResult> getResultsByType(SearchResultType type) {
    return searchResults.where((result) => result.type == type).toList();
  }

  // 검색 결과 새로고침
  Future<void> refreshSearch() async {
    if (_searchData != null) {
      clearCache();
      await search(_searchData!.query, _searchData!.filter);
    }
  }

  // 고급 검색 (여러 필터 조건)
  Future<void> advancedSearch({
    required String query,
    List<SearchResultType>? types,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, dynamic>? additionalFilters,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 800));

      List<SearchResult> results = _generateTestSearchResults(query, 'all');

      // 타입 필터링
      if (types != null && types.isNotEmpty) {
        results = results.where((result) => types.contains(result.type)).toList();
      }

      // 날짜 범위 필터링
      if (startDate != null) {
        results = results.where((result) => result.date.isAfter(startDate)).toList();
      }
      if (endDate != null) {
        results = results.where((result) => result.date.isBefore(endDate.add(Duration(days: 1)))).toList();
      }

      _searchData = SearchDataModel(
        results: results,
        totalCount: results.length,
        query: query,
        filter: 'advanced',
        searchTime: DateTime.now(),
      );

      _addToRecentSearches(query);

    } catch (e) {
      _error = 'Failed to perform advanced search: $e';
      print('Error during advanced search: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}