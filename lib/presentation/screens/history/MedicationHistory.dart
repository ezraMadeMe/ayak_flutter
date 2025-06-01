
// 히스토리 탭 컨텐츠
import 'package:flutter/material.dart';
import 'package:yakunstructuretest/core/constants/app_colors.dart';

class HistoryTabContent extends StatefulWidget {
  const HistoryTabContent({super.key});

  @override
  State<HistoryTabContent> createState() => _HistoryTabContentState();
}

class _HistoryTabContentState extends State<HistoryTabContent>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  DateTime _selectedDate = DateTime.now();
  String _selectedFilter = 'all';

  final List<String> _filters = ['all', 'taken', 'missed', 'skipped', 'side_effect'];
  final Map<String, String> _filterLabels = {
    'all': '전체',
    'taken': '복용함',
    'missed': '누락',
    'skipped': '건너뜀',
    'side_effect': '부작용',
  };

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHistoryHeader(),
            _buildDateSelector(),
            _buildFilterTabs(),
            Expanded(child: _buildHistoryContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '복약 기록',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _showStatistics,
                icon: Icon(Icons.analytics, color: AppColors.primary),
              ),
              IconButton(
                onPressed: _exportHistory,
                icon: Icon(Icons.file_download, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  _filterLabels[filter] ?? filter,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const Center(
        child: Text('복약 기록 목록 표시 영역'),
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _showStatistics() {
    // 통계 페이지로 이동
    Navigator.pushNamed(context, '/statistics');
  }

  void _exportHistory() {
    // 기록 내보내기 기능
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('기록을 내보내는 중...')),
    );
  }
}
