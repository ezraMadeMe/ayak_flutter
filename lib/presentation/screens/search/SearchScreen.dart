
// ===== 4. 검색 화면 (Search Screen) =====

import 'package:flutter/material.dart';

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

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<SearchProvider>().search(query, _selectedFilter);
    }
  }
}