import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yakunstructuretest/core/constants/app_colors.dart';
import 'package:yakunstructuretest/data/models/medication_detail_model.dart';
import 'package:yakunstructuretest/data/models/medication_model.dart';
import 'package:yakunstructuretest/data/models/medication_record_model.dart';
import 'package:yakunstructuretest/presentation/providers/analytics_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _selectedDateRange;
  String? _selectedGroupId;
  String _analysisType = 'medication';
  Map<String, bool> _selectedMedications = {};

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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('분석 기간 및 그룹 선택', style: AppTextStyles.subtitle),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDateRangeSelector()),
              SizedBox(width: 12),
              Expanded(child: _buildGroupSelector()),
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
            // 처방 변화 타임라인
            _buildPrescriptionTimeline(provider),
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
        child: _buildDosageChangesChart(provider),
      ),
    );
  }

  // 1. 필터 옵션 모달 표시
  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('필터 옵션', style: AppTextStyles.titleBold),
            SizedBox(height: 20),
            Text('분석 기간', style: AppTextStyles.subtitle),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDateRange(),
                    child: Text(
                      _selectedDateRange != null
                          ? '${_selectedDateRange!.start.month}/${_selectedDateRange!.start.day} - ${_selectedDateRange!.end.month}/${_selectedDateRange!.end.day}'
                          : '기간 선택',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('복약 그룹', style: AppTextStyles.subtitle),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedGroupId,
              hint: Text('그룹 선택'),
              isExpanded: true,
              items: [
                DropdownMenuItem(value: null, child: Text('전체 그룹')),
                DropdownMenuItem(value: 'group1', child: Text('정신과 약물 그룹')),
                DropdownMenuItem(value: 'group2', child: Text('내과 약물 그룹')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGroupId = value;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 날짜 범위 선택
  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  // 2. 날짜 범위 선택기
  Widget _buildDateRangeSelector() {
    return GestureDetector(
      onTap: _selectDateRange,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.date_range, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedDateRange != null
                    ? '${_selectedDateRange!.start.month}/${_selectedDateRange!.start.day} - ${_selectedDateRange!.end.month}/${_selectedDateRange!.end.day}'
                    : '기간 선택',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. 그룹 선택기
  Widget _buildGroupSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _selectedGroupId,
        hint: Text('그룹 선택', style: TextStyle(fontSize: 14)),
        isExpanded: true,
        underline: SizedBox(),
        items: [
          DropdownMenuItem(value: null, child: Text('전체 그룹')),
          DropdownMenuItem(value: 'group1', child: Text('정신과 약물')),
          DropdownMenuItem(value: 'group2', child: Text('내과 약물')),
        ],
        onChanged: (value) {
          setState(() {
            _selectedGroupId = value;
          });
        },
      ),
    );
  }

  // 4. 주요 지표 카드들
  Widget _buildKeyMetricsCards(AnalyticsProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                '총 처방 수',
                '24회',
                Colors.blue,
                Icons.medical_services,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                '활성 약물',
                '5개',
                Colors.green,
                Icons.medication,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                '복용 준수율',
                '85%',
                Colors.orange,
                Icons.check_circle,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                '부작용 기록',
                '2건',
                Colors.red,
                Icons.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // 5. 처방 변화 요약 차트
  Widget _buildPrescriptionChangesSummaryChart(AnalyticsProvider provider) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('처방 변화 요약', style: AppTextStyles.titleBold),
          SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildChangeBar('증량', 3, Colors.blue)),
                SizedBox(width: 8),
                Expanded(child: _buildChangeBar('감량', 2, Colors.orange)),
                SizedBox(width: 8),
                Expanded(child: _buildChangeBar('신규', 1, Colors.green)),
                SizedBox(width: 8),
                Expanded(child: _buildChangeBar('중단', 1, Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeBar(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: (count / 5) * 100,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  // 6. 복용 준수율 차트
  Widget _buildAdherenceChart(AnalyticsProvider provider) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('복용 준수율 추이', style: AppTextStyles.titleBold),
          SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              child: CustomPaint(painter: AdherenceChartPainter()),
            ),
          ),
        ],
      ),
    );
  }

  // 7. 처방 변화 타임라인
  Widget _buildPrescriptionTimeline(AnalyticsProvider provider) {
    final changes = [
      {
        'date': '2024-06-01',
        'type': '증량',
        'medication': '제프람',
        'change': '10mg → 20mg',
      },
      {
        'date': '2024-07-01',
        'type': '감량',
        'medication': '알프람',
        'change': '0.5mg → 0.25mg',
      },
      {
        'date': '2024-08-01',
        'type': '신규',
        'medication': '부스피론',
        'change': '5mg 추가',
      },
    ];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('처방 변화 타임라인', style: AppTextStyles.titleBold),
          SizedBox(height: 16),
          ...changes.map((change) => _buildTimelineItem(change)).toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, String> change) {
    Color getTypeColor(String type) {
      switch (type) {
        case '증량':
          return Colors.blue;
        case '감량':
          return Colors.orange;
        case '신규':
          return Colors.green;
        case '중단':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.fromBorderSide(
          BorderSide(color: getTypeColor(change['type']!), width: 4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: getTypeColor(change['type']!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              change['type']!,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(change['medication']!, style: AppTextStyles.subtitle),
                Text(
                  change['change']!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            change['date']!,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTypeSelector() {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _analysisType = 'medication'),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: _analysisType == 'medication'
                              ? Colors.blue[600]
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '약물명별',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _analysisType == 'medication'
                                ? Colors.white
                                : Colors.grey[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _analysisType = 'ingredient'),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: _analysisType == 'ingredient'
                              ? Colors.blue[600]
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '주성분별',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _analysisType == 'ingredient'
                                ? Colors.white
                                : Colors.grey[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<MedicationRecordModel> _getSampleData() {
    return [
      // 1월 1주차 - 리튬 (기분안정제)
      MedicationRecordModel(
        id: 1,
        cycleId: 101,
        medicationDetail: MedicationDetailModel(
          id: 1,
          cycleId: 101,
          medication: MedicationModel(
            itemSeq: 1,
            itemName: "리튬 카보네이트",
            entpName: "기분안정제",
            className: "",
            dosageForm: "",
            isPrescription: true,
            createdAt: DateTime.timestamp(),
            updatedAt: DateTime.timestamp(),
          ),
          dosageInterval: "매일",
          frequencyPerInterval: 2,
          quantityPerDose: 300.0,
          totalPrescribed: 60,
          remainingQuantity: 58,
          unit: "mg",
          specialInstructions: "식후 복용, 충분한 수분 섭취",
          createdAt: DateTime(2024, 1, 5, 9, 0),
          updatedAt: DateTime(2024, 1, 5, 9, 0),
        ),
        recordType: "복용",
        recordDate: DateTime(2024, 1, 6, 9, 0),
        quantityTaken: 300.0,
        notes: "기분안정제 복용 시작",
        symptoms: "조증 증상 약간 있음",
        createdAt: DateTime(2024, 1, 6, 9, 5),
        updatedAt: DateTime(2024, 1, 6, 9, 5),
      ),

      // 1월 1주차 - 로라제팜 (항불안제)
      MedicationRecordModel(
        id: 2,
        cycleId: 102,
        medicationDetail: MedicationDetailModel(
          id: 2,
          cycleId: 102,
          medication: MedicationModel(
            itemSeq: 2,
            itemName: "로라제팜",
            entpName: "항불안제",
            className: "",
            dosageForm: "",
            isPrescription: true,
            createdAt: DateTime.timestamp(),
            updatedAt: DateTime.timestamp(),
          ),
          dosageInterval: "필요시",
          frequencyPerInterval: 3,
          quantityPerDose: 0.5,
          totalPrescribed: 30,
          remainingQuantity: 29,
          unit: "mg",
          specialInstructions: "심한 불안감시에만 복용, 하루 최대 3회",
          createdAt: DateTime(2024, 1, 5, 9, 0),
          updatedAt: DateTime(2024, 1, 5, 9, 0),
        ),
        recordType: "복용",
        recordDate: DateTime(2024, 1, 7, 14, 30),
        quantityTaken: 0.5,
        notes: "공황발작 증상으로 응급 복용",
        symptoms: "심한 불안감, 숨가쁨",
        createdAt: DateTime(2024, 1, 7, 14, 35),
        updatedAt: DateTime(2024, 1, 7, 14, 35),
      ),

      // 1월 2주차 - 쿠에티아핀 추가 (항정신병약)
      MedicationRecordModel(
        id: 3,
        cycleId: 103,
        medicationDetail: MedicationDetailModel(
          id: 3,
          cycleId: 103,
          medication: MedicationModel(
            itemSeq: 3,
            itemName: "쿠에티아핀",
            entpName: "항정신병약",
            className: "",
            dosageForm: "",
            isPrescription: true,
            createdAt: DateTime.timestamp(),
            updatedAt: DateTime.timestamp(),
          ),
          dosageInterval: "매일",
          frequencyPerInterval: 1,
          quantityPerDose: 25.0,
          totalPrescribed: 28,
          remainingQuantity: 27,
          unit: "mg",
          specialInstructions: "취침 전 복용, 졸음 유발 가능",
          createdAt: DateTime(2024, 1, 12, 10, 0),
          updatedAt: DateTime(2024, 1, 12, 10, 0),
        ),
        recordType: "복용",
        recordDate: DateTime(2024, 1, 13, 22, 0),
        quantityTaken: 25.0,
        notes: "수면장애 및 조증 조절 목적으로 추가",
        symptoms: "잠들기 어려움, 기분 변화",
        createdAt: DateTime(2024, 1, 13, 22, 5),
        updatedAt: DateTime(2024, 1, 13, 22, 5),
      ),

      // 1월 3주차 - 리튬 복용 기록
      MedicationRecordModel(
        id: 4,
        cycleId: 101,
        medicationDetail: MedicationDetailModel(
          id: 1,
          cycleId: 101,
          medication: MedicationModel(
            itemSeq: 1,
            itemName: "리튬 카보네이트",
            entpName: "기분안정제",
            className: "",
            dosageForm: "",
            isPrescription: true,
            createdAt: DateTime.timestamp(),
            updatedAt: DateTime.timestamp(),
          ),
          dosageInterval: "매일",
          frequencyPerInterval: 2,
          quantityPerDose: 300.0,
          totalPrescribed: 60,
          remainingQuantity: 42,
          unit: "mg",
          specialInstructions: "식후 복용, 충분한 수분 섭취",
          createdAt: DateTime(2024, 1, 5, 9, 0),
          updatedAt: DateTime(2024, 1, 20, 9, 0),
        ),
        recordType: "복용",
        recordDate: DateTime(2024, 1, 20, 9, 0),
        quantityTaken: 300.0,
        notes: "기분안정제 정규 복용 중",
        symptoms: "기분 안정화되고 있음",
        createdAt: DateTime(2024, 1, 20, 9, 5),
        updatedAt: DateTime(2024, 1, 20, 9, 5),
      ),

      // ============ 2월 처방 변경 (메틸페니데이트 추가) ============

      // 2월 1주차 - 메틸페니데이트 추가 (ADHD 치료)
      MedicationRecordModel(
        id: 5,
        cycleId: 104,
        medicationDetail: MedicationDetailModel(
          id: 4,
          cycleId: 104,
          medication: MedicationModel(
            itemSeq: 3,
            itemName: "메틸페니데이트",
            entpName: "ADHD치료제",
            className: "",
            dosageForm: "",
            isPrescription: true,
            createdAt: DateTime.timestamp(),
            updatedAt: DateTime.timestamp(),
          ),
          dosageInterval: "매일",
          frequencyPerInterval: 2,
          quantityPerDose: 10.0,
          totalPrescribed: 60,
          remainingQuantity: 59,
          unit: "mg",
          specialInstructions: "아침, 점심 식후 복용, 오후 4시 이후 금지",
          createdAt: DateTime(2024, 2, 3, 11, 0),
          updatedAt: DateTime(2024, 2, 3, 11, 0),
        ),
        recordType: "복용",
        recordDate: DateTime(2024, 2, 4, 8, 30),
        quantityTaken: 10.0,
        notes: "ADHD 증상 치료를 위해 새로 추가",
        symptoms: "집중력 부족, 과잉행동",
        createdAt: DateTime(2024, 2, 4, 8, 35),
        updatedAt: DateTime(2024, 2, 4, 8, 35),
      ),

      // 2월 2주차 - 쿠에티아핀 용량 증량
      MedicationRecordModel(
        id: 6,
        cycleId: 105,
        medicationDetail: MedicationDetailModel(
          id: 5,
          cycleId: 105,
          medication: MedicationModel(
            itemSeq: 3,
            itemName: "쿠에티아핀",
            entpName: "항정신병약",
            className: "",
            dosageForm: "",
            isPrescription: true,
            createdAt: DateTime.timestamp(),
            updatedAt: DateTime.timestamp(),
          ),
          dosageInterval: "매일",
          frequencyPerInterval: 1,
          quantityPerDose: 50.0,
          totalPrescribed: 28,
          remainingQuantity: 27,
          unit: "mg",
          specialInstructions: "취침 전 복용, 용량 증가로 인한 졸음 주의",
          createdAt: DateTime(2024, 2, 10, 10, 30),
          updatedAt: DateTime(2024, 2, 10, 10, 30),
        ),
        recordType: "복용",
        recordDate: DateTime(2024, 2, 11, 22, 0),
        quantityTaken: 50.0,
        notes: "용량 25mg에서 50mg로 증량",
        symptoms: "수면 패턴 개선 필요",
        createdAt: DateTime(2024, 2, 11, 22, 5),
        updatedAt: DateTime(2024, 2, 11, 22, 5),
      ),

      // 2월 3주차 - 메틸페니데이트 효과 확인
      MedicationRecordModel(
        id: 7,
        cycleId: 104,
        medicationDetail: MedicationDetailModel(
          id: 4,
          cycleId: 104,
          medication: MedicationModel(
            itemSeq: 3,
            itemName: "메틸페니데이트",
            entpName: "ADHD치료제",
            className: "",
            dosageForm: "",
            isPrescription: true,
            createdAt: DateTime.timestamp(),
            updatedAt: DateTime.timestamp(),
          ),
          dosageInterval: "매일",
          frequencyPerInterval: 2,
          quantityPerDose: 10.0,
          totalPrescribed: 60,
          remainingQuantity: 45,
          unit: "mg",
          specialInstructions: "아침, 점심 식후 복용, 오후 4시 이후 금지",
          createdAt: DateTime(2024, 2, 3, 11, 0),
          updatedAt: DateTime(2024, 2, 18, 11, 0),
        ),
        recordType: "복용",
        recordDate: DateTime(2024, 2, 18, 12, 30),
        quantityTaken: 10.0,
        notes: "집중력 개선 효과 있음",
        symptoms: "집중력 향상, 식욕 감소",
        createdAt: DateTime(2024, 2, 18, 12, 35),
        updatedAt: DateTime(2024, 2, 18, 12, 35),
      ),

      // ============ 3월 처방 조정 (세르트랄린 추가, 로라제팜 용량 조정) ============

      // 3월 1주차 - 세르트랄린 추가 (항우울제)
      MedicationRecordModel(
        id: 8,
        cycleId: 106,
        medicationDetail: MedicationDetailModel(
          id: 6,
          cycleId: 106,
          medication: MedicationModel(
            itemSeq: 3,
            itemName: "세르트랄린",
            entpName: "항우울제",
            className: "",
            dosageForm: "",
            isPrescription: true,
            createdAt: DateTime.timestamp(),
            updatedAt: DateTime.timestamp(),
          ),
          dosageInterval: "매일",
          frequencyPerInterval: 1,
          quantityPerDose: 25.0,
          totalPrescribed: 28,
          remainingQuantity: 27,
          unit: "mg",
          specialInstructions: "아침 식후 복용, 우울 증상 개선 목적",
          createdAt: DateTime(2024, 3, 2, 9, 15),
          updatedAt: DateTime(2024, 3, 2, 9, 15),
        ),
        recordType: "복용",
        recordDate: DateTime(2024, 3, 3, 9, 0),
        quantityTaken: 25.0,
        notes: "우울 증상 악화로 항우울제 추가",
        symptoms: "우울감 심화, 의욕 저하",
        createdAt: DateTime(2024, 3, 3, 9, 5),
        updatedAt: DateTime(2024, 3, 3, 9, 5),
      ),

      // 3월 2주차 - 로라제팜 용량 감소
      MedicationRecordModel(
        id: 9,
        cycleId: 107,
        medicationDetail: MedicationDetailModel(
          id: 7,
          cycleId: 107,
          medication: MedicationModel(
            itemSeq: 3,
            itemName: "올란자핀",
            entpName: "항정신병약",
            className: "",
            dosageForm: "",
            isPrescription: true,
            createdAt: DateTime.timestamp(),
            updatedAt: DateTime.timestamp(),
          ),
          dosageInterval: "필요시",
          frequencyPerInterval: 2,
          quantityPerDose: 0.25,
          totalPrescribed: 20,
          remainingQuantity: 19,
          unit: "mg",
          specialInstructions: "의존성 방지를 위해 용량 감소, 필요시에만",
          createdAt: DateTime(2024, 3, 9, 14, 0),
          updatedAt: DateTime(2024, 3, 9, 14, 0),
        ),
        recordType: "복용",
        recordDate: DateTime(2024, 3, 12, 16, 0),
        quantityTaken: 0.25,
        notes: "용량 0.5mg에서 0.25mg로 감량",
        symptoms: "불안감 조절됨",
        createdAt: DateTime(2024, 3, 12, 16, 5),
        updatedAt: DateTime(2024, 3, 12, 16, 5),
      ),

      // 3월 3주차 - 메틸페니데이트 용량 증량
      MedicationRecordModel(
        id: 10,
        cycleId: 108,
        medicationDetail: MedicationDetailModel(
          id: 8,
          cycleId: 108,
          medication: MedicationModel(
            itemSeq: 3,
            itemName: "메틸페니데이트",
            entpName: "ADHD치료제",
            className: "",
            dosageForm: "",
            isPrescription: true,
            createdAt: DateTime.timestamp(),
            updatedAt: DateTime.timestamp(),
          ),
          dosageInterval: "매일",
          frequencyPerInterval: 2,
          quantityPerDose: 15.0,
          totalPrescribed: 60,
          remainingQuantity: 59,
          unit: "mg",
          specialInstructions: "용량 증량, 부작용 관찰 필요",
          createdAt: DateTime(2024, 3, 16, 10, 30),
          updatedAt: DateTime(2024, 3, 16, 10, 30),
        ),
        recordType: "복용",
        recordDate: DateTime(2024, 3, 17, 8, 30),
        quantityTaken: 15.0,
        notes: "ADHD 증상 조절 위해 10mg에서 15mg로 증량",
        symptoms: "집중력 더 향상됨, 심박수 약간 증가",
        createdAt: DateTime(2024, 3, 17, 8, 35),
        updatedAt: DateTime(2024, 3, 17, 8, 35),
      ),

      // 3월 4주차 - 세르트랄린 용량 증량
      MedicationRecordModel(
        id: 11,
        cycleId: 109,
        medicationDetail: MedicationDetailModel(
          id: 9,
          cycleId: 109,
          medication: MedicationModel(
            itemSeq: 3,
            itemName: "세르트랄린",
            entpName: "항우울제",
            className: "",
            dosageForm: "",
            isPrescription: true,
            createdAt: DateTime.timestamp(),
            updatedAt: DateTime.timestamp(),
          ),
          dosageInterval: "매일",
          frequencyPerInterval: 1,
          quantityPerDose: 50.0,
          totalPrescribed: 28,
          remainingQuantity: 27,
          unit: "mg",
          specialInstructions: "용량 증량, 우울 증상 개선 목적",
          createdAt: DateTime(2024, 3, 23, 9, 0),
          updatedAt: DateTime(2024, 3, 23, 9, 0),
        ),
        recordType: "복용",
        recordDate: DateTime(2024, 3, 24, 9, 0),
        quantityTaken: 50.0,
        notes: "항우울제 25mg에서 50mg로 증량",
        symptoms: "우울감 점진적 개선",
        createdAt: DateTime(2024, 3, 24, 9, 5),
        updatedAt: DateTime(2024, 3, 24, 9, 5),
      ),

      // ============ 4월 처방 최종 조정 (올란자핀 추가, 로라제팜 중단) ============

      // 4월 1주차 - 올란자핀 추가 (항정신병약)
      MedicationRecordModel(
        id: 12,
        cycleId: 110,
        medicationDetail: MedicationDetailModel(
          id: 10,
          cycleId: 110,
          medication: MedicationModel(
            itemSeq: 3,
            itemName: "올란자핀",
            entpName: "항정신병약",
            className: "",
            dosageForm: "",
            isPrescription: true,
            createdAt: DateTime.timestamp(),
            updatedAt: DateTime.timestamp(),
          ),
          dosageInterval: "매일",
          frequencyPerInterval: 1,
          quantityPerDose: 2.5,
          totalPrescribed: 28,
          remainingQuantity: 27,
          unit: "mg",
          specialInstructions: "취침 전 복용, 체중 증가 주의",
          createdAt: DateTime(2024, 4, 6, 15, 0),
          updatedAt: DateTime(2024, 4, 6, 15, 0),
        ),
        recordType: "복용",
        recordDate: DateTime(2024, 4, 7, 22, 0),
        quantityTaken: 2.5,
        notes: "기분 안정화 및 수면 개선을 위해 추가",
        symptoms: "기분 변화 심함, 수면 불안정",
        createdAt: DateTime(2024, 4, 7, 22, 5),
        updatedAt: DateTime(2024, 4, 7, 22, 5),
      ),

      // 4월 2주차 - 쿠에티아핀 중단
      MedicationRecordModel(
        id: 13,
        cycleId: 105,
        medicationDetail: MedicationDetailModel(
          id: 5,
          cycleId: 105,
          medication: MedicationModel(
            itemSeq: 3,
            itemName: "쿠에티아핀",
            entpName: "항정신병약",
            className: "",
            dosageForm: "",
            isPrescription: true,
            createdAt: DateTime.timestamp(),
            updatedAt: DateTime.timestamp(),
          ),
          dosageInterval: "매일",
          frequencyPerInterval: 1,
          quantityPerDose: 50.0,
          totalPrescribed: 28,
          remainingQuantity: 10,
          unit: "mg",
          specialInstructions: "올란자핀으로 대체하여 점진적 중단",
          createdAt: DateTime(2024, 2, 10, 10, 30),
          updatedAt: DateTime(2024, 4, 14, 10, 30),
        ),
        recordType: "중단",
        recordDate: DateTime(2024, 4, 14, 22, 0),
        quantityTaken: 0.0,
        notes: "올란자핀으로 대체하여 쿠에티아핀 중단",
        symptoms: "올란자핀으로 대체 효과 좋음",
        createdAt: DateTime(2024, 4, 14, 22, 5),
        updatedAt: DateTime(2024, 4, 14, 22, 5),
      ),

      // 4월 3주차 - 리튬 혈중농도 모니터링
      MedicationRecordModel(
        id: 14,
        cycleId: 101,
        medicationDetail: MedicationDetailModel(
          id: 1,
          cycleId: 101,
          medication: MedicationModel(
            itemSeq: 1,
            itemName: "리튬 카보네이트",
            entpName: "기분안정제",
            className: "",
            dosageForm: "",
            isPrescription: true,
            createdAt: DateTime.timestamp(),
            updatedAt: DateTime.timestamp(),
          ),
          dosageInterval: "매일",
          frequencyPerInterval: 2,
          quantityPerDose: 300.0,
          totalPrescribed: 60,
          remainingQuantity: 15,
          unit: "mg",
          specialInstructions: "혈중농도 정기 모니터링 필요",
          createdAt: DateTime(2024, 1, 5, 9, 0),
          updatedAt: DateTime(2024, 4, 21, 9, 0),
        ),
        recordType: "복용",
        recordDate: DateTime(2024, 4, 21, 9, 0),
        quantityTaken: 300.0,
        notes: "혈중농도 검사 결과 적정 수준",
        symptoms: "기분 안정적 유지",
        createdAt: DateTime(2024, 4, 21, 9, 5),
        updatedAt: DateTime(2024, 4, 21, 9, 5),
      ),

      // 4월 4주차 - 최종 처방 상태 확인
      MedicationRecordModel(
        id: 15,
        cycleId: 108,
        medicationDetail: MedicationDetailModel(
          id: 8,
          cycleId: 108,
          medication: MedicationModel(
            itemSeq: 3,
            itemName: "메틸페니데이트",
            entpName: "ADHD치료제",
            className: "",
            dosageForm: "",
            isPrescription: true,
            createdAt: DateTime.timestamp(),
            updatedAt: DateTime.timestamp(),
          ),
          dosageInterval: "매일",
          frequencyPerInterval: 2,
          quantityPerDose: 15.0,
          totalPrescribed: 60,
          remainingQuantity: 30,
          unit: "mg",
          specialInstructions: "현재 용량에서 안정적 유지",
          createdAt: DateTime(2024, 3, 16, 10, 30),
          updatedAt: DateTime(2024, 4, 28, 10, 30),
        ),
        recordType: "복용",
        recordDate: DateTime(2024, 4, 28, 8, 30),
        quantityTaken: 15.0,
        notes: "ADHD 증상 잘 조절됨, 현재 용량 유지",
        symptoms: "집중력 양호, 부작용 최소화",
        createdAt: DateTime(2024, 4, 28, 8, 35),
        updatedAt: DateTime(2024, 4, 28, 8, 35),
      ),
    ];

    // 4월 말 기준 최종 처방 현황:
    // 1. 리튬 카보네이트 300mg 하루 2회 (지속)
    // 2. 세르트랄린 50mg 하루 1회 (용량 증량됨)
    // 3. 메틸페니데이트 15mg 하루 2회 (용량 증량됨)
    // 4. 올란자핀 2.5mg 하루 1회 (새로 추가)
    // 5. 로라제팜 0.25mg 필요시 (용량 감량됨)
    // 중단된 약물: 쿠에티아핀 (올란자핀으로 대체)
  }

  List<String> _getAllMedications() {
    final Set<String> medications = {};
    for (final record in _getSampleData()) {
      final med = record.medicationDetail.medication;

      if (_analysisType == 'ingredient') {
        medications.add('${med.itemName}(${med.className})');
      } else {
        medications.add('${med.itemSeq}(${med.entpName})');
      }
    }
    return medications.toList();
  }

  Widget _buildMedicationSelector() {
    final medications = _getAllMedications();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '분석할 약물 선택',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => setState(() {
                        _selectedMedications = {
                          for (String med in medications) med: true,
                        };
                      }),
                      child: Text('전체선택', style: TextStyle(fontSize: 12)),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _selectedMedications = {
                          for (String med in medications) med: false,
                        };
                      }),
                      child: Text('전체해제', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: medications
                  .map((med) => _buildMedicationChip(med))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationChip(String medication) {
    final isSelected = _selectedMedications[medication] ?? false;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedMedications[medication] = !isSelected;
      }),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[600] : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            SizedBox(width: 6),
            Text(
              medication,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 8. 용량 변화 차트
  Widget _buildDosageChangesChart(AnalyticsProvider provider) {
    return Container(
      height: 600,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('용량 변화 차트', style: AppTextStyles.titleBold),
          SizedBox(height: 16),
          _buildAnalysisTypeSelector(),
          SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              child: CustomPaint(painter: DosageChartPainter()),
            ),
          ),
          SizedBox(height: 16),
          _buildMedicationSelector(),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  // 10. 복용 패턴 탭
  Widget _buildMedicationPatternsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPatternCard('복용 시간 패턴', '오전 8시가 가장 활발', Icons.schedule),
          SizedBox(height: 16),
          _buildPatternCard('요일별 패턴', '주말 복용률이 10% 낮음', Icons.calendar_today),
          SizedBox(height: 16),
          _buildPatternCard('누락 패턴', '저녁 시간대 누락 빈도 높음', Icons.warning),
        ],
      ),
    );
  }

  Widget _buildPatternCard(String title, String description, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleBold),
                SizedBox(height: 4),
                Text(description, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 11. 상세 분석 탭
  Widget _buildDetailedAnalysisTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDetailCard('상관관계 분석', '알프람 사용량과 수면 질 상관관계: 0.67'),
          SizedBox(height: 16),
          _buildDetailCard('예측 분석', '다음 달 복용 준수율 예상: 88%'),
          SizedBox(height: 16),
          _buildDetailCard('권장 사항', '저녁 복용 알림 설정 권장'),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, String content) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleBold),
          SizedBox(height: 8),
          Text(content, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }
}

// 차트 페인터 클래스들
class AdherenceChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final points = [0.7, 0.8, 0.6, 0.9, 0.85, 0.75, 0.8];

    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - (points[i] * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.green);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DosageChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final medications = [
      {
        'name': '제프람',
        'data': [10.0, 15.0, 20.0, 20.0, 15.0],
        'color': Colors.blue,
      },
      {
        'name': '알프람',
        'data': [0.5, 0.5, 0.25, 0.25, 0.25],
        'color': Colors.green,
      },
      {
        'name': '부스피론',
        'data': [0.0, 0.0, 5.0, 10.0, 5.0],
        'color': Colors.orange,
      },
    ];

    for (int medIndex = 0; medIndex < medications.length; medIndex++) {
      final med = medications[medIndex];
      final data = med['data'] as List<double>;
      final color = med['color'] as Color;

      final paint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final path = Path();
      final maxValue = 25.0; // 최대값 설정

      for (int i = 0; i < data.length; i++) {
        final x = (i / (data.length - 1)) * size.width;
        final y = size.height - ((data[i] / maxValue) * size.height);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }

        canvas.drawCircle(Offset(x, y), 3, Paint()..color = color);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
