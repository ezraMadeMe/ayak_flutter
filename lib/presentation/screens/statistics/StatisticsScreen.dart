
// ===== 2. 통계 화면 (Statistics Screen) =====

import 'package:flutter/material.dart';
import 'package:yakunstructuretest/core/constants/app_colors.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _selectedDateRange;
  String? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(Duration(days: 90)),
      end: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('복약 통계'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '개요'),
            Tab(text: '처방 변화'),
            Tab(text: '복용 패턴'),
            Tab(text: '상세 분석'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showFilterOptions,
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // 필터 섹션
          _buildFilterSection(),

          // 탭 내용
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildPrescriptionChangesTab(),
                _buildMedicationPatternsTab(),
                _buildDetailedAnalysisTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('분석 기간 및 그룹 선택', style: AppTextStyles.subtitle),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateRangeSelector(),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildGroupSelector(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider, _) => SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 주요 지표 카드들
            _buildKeyMetricsCards(provider),
            SizedBox(height: 16),

            // 처방 변화 요약 차트
            _buildPrescriptionChangesSummaryChart(provider),
            SizedBox(height: 16),

            // 복용 준수율 차트
            _buildAdherenceChart(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionChangesTab() {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider, _) => SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 처방 변화 타임라인
            _buildPrescriptionTimeline(provider),
            SizedBox(height: 16),

            // 용량 변화 차트
            _buildDosageChangesChart(provider),
            SizedBox(height: 16),

            // 약물별 변화 분석
            _buildMedicationChangesAnalysis(provider),
          ],
        ),
      ),
    );
  }
}
