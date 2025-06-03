// presentation/screens/home/home_screen.dart (API 통합 완료)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yakunstructuretest/core/constants/app_colors.dart';
import 'package:yakunstructuretest/data/models/medication_model.dart';
import 'package:yakunstructuretest/presentation/providers/auth_provider.dart';
import 'package:yakunstructuretest/presentation/providers/enhanced_medication_provider.dart';
import 'package:yakunstructuretest/presentation/providers/medication_provider.dart';
import 'package:yakunstructuretest/presentation/screens/home/BasicInfoScreen.dart';
import 'package:yakunstructuretest/presentation/screens/home/PillGrid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // API에서 오늘의 복약 데이터 로드
      context.read<EnhancedMedicationProvider>().loadTodayMedications();
      context.read<HomeProvider>().loadHomeData();
    });
  }

  // 복약 기록 생성 메서드
  Future<void> _createMedicationRecord(
    List<PillData> medications,
    MedicationRecordAction action,
  ) async {
    final provider = context.read<EnhancedMedicationProvider>();
    
    try {
      // 선택된 약물들에 대해 벌크 기록 생성
      final result = await provider.createBulkMedicationRecords(
        selectedMedications: medications,
        recordType: action.apiValue,
        dosageTime: DateTime.now().toString(),
        notes: action.displayName,
      );

      if (result.success) {
        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.summaryMessage),
            backgroundColor: action.color,
          ),
        );

        // 데이터 새로고침
        await provider.refreshData();
      } else {
        // 실패 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('기록 실패: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류 발생: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildQuickRecordButton(
    String label,
    IconData icon,
    Color color,
    MedicationRecordAction action,
  ) {
    return GestureDetector(
      onTap: () async {
        final selectedMedications = context.read<EnhancedMedicationProvider>().selectedMedications;
        
        if (selectedMedications.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('선택된 약물이 없습니다.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await _createMedicationRecord(selectedMedications.toList(), action);
        
        // 선택 초기화
        context.read<EnhancedMedicationProvider>().clearSelection();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              context.read<EnhancedMedicationProvider>().refreshData(),
              context.read<HomeProvider>().refreshHomeData(),
            ]);
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(),
                _buildMainActionSection(),
                _buildUrgentNotifications(),
                _buildUpcomingSchedule(),
                _buildRecentActivity(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('안녕하세요', style: AppTextStyles.subtitle),
              Consumer<AuthProvider>(
                builder: (context, auth, _) => Text(
                  '${auth.currentUser?.userName ?? ""}님',
                  style: AppTextStyles.heading,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('다가오는 일정', style: AppTextStyles.titleBold),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/schedule'),
                child: Text('전체보기', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          SizedBox(height: 12),
          Consumer<HomeProvider>(
            builder: (context, provider, _) {
              if (provider.upcomingSchedules == null ||
                  provider.upcomingSchedules.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '다가오는 일정이 없습니다',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                );
              }
              return Column(
                children: provider.upcomingSchedules
                    .map((schedule) => _buildScheduleCard(schedule))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
      String title,
      IconData icon,
      Color color,
      String route,
      ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(dynamic notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange),
          SizedBox(width: 12),
          Expanded(child: Text('알림 내용', style: AppTextStyles.subtitle)),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleItem schedule) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScheduleHeader(schedule),
            if (schedule.progress != null) ...[
              SizedBox(height: 8),
              _buildProgressBar(schedule.progress!),
            ],
            SizedBox(height: 12),
            Divider(thickness: 1, height: 1),
            SizedBox(height: 12),
            _buildScheduleContent(schedule),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleContent(dynamic item) {
    switch (item.type) {
      case ScheduleType.medication:
        return _buildMedicationContent(item);
      case ScheduleType.hospital:
        return _buildHospitalContent(item);
      case ScheduleType.prescription:
        return _buildPrescriptionContent(item);
      default:
        return _buildDefaultContent(item);
    }
  }

  Widget _buildHospitalContent(dynamic item) {
    final department = item.additionalData?['department'] ?? '';
    final doctor = item.additionalData?['doctor'] ?? '';
    final appointmentTime = item.additionalData?['appointmentTime'] ?? '';

    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(
            Icons.local_hospital,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (department.isNotEmpty)
                Text(
                  department,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              if (doctor.isNotEmpty)
                Text(
                  "$doctor 교수",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              if (appointmentTime.isNotEmpty)
                Text(
                  "예약시간: $appointmentTime",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrescriptionContent(dynamic item) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(Icons.receipt_long, color: Colors.orange, size: 28),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "처방전 만료 예정",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Text(
                "미리 예약을 진행해주세요",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // 예약 페이지로 이동
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text("예약하기", style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildDefaultContent(dynamic item) {
    return Container(
      height: 60,
      child: Center(
        child: Text(
          "일정 정보",
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildMedicationContent(dynamic item) {
    final medications =
        item.additionalData?['medications'] as List<MedicationModel>? ?? [];
    final cycleNumber = item.additionalData?['cycleNumber'] ?? 0;
    final remainingDays = item.additionalData?['remainingDays'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "사이클 $cycleNumber",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            Text(
              "잔여 ${remainingDays}일",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          height: 120,
          child: medications.isNotEmpty
              ? _buildMedicationList(medications)
              : _buildPlaceholderMedicationList(),
        ),
      ],
    );
  }

  Widget _buildMedicationList(List<MedicationModel> medications) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: medications.length,
      itemBuilder: (context, index) {
        final medication = medications[index];
        return Container(
          width: 100,
          margin: EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.medication, color: Colors.green, size: 24),
              ),
              SizedBox(height: 8),
              Text(
                medication.itemName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              Text(
                medication.dosageForm,
                style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              Text(
                medication.className,
                style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderMedicationList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication_outlined, size: 32, color: Colors.grey[400]),
            SizedBox(height: 8),
            Text(
              "복약 정보 로딩 중...",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return LinearProgressIndicator(
      value: progress,
      minHeight: 8,
      borderRadius: BorderRadius.circular(4),
      backgroundColor: Colors.grey[300],
      valueColor: AlwaysStoppedAnimation<Color>(
        Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildScheduleHeader(ScheduleItem schedule) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schedule.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if (schedule.subtitle.isNotEmpty) ...[
                SizedBox(height: 4),
                Text(
                  schedule.subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ],
          ),
        ),
        Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getDaysRemainingColor(schedule.daysRemaining),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                schedule.daysRemainingText,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(
              DateFormat('yyyy-MM-dd').format(schedule.scheduledDate),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Color _getDaysRemainingColor(int daysRemaining) {
    if (daysRemaining < 0) return Colors.grey;
    if (daysRemaining == 0) return Colors.red;
    if (daysRemaining <= 3) return Colors.orange;
    if (daysRemaining <= 7) return Colors.blue;
    return Colors.green;
  }

  Widget _buildRecentActivity() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('최근 활동', style: AppTextStyles.titleBold),
          SizedBox(height: 12),
          Consumer<EnhancedMedicationProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
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
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              // 최근 활동 데이터가 있다면 표시
              final overallStats = provider.overallStats;
              if (overallStats != null && overallStats.totalMedications > 0) {
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActivityStat(
                            '총 복약',
                            overallStats.totalMedications,
                            Icons.medication,
                            AppColors.primary,
                          ),
                          _buildActivityStat(
                            '완료',
                            overallStats.totalTaken,
                            Icons.check_circle,
                            Colors.green,
                          ),
                          _buildActivityStat(
                            '누락',
                            overallStats.totalMissed,
                            Icons.cancel,
                            Colors.red,
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: overallStats.overallCompletionRate,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        minHeight: 6,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '전체 순응도: ${(overallStats.overallCompletionRate * 100).toInt()}%',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                );
              }

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
                child: Text('최근 활동이 없습니다', style: AppTextStyles.caption),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStat(String label, int value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showBasicInfoSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BasicInfoScreen(),
    );
  }

  Widget _buildMainActionSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.medication, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('복약 관리', style: AppTextStyles.titleBold),
                  Text('오늘의 복용 현황을 확인하세요', style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          // API 통합된 오늘의 복약 현황
          Consumer<EnhancedMedicationProvider>(
            builder: (context, provider, _) => _buildTodayMedicationStatus(provider),
          ),
          SizedBox(height: 16),
          // 빠른 액션 버튼들
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  '처방전 갱신',
                  Icons.published_with_changes_outlined,
                  Colors.green,
                  '/prescription-renewal',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  '새로운 주기 등록',
                  Icons.new_label_outlined,
                  Colors.blue,
                  '/medication-cycle',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  '복약 상세 기록',
                  Icons.add_chart,
                  Colors.orange,
                  '/medication-detail',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayMedicationStatus(EnhancedMedicationProvider provider) {
    if (provider.isLoading) {
      return _buildLoadingMedicationStatus();
    }

    if (provider.errorMessage != null) {
      return _buildErrorMedicationStatus(provider.errorMessage!);
    }

    if (provider.medicationGroups.isEmpty) {
      return _buildEmptyMedicationStatus();
    }

    // 첫 번째 복약그룹의 첫 번째 시간대 데이터 가져오기
    final firstGroup = provider.medicationGroups.first;
    final firstTimeData = provider.getFirstDosageTimeData(firstGroup);

    if (firstTimeData == null) {
      return _buildEmptyMedicationStatus();
    }

    final todayStatus = provider.todayMedicationStatus;

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
          Text(
            '${firstTimeData.groupName} - ${firstTimeData.dosageTimeDisplayName}',
            style: AppTextStyles.subtitle,
          ),
          SizedBox(height: 12),

          // 복약 그리드
          MedicationGridWidget(
            groupId: firstTimeData.groupId,
            cycleId: firstGroup.cycleId,
            dosagePattern: firstTimeData.dosageTime,
            medications: firstTimeData.pillDataList,
            columnsPerRow: 6,
          ),

          SizedBox(height: 16),

          // 복약 기록 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickRecordButton(
                '복용함',
                Icons.check_circle,
                const Color(0xFF28A745),
                MedicationRecordAction.taken,
              ),
              _buildQuickRecordButton(
                '누락',
                Icons.cancel,
                const Color(0xFFDC3545),
                MedicationRecordAction.missed,
              ),
              _buildQuickRecordButton(
                '건너뜀',
                Icons.skip_next,
                const Color(0xFFFFC107),
                MedicationRecordAction.skipped,
              ),
              _buildQuickRecordButton(
                '부작용',
                Icons.warning,
                const Color(0xFFFF6B35),
                MedicationRecordAction.sideEffect,
              ),
            ],
          ),

          SizedBox(height: 16),

          // 진행률 표시
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: LinearProgressIndicator(
                    value: todayStatus.completionRate,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    minHeight: 8,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${(todayStatus.completionRate * 100).toInt()}%',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          // 통계 요약
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusChip('복용', todayStatus.taken, Colors.green),
              _buildStatusChip('누락', todayStatus.missed, Colors.red),
              _buildStatusChip('대기', todayStatus.pending, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMedicationStatus() {
    return Container(
      padding: EdgeInsets.all(32),
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
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('복약 정보를 불러오는 중...', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMedicationStatus(String error) {
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
          Icon(Icons.error_outline, color: Colors.red, size: 48),
          SizedBox(height: 12),
          Text('데이터 로드 실패', style: AppTextStyles.titleBold),
          SizedBox(height: 8),
          Text(error, style: AppTextStyles.caption, textAlign: TextAlign.center),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              context.read<EnhancedMedicationProvider>().refreshData();
            },
            child: Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMedicationStatus() {
    return Container(
      padding: EdgeInsets.all(32),
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
      child: Center(
        child: Column(
          children: [
            Icon(Icons.medication_outlined, color: Colors.grey[400], size: 48),
            SizedBox(height: 16),
            Text('등록된 복약 정보가 없습니다', style: AppTextStyles.caption),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/medication-setup');
              },
              child: Text('복약 등록하기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: 6),
          Text(
            '$label $count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentNotifications() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        final notifications = provider.urgentNotifications;
        if (notifications.isEmpty) return SizedBox.shrink();

        return Container(
          margin: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('긴급 알림', style: AppTextStyles.titleBold),
              SizedBox(height: 12),
              ...notifications.map(
                (notification) => Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (notification.message != null) ...[
                              SizedBox(height: 4),
                              Text(
                                notification.message!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpcomingSchedule() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('다가오는 일정', style: AppTextStyles.titleBold),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/schedule'),
                child: Text('전체보기', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          SizedBox(height: 12),
          Consumer<HomeProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (provider.errorMessage != null) {
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }

              final schedules = provider.upcomingSchedules;
              if (schedules == null || schedules.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '다가오는 일정이 없습니다',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                );
              }

              return Column(
                children: schedules.map((schedule) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              schedule.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getScheduleTypeColor(schedule.type),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getScheduleTypeText(schedule.type),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          DateFormat('yyyy년 MM월 dd일 HH:mm').format(schedule.scheduledDate),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        if (schedule.description != null) ...[
                          SizedBox(height: 8),
                          Text(
                            schedule.description!,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getScheduleTypeColor(ScheduleType type) {
    switch (type) {
      case ScheduleType.medication:
        return Colors.blue;
      case ScheduleType.hospital:
        return Colors.green;
      case ScheduleType.prescription:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getScheduleTypeText(ScheduleType type) {
    switch (type) {
      case ScheduleType.medication:
        return '복약';
      case ScheduleType.hospital:
        return '병원';
      case ScheduleType.prescription:
        return '처방';
      default:
        return '기타';
    }
  }
}
