
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yakunstructuretest/core/constants/app_colors.dart';
import 'package:yakunstructuretest/presentation/providers/auth_provider.dart';
import 'package:yakunstructuretest/presentation/providers/medication_provider.dart';

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
              Text(
                '안녕하세요',
                style: AppTextStyles.subtitle,
              ),
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
              IconButton(
                onPressed: () => _showBasicInfoSheet(),
                icon: Icon(Icons.settings, color: AppColors.primary),
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
          colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.15)],
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
            builder: (context, provider, _) => _buildTodayMedicationStatus(provider),
          ),

          SizedBox(height: 16),

          // 빠른 액션 버튼들
          Row(
            children: [
              Expanded(child: _buildQuickActionButton('그룹 등록', Icons.group_add, Colors.green, '/medication-group')),
              SizedBox(width: 12),
              Expanded(child: _buildQuickActionButton('사이클 등록', Icons.schedule, Colors.blue, '/medication-cycle')),
              SizedBox(width: 12),
              Expanded(child: _buildQuickActionButton('복약 기록', Icons.edit_note, Colors.orange, '/medication-record')),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text('오늘의 복약 현황', style: AppTextStyles.subtitle),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatusCard('복용 완료', todayStatus.taken, Colors.green)),
              Expanded(child: _buildStatusCard('누락', todayStatus.missed, Colors.red)),
              Expanded(child: _buildStatusCard('예정', todayStatus.pending, Colors.orange)),
            ],
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: todayStatus.completionRate,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          SizedBox(height: 4),
          Text('${(todayStatus.completionRate * 100).toInt()}% 완료', style: AppTextStyles.caption),
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
              ...notifications.map((notification) => _buildNotificationCard(notification)),
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
            builder: (context, provider, _) => Column(
              children: provider.upcomingSchedules
                  .map((schedule) => _buildScheduleCard(schedule))
                  .toList(),
            ),
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
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon, Color color, String route) {
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
          Expanded(
            child: Text(
              '알림 내용',
              style: AppTextStyles.subtitle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(dynamic schedule) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            schedule['title'] ?? '일정',
            style: AppTextStyles.subtitle,
          ),
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
    );
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
            child: Text(
              '최근 활동이 없습니다',
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }

  void _showBasicInfoSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 200,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text('기본 정보 관리', style: AppTextStyles.titleBold),
            SizedBox(height: 20),
            Text('병원, 질병, 증상 등록 기능', style: AppTextStyles.subtitle),
          ],
        ),
      ),
    );
  }
}

