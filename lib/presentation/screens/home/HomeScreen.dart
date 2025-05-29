import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yakunstructuretest/core/constants/app_colors.dart';
import 'package:yakunstructuretest/data/models/medication_model.dart';
import 'package:yakunstructuretest/presentation/providers/auth_provider.dart';
import 'package:yakunstructuretest/presentation/providers/medication_provider.dart';
import 'package:yakunstructuretest/presentation/screens/home/BasicInfoScreen.dart';

// 홈 화면 메인
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
      context.read<HomeProvider>().loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<HomeProvider>().refreshHomeData();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // 상단 헤더
                _buildHeader(),

                // 메인 액션 섹션 (복약 관리 강조)
                _buildMainActionSection(),

                // 긴급 알림 섹션
                _buildUrgentNotifications(),

                // 다가오는 일정 섹션
                _buildUpcomingSchedule(),

                // 최근 활동 섹션
                //_buildRecentActivity(),
                _showStatisticSheet(),
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
            children: [
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/search'),
                icon: Icon(Icons.search, color: AppColors.primary),
              ),
              GestureDetector(
                onTap: () => _showBasicInfoSheet(),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.settings, size: 16, color: Color(0xFF7B68EE)),
                      SizedBox(width: 4),
                      Text(
                        '기본정보',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7B68EE),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
          SizedBox(height: 20),

          // 오늘의 복약 현황
          Consumer<MedicationProvider>(
            builder: (context, provider, _) =>
                _buildTodayMedicationStatus(provider),
          ),

          SizedBox(height: 16),

          // 빠른 액션 버튼들
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  '그룹 등록',
                  Icons.group_add,
                  Colors.green,
                  '/medication-group',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  '사이클 등록',
                  Icons.schedule,
                  Colors.blue,
                  '/medication-cycle',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  '복약 기록',
                  Icons.edit_note,
                  Colors.orange,
                  '/medication-record',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayMedicationStatus(MedicationProvider provider) {
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
          Text('오늘의 복약 현황', style: AppTextStyles.subtitle),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  '복용 완료',
                  todayStatus.taken,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatusCard('누락', todayStatus.missed, Colors.red),
              ),
              Expanded(
                child: _buildStatusCard(
                  '예정',
                  todayStatus.pending,
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: todayStatus.completionRate,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          SizedBox(height: 4),
          Text(
            '${(todayStatus.completionRate * 100).toInt()}% 완료',
            style: AppTextStyles.caption,
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
                (notification) => _buildNotificationCard(notification),
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
              // HomeProvider가 없거나 upcomingSchedules가 null인 경우 처리
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

  // 누락된 메서드들 추가
  Widget _buildStatusCard(String title, int count, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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

  Widget _buildScheduleCard(dynamic schedule) {
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
            if (schedule != null &&
                schedule is Map &&
                schedule.containsKey('progress') &&
                schedule['progress'] != null) ...[
              SizedBox(height: 8),
              _buildProgressBar(schedule['progress'].toDouble()),
            ],
            SizedBox(height: 12),
            Divider(thickness: 1, height: 1),
            SizedBox(height: 12),
            _buildScheduleContent(schedule),
            Text(schedule['title'] ?? '일정', style: AppTextStyles.subtitle),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                schedule['date'] ?? '',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
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

  Widget _buildScheduleHeader(dynamic schedule) {
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
          Container(
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
          ),
        ],
      ),
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

  Widget _showStatisticSheet() {
    return Container(
      child: _buildQuickActionButton(
        '처방 통계',
        Icons.baby_changing_station,
        Colors.orange,
        '/statistics',
      ),
    );
  }
}
