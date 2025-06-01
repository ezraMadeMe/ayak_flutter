
// 설정 탭 컨텐츠
import 'package:flutter/material.dart';
import 'package:yakunstructuretest/core/constants/app_colors.dart';

class MypageScreen extends StatelessWidget {
  const MypageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '설정',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 24),
              _buildSettingsSection(
                '기본 정보',
                [
                  _buildSettingsItem('개인정보 관리', Icons.person, () {}),
                  _buildSettingsItem('병원 정보', Icons.local_hospital, () {}),
                  _buildSettingsItem('질병 정보', Icons.favorite, () {}),
                ],
              ),
              _buildSettingsSection(
                '알림 설정',
                [
                  _buildSettingsItem('복약 알림', Icons.notifications, () {}),
                  _buildSettingsItem('처방전 갱신 알림', Icons.refresh, () {}),
                  _buildSettingsItem('진료 예약 알림', Icons.schedule, () {}),
                ],
              ),
              _buildSettingsSection(
                '기타',
                [
                  _buildSettingsItem('데이터 백업', Icons.backup, () {}),
                  _buildSettingsItem('앱 정보', Icons.info, () {}),
                  _buildSettingsItem('로그아웃', Icons.logout, () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
          child: Column(children: items),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}