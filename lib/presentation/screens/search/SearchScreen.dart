import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yakunstructuretest/core/constants/app_colors.dart';
import 'package:yakunstructuretest/presentation/providers/search_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all'; // all, medications, records, notes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '약물명, 메모 내용 검색...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              onPressed: () => _performSearch(),
              icon: Icon(Icons.search),
            ),
          ),
          onSubmitted: (_) => _performSearch(),
        ),
      ),
      body: Column(
        children: [
          // 검색 필터
          _buildSearchFilters(),

          // 검색 결과
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (provider.searchResults.isEmpty && _searchController.text.isNotEmpty) {
                  return _buildEmptyState();
                }

                return _buildSearchResults(provider.searchResults);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilters() {
    return Container(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('전체', 'all'),
            SizedBox(width: 8),
            _buildFilterChip('약물', 'medications'),
            SizedBox(width: 8),
            _buildFilterChip('복약기록', 'records'),
            SizedBox(width: 8),
            _buildFilterChip('메모', 'notes'),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<SearchResult> results) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return _buildSearchResultItem(result);
      },
    );
  }

  Widget _buildSearchResultItem(SearchResult result) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getResultTypeColor(result.type),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getResultTypeLabel(result.type),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              Spacer(),
              Text(result.date.toString(), style: AppTextStyles.caption),
            ],
          ),
          SizedBox(height: 8),
          Text(result.title, style: AppTextStyles.subtitle),
          if (result.subtitle != null) ...[
            SizedBox(height: 4),
            Text(result.subtitle!, style: AppTextStyles.caption),
          ],
          if (result.highlightedContent != null) ...[
            SizedBox(height: 8),
            Text(result.highlightedContent!, style: AppTextStyles.body),
          ],
        ],
      ),
    );
  }

  // 누락된 메서드 1: 필터 칩 빌더
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.primary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        if (_searchController.text.isNotEmpty) {
          _performSearch();
        }
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      elevation: isSelected ? 2 : 0,
      shadowColor: AppColors.primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
          width: 1,
        ),
      ),
    );
  }
  // 누락된 메서드 2: 빈 상태 위젯
  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.search_off,
                size: 40,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '검색 결과가 없습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '다른 키워드로 검색해보세요\n또는 필터를 변경해보세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '💡 팁: 약물명의 일부만 입력해도 검색됩니다',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 누락된 메서드 3: 결과 타입별 색상
  Color _getResultTypeColor(SearchResultType type) {
    switch (type) {
      case SearchResultType.medication:
        return Colors.blue;
      case SearchResultType.record:
        return Colors.green;
      case SearchResultType.note:
        return Colors.orange;
      case SearchResultType.prescription:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // 누락된 메서드 4: 결과 타입별 라벨
  String _getResultTypeLabel(SearchResultType type) {
    switch (type) {
      case SearchResultType.medication:
        return '약물';
      case SearchResultType.record:
        return '복약기록';
      case SearchResultType.note:
        return '메모';
      case SearchResultType.prescription:
        return '처방전';
      default:
        return '기타';
    }
  }

  // 날짜 포맷팅 메서드
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<SearchProvider>().search(query, _selectedFilter);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}