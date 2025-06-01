import 'package:flutter/material.dart';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  _HomeScreen2State createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'AYAK 복약 관리',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F4),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: const Color(0xFF667EEA),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF6C757D),
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: '의료정보'),
                Tab(text: '처방전'),
                Tab(text: '복약관리'),
                Tab(text: '기록'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMedicalInfoTab(),
          _buildPrescriptionTab(),
          _buildMedicationManagementTab(),
          _buildRecordTab(),
        ],
      ),
    );
  }

  // 1. 의료정보 탭 (덜 중요, 저빈도)
  Widget _buildMedicalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            '기본 의료정보',
            '병원과 질병 정보를 등록해주세요',
            Icons.local_hospital,
            const Color(0xFF28A745),
          ),
          const SizedBox(height: 16),

          // 병원 정보 카드
          _buildSimpleInfoCard(
            '병원 정보',
            '담당 병원을 등록하세요',
            Icons.location_on,
            const Color(0xFF17A2B8),
            onTap: () => _showHospitalDialog(),
          ),

          const SizedBox(height: 12),

          // 질병 정보 카드
          _buildSimpleInfoCard(
            '질병 정보',
            '진단받은 질병을 등록하세요',
            Icons.favorite,
            const Color(0xFFDC3545),
            onTap: () => _showIllnessDialog(),
          ),

          const SizedBox(height: 20),

          // 등록된 의료정보 목록
          _buildRegisteredMedicalInfo(),
        ],
      ),
    );
  }

  // 2. 처방전 탭 (중요, 진료시마다 갱신)
  Widget _buildPrescriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            '처방전 관리',
            '병원에서 받은 처방전을 등록해주세요',
            Icons.receipt_long,
            const Color(0xFF6F42C1),
          ),
          const SizedBox(height: 16),

          // 새 처방전 등록
          _buildPrimaryActionCard(
            '새 처방전 등록',
            '병원 방문 후 받은 처방전을 입력하세요',
            Icons.add_circle,
            const Color(0xFF007BFF),
            onTap: () => _showPrescriptionDialog(),
          ),

          const SizedBox(height: 16),

          // 활성 처방전 목록
          _buildActivePrescriptions(),

          const SizedBox(height: 16),

          // 처방전 갱신 버튼
          _buildSecondaryActionCard(
            '처방전 갱신',
            '기존 처방전을 새로운 처방으로 갱신',
            Icons.refresh,
            const Color(0xFF28A745),
            onTap: () => _showPrescriptionUpdateDialog(),
          ),
        ],
      ),
    );
  }

  // 3. 복약관리 탭 (핵심 기능, 사용자 중심)
  Widget _buildMedicationManagementTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            '복약 관리',
            '나만의 복약 스케줄을 설정하세요',
            Icons.schedule,
            const Color(0xFFFF6B35),
          ),
          const SizedBox(height: 16),

          // 복약그룹 관리
          _buildDetailedManagementCard(
            '복약그룹 설정',
            '처방약을 그룹별로 관리하세요',
            '아침약, 저녁약, 혈압약 등으로 분류',
            Icons.group_work,
            const Color(0xFF667EEA),
            onTap: () => _showMedicationGroupDialog(),
          ),

          const SizedBox(height: 12),

          // 복약주기 관리
          _buildDetailedManagementCard(
            '복약주기 관리',
            '새로운 진료 기간을 시작하세요',
            '동일 질병의 새로운 처방 기간 설정',
            Icons.timeline,
            const Color(0xFF20C997),
            onTap: () => _showMedicationCycleDialog(),
          ),

          const SizedBox(height: 12),

          // 복약상세 조정
          _buildDetailedManagementCard(
            '복약상세 조정',
            '개별 약물의 복용량을 조정하세요',
            '의사 지시에 따른 용량 변경',
            Icons.tune,
            const Color(0xFFFD7E14),
            onTap: () => _showMedicationDetailDialog(),
          ),

          const SizedBox(height: 20),

          // 현재 복약 현황
          _buildCurrentMedicationStatus(),
        ],
      ),
    );
  }

  // 4. 기록 탭 (부가 기능)
  Widget _buildRecordTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            '복약 기록',
            '복용 상태를 기록하고 알림을 설정하세요',
            Icons.history,
            const Color(0xFF6C757D),
          ),
          const SizedBox(height: 16),

          // 빠른 복약 기록
          _buildQuickRecordCard(),

          const SizedBox(height: 16),

          // 알림 설정
          _buildSimpleInfoCard(
            '알림 설정',
            '복약 시간 알림을 설정하세요',
            Icons.notifications,
            const Color(0xFFFFC107),
            onTap: () => _showAlertDialog(),
          ),

          const SizedBox(height: 16),

          // 최근 기록
          _buildRecentRecords(),
        ],
      ),
    );
  }

  // 섹션 헤더
  Widget _buildSectionHeader(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 간단한 정보 카드 (의료정보, 기록용)
  Widget _buildSimpleInfoCard(String title, String subtitle, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  // 주요 액션 카드 (처방전용)
  Widget _buildPrimaryActionCard(String title, String subtitle, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.add, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

  // 상세 관리 카드 (복약관리용)
  Widget _buildDetailedManagementCard(String title, String subtitle, String description,
      IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 보조 액션 카드
  Widget _buildSecondaryActionCard(String title, String subtitle, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  // 등록된 의료정보 목록
  Widget _buildRegisteredMedicalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '등록된 의료정보',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: const Column(
            children: [
              _MedicalInfoItem(
                hospital: '서울대학교병원',
                doctor: '김의사',
                illness: '고혈압',
                isActive: true,
              ),
              Divider(),
              _MedicalInfoItem(
                hospital: '서울대학교병원',
                doctor: '김의사',
                illness: '당뇨병',
                isActive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 활성 처방전 목록
  Widget _buildActivePrescriptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '활성 처방전',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: const Column(
            children: [
              _PrescriptionItem(
                prescriptionId: 'PR2025010001',
                date: '2025-01-15',
                medications: ['아스피린', '메트포르민'],
                isActive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 현재 복약 현황
  Widget _buildCurrentMedicationStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '현재 복약 현황',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: const Column(
            children: [
              _MedicationGroupItem(
                groupName: '아침약',
                medications: ['아스피린 100mg', '메트포르민 500mg'],
                nextDose: '08:00',
              ),
              Divider(),
              _MedicationGroupItem(
                groupName: '저녁약',
                medications: ['아스피린 100mg'],
                nextDose: '20:00',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 빠른 복약 기록 카드
  Widget _buildQuickRecordCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '빠른 복약 기록',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickRecordButton('복용함', Icons.check_circle, const Color(0xFF28A745)),
              _buildQuickRecordButton('누락', Icons.cancel, const Color(0xFFDC3545)),
              _buildQuickRecordButton('건너뜀', Icons.skip_next, const Color(0xFFFFC107)),
              _buildQuickRecordButton('부작용', Icons.warning, const Color(0xFFFF6B35)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickRecordButton(String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _recordMedication(label),
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

  // 최근 기록
  Widget _buildRecentRecords() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '최근 기록',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: const Column(
            children: [
              _RecordItem(
                medication: '아스피린 100mg',
                time: '08:00',
                status: '복용함',
                date: '오늘',
              ),
              Divider(),
              _RecordItem(
                medication: '메트포르민 500mg',
                time: '08:00',
                status: '복용함',
                date: '오늘',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 다이얼로그 메서드들
  void _showHospitalDialog() {
    showDialog(
      context: context,
      builder: (context) => _HospitalDialog(),
    );
  }

  void _showIllnessDialog() {
    showDialog(
      context: context,
      builder: (context) => _IllnessDialog(),
    );
  }

  void _showPrescriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => _PrescriptionDialog(),
    );
  }

  void _showPrescriptionUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => _PrescriptionUpdateDialog(),
    );
  }

  void _showMedicationGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => _MedicationGroupDialog(),
    );
  }

  void _showMedicationCycleDialog() {
    showDialog(
      context: context,
      builder: (context) => _MedicationCycleDialog(),
    );
  }

  void _showMedicationDetailDialog() {
    showDialog(
      context: context,
      builder: (context) => _MedicationDetailDialog(),
    );
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (context) => _AlertDialog(),
    );
  }

  void _recordMedication(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('복약 기록: $type'),
        backgroundColor: const Color(0xFF28A745),
      ),
    );
  }
}

// 의료정보 아이템 위젯
class _MedicalInfoItem extends StatelessWidget {
  final String hospital;
  final String doctor;
  final String illness;
  final bool isActive;

  const _MedicalInfoItem({
    required this.hospital,
    required this.doctor,
    required this.illness,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF28A745) : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$hospital - $doctor',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Text(
                illness,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6C757D),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 처방전 아이템 위젯
class _PrescriptionItem extends StatelessWidget {
  final String prescriptionId;
  final String date;
  final List<String> medications;
  final bool isActive;

  const _PrescriptionItem({
    required this.prescriptionId,
    required this.date,
    required this.medications,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF28A745) : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isActive ? '활성' : '비활성',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              prescriptionId,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const Spacer(),
            Text(
              date,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6C757D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '처방약물: ${medications.join(', ')}',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6C757D),
          ),
        ),
      ],
    );
  }
}

// 복약그룹 아이템 위젯
class _MedicationGroupItem extends StatelessWidget {
  final String groupName;
  final List<String> medications;
  final String nextDose;

  const _MedicationGroupItem({
    required this.groupName,
    required this.medications,
    required this.nextDose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              groupName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '다음: $nextDose',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF667EEA),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          medications.join(', '),
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6C757D),
          ),
        ),
      ],
    );
  }
}

// 기록 아이템 위젯
class _RecordItem extends StatelessWidget {
  final String medication;
  final String time;
  final String status;
  final String date;

  const _RecordItem({
    required this.medication,
    required this.time,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status) {
      case '복용함':
        statusColor = const Color(0xFF28A745);
        break;
      case '누락':
        statusColor = const Color(0xFFDC3545);
        break;
      case '건너뜀':
        statusColor = const Color(0xFFFFC107);
        break;
      default:
        statusColor = const Color(0xFF6C757D);
    }

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medication,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Text(
                '$date $time - $status',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6C757D),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 병원 정보 입력 다이얼로그
class _HospitalDialog extends StatefulWidget {
  @override
  _HospitalDialogState createState() => _HospitalDialogState();
}

class _HospitalDialogState extends State<_HospitalDialog> {
  final _hospNameController = TextEditingController();
  final _hospCodeController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedHospType = '종합병원';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.local_hospital, color: const Color(0xFF17A2B8)),
          const SizedBox(width: 8),
          const Text('병원 정보 등록'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _hospNameController,
              decoration: const InputDecoration(
                labelText: '병원명',
                hintText: '서울대학교병원',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _hospCodeController,
              decoration: const InputDecoration(
                labelText: '병원 코드 (선택사항)',
                hintText: 'H001',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedHospType,
              decoration: const InputDecoration(
                labelText: '병원 종별',
                border: OutlineInputBorder(),
              ),
              items: ['종합병원', '상급종합병원', '의원', '보건소', '한의원']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedHospType = value!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _doctorNameController,
              decoration: const InputDecoration(
                labelText: '담당의',
                hintText: '김의사',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: '주소 (선택사항)',
                hintText: '서울특별시 종로구...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: '전화번호 (선택사항)',
                hintText: '02-2072-2114',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _saveHospital,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF17A2B8),
            foregroundColor: Colors.white,
          ),
          child: const Text('저장'),
        ),
      ],
    );
  }

  void _saveHospital() {
    // ERD 기반 Hospital 모델 저장 로직
    final hospitalData = {
      'user_id': 'current_user_id', // 현재 사용자 ID
      'hosp_name': _hospNameController.text,
      'hosp_code': _hospCodeController.text,
      'hosp_type': _selectedHospType,
      'doctor_name': _doctorNameController.text,
      'address': _addressController.text,
      'phone_number': _phoneController.text,
    };

    // API 호출: POST /api/v1/user/hospitals/
    print('병원 정보 저장: $hospitalData');
    Navigator.pop(context);
  }
}

// 질병 정보 입력 다이얼로그
class _IllnessDialog extends StatefulWidget {
  @override
  _IllnessDialogState createState() => _IllnessDialogState();
}

class _IllnessDialogState extends State<_IllnessDialog> {
  final _illNameController = TextEditingController();
  final _illCodeController = TextEditingController();
  String _selectedIllType = 'DISEASE';
  bool _isChronic = false;
  DateTime? _illStart;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.favorite, color: const Color(0xFFDC3545)),
          const SizedBox(width: 8),
          const Text('질병 정보 등록'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _illNameController,
              decoration: const InputDecoration(
                labelText: '질병/증상명',
                hintText: '고혈압',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedIllType,
              decoration: const InputDecoration(
                labelText: '구분',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'DISEASE', child: Text('질병')),
                DropdownMenuItem(value: 'SYMPTOM', child: Text('증상')),
              ],
              onChanged: (value) => setState(() => _selectedIllType = value!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _illCodeController,
              decoration: const InputDecoration(
                labelText: 'ICD-10 코드 (선택사항)',
                hintText: 'I10',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _isChronic,
                  onChanged: (value) => setState(() => _isChronic = value!),
                ),
                const Text('만성 질환'),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('발병일'),
              subtitle: Text(_illStart?.toString().split(' ')[0] ?? '선택하지 않음'),
              trailing: Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _saveIllness,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC3545),
            foregroundColor: Colors.white,
          ),
          child: const Text('저장'),
        ),
      ],
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _illStart = date);
    }
  }

  void _saveIllness() {
    // ERD 기반 Illness 모델 저장 로직
    final illnessData = {
      'user_id': 'current_user_id',
      'ill_name': _illNameController.text,
      'ill_type': _selectedIllType,
      'ill_code': _illCodeController.text,
      'is_chronic': _isChronic,
      'ill_start': _illStart?.toIso8601String(),
    };

    // API 호출: POST /api/v1/user/illnesses/
    print('질병 정보 저장: $illnessData');
    Navigator.pop(context);
  }
}

// 처방전 등록 다이얼로그
class _PrescriptionDialog extends StatefulWidget {
  @override
  _PrescriptionDialogState createState() => _PrescriptionDialogState();
}

class _PrescriptionDialogState extends State<_PrescriptionDialog> {
  String? _selectedMedicalInfo;
  DateTime _prescriptionDate = DateTime.now();
  List<Map<String, dynamic>> _medications = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.receipt_long, color: const Color(0xFF6F42C1)),
          const SizedBox(width: 8),
          const Text('처방전 등록'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedMedicalInfo,
              decoration: const InputDecoration(
                labelText: '의료정보 선택',
                border: OutlineInputBorder(),
                hintText: '병원-질병 조합을 선택하세요',
              ),
              items: [
                // UserMedicalInfo 목록에서 가져올 데이터
                DropdownMenuItem(
                  value: '1',
                  child: Text('서울대학교병원 - 고혈압'),
                ),
                DropdownMenuItem(
                  value: '2',
                  child: Text('서울대학교병원 - 당뇨병'),
                ),
              ],
              onChanged: (value) => setState(() => _selectedMedicalInfo = value),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('처방일'),
              subtitle: Text(_prescriptionDate.toString().split(' ')[0]),
              trailing: Icon(Icons.calendar_today),
              onTap: _selectPrescriptionDate,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('처방 약물', style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _addMedication,
                  icon: Icon(Icons.add),
                  label: Text('약물 추가'),
                ),
              ],
            ),
            ..._medications.map((med) => _buildMedicationItem(med)).toList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _savePrescription,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6F42C1),
            foregroundColor: Colors.white,
          ),
          child: const Text('저장'),
        ),
      ],
    );
  }

  Widget _buildMedicationItem(Map<String, dynamic> medication) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  medication['name'] ?? '약물명',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                onPressed: () => _removeMedication(medication),
                icon: Icon(Icons.remove_circle, color: Colors.red),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text('복용법: ${medication['dosage'] ?? '하루 2회'}'),
              ),
              Expanded(
                child: Text('기간: ${medication['duration'] ?? '30일'}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectPrescriptionDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _prescriptionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _prescriptionDate = date);
    }
  }

  void _addMedication() {
    showDialog(
      context: context,
      builder: (context) => _MedicationSelectionDialog(
        onMedicationSelected: (medication) {
          setState(() {
            _medications.add(medication);
          });
        },
      ),
    );
  }

  void _removeMedication(Map<String, dynamic> medication) {
    setState(() {
      _medications.remove(medication);
    });
  }

  void _savePrescription() {
    // ERD 기반 Prescription 및 PrescriptionMedication 저장
    final prescriptionData = {
      'prescription_date': _prescriptionDate.toIso8601String(),
      'is_active': true,
    };

    final userMedicalInfoData = {
      'medical_info_id': _selectedMedicalInfo,
      'prescription_id': 'generated_prescription_id',
    };

    final medicationsData = _medications.map((med) => {
      'medication_id': med['id'],
      'standard_dosage_pattern': med['dosage_pattern'],
      'duration_days': med['duration'],
      'total_quantity': med['quantity'],
    }).toList();

    // API 호출들:
    // 1. POST /api/v1/bokyak/prescriptions/
    // 2. PUT /api/v1/user/medical-info/{id}/ (prescriptions 업데이트)
    // 3. POST /api/v1/bokyak/prescriptions-medications/ (각 약물별)

    print('처방전 저장: $prescriptionData');
    print('의료정보 업데이트: $userMedicalInfoData');
    print('처방약물: $medicationsData');
    Navigator.pop(context);
  }
}

// 약물 선택 다이얼로그
class _MedicationSelectionDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onMedicationSelected;

  const _MedicationSelectionDialog({required this.onMedicationSelected});

  @override
  _MedicationSelectionDialogState createState() => _MedicationSelectionDialogState();
}

class _MedicationSelectionDialogState extends State<_MedicationSelectionDialog> {
  final _searchController = TextEditingController();
  final _durationController = TextEditingController(text: '30');
  final _quantityController = TextEditingController(text: '60');
  List<String> _selectedTimes = [];
  Map<String, dynamic>? _selectedMedication;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('약물 추가'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '약물 검색',
                hintText: '아스피린',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: _searchMedication,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedMedication != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('선택: ${_selectedMedication!['name']}'),
              ),
              const SizedBox(height: 12),
            ],
            const Text('복용 시간', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              children: ['아침(D)', '점심(A)', '저녁(E)', '취침전(N)', '필요시(P)']
                  .map((time) => FilterChip(
                label: Text(time),
                selected: _selectedTimes.contains(time.split('(')[1].split(')')[0]),
                onSelected: (selected) {
                  setState(() {
                    final code = time.split('(')[1].split(')')[0];
                    if (selected) {
                      _selectedTimes.add(code);
                    } else {
                      _selectedTimes.remove(code);
                    }
                  });
                },
              ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: '처방일수',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: '총 개수',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _selectedMedication != null ? _addMedication : null,
          child: const Text('추가'),
        ),
      ],
    );
  }

  void _searchMedication() {
    // API 호출: GET /api/v1/user/medications/search/?name=query
    setState(() {
      _selectedMedication = {
        'id': 1234567890,
        'name': '${_searchController.text} 100mg',
        'company': '제약회사',
      };
    });
  }

  void _addMedication() {
    final medication = {
      'id': _selectedMedication!['id'],
      'name': _selectedMedication!['name'],
      'dosage_pattern': _selectedTimes,
      'dosage': '하루 ${_selectedTimes.length}회',
      'duration': int.parse(_durationController.text),
      'quantity': int.parse(_quantityController.text),
    };

    widget.onMedicationSelected(medication);
    Navigator.pop(context);
  }
}

// 처방전 갱신 다이얼로그
class _PrescriptionUpdateDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.refresh, color: const Color(0xFF28A745)),
          const SizedBox(width: 8),
          const Text('처방전 갱신'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('기존 활성 처방전을 새로운 처방으로 갱신하시겠습니까?'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '기존 처방전은 비활성화되고 새로운 처방전이 생성됩니다.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            // Prescription.update_prescription() 메서드 호출
            // API: POST /api/v1/bokyak/prescriptions/{id}/update_prescription/
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF28A745),
            foregroundColor: Colors.white,
          ),
          child: const Text('갱신'),
        ),
      ],
    );
  }
}

// 복약그룹 다이얼로그
class _MedicationGroupDialog extends StatefulWidget {
  @override
  _MedicationGroupDialogState createState() => _MedicationGroupDialogState();
}

class _MedicationGroupDialogState extends State<_MedicationGroupDialog> {
  final _groupNameController = TextEditingController();
  String? _selectedPrescription;
  String? _selectedMedicalInfo;
  bool _reminderEnabled = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.group_work, color: const Color(0xFF667EEA)),
          const SizedBox(width: 8),
          const Text('복약그룹 설정'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _groupNameController,
            decoration: const InputDecoration(
              labelText: '그룹명',
              hintText: '아침약, 저녁약, 혈압약 등',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedMedicalInfo,
            decoration: const InputDecoration(
              labelText: '의료정보',
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: '1', child: Text('서울대학교병원 - 고혈압')),
              DropdownMenuItem(value: '2', child: Text('서울대학교병원 - 당뇨병')),
            ],
            onChanged: (value) => setState(() => _selectedMedicalInfo = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedPrescription,
            decoration: const InputDecoration(
              labelText: '처방전',
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'PR2025010001', child: Text('PR2025010001 (2025-01-15)')),
            ],
            onChanged: (value) => setState(() => _selectedPrescription = value),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _reminderEnabled,
                onChanged: (value) => setState(() => _reminderEnabled = value!),
              ),
              const Text('알림 활성화'),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _saveMedicationGroup,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667EEA),
            foregroundColor: Colors.white,
          ),
          child: const Text('저장'),
        ),
      ],
    );
  }

  void _saveMedicationGroup() {
    // ERD 기반 MedicationGroup 저장
    final groupData = {
      'medical_info_id': _selectedMedicalInfo,
      'prescription_id': _selectedPrescription,
      'group_name': _groupNameController.text,
      'reminder_enabled': _reminderEnabled,
    };

    // API 호출: POST /api/v1/bokyak/groups/
    print('복약그룹 저장: $groupData');
    Navigator.pop(context);
  }
}

// 복약주기 다이얼로그
class _MedicationCycleDialog extends StatefulWidget {
  @override
  _MedicationCycleDialogState createState() => _MedicationCycleDialogState();
}

class _MedicationCycleDialogState extends State<_MedicationCycleDialog> {
  String? _selectedGroup;
  DateTime _cycleStart = DateTime.now();
  DateTime? _cycleEnd;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.timeline, color: const Color(0xFF20C997)),
          const SizedBox(width: 8),
          const Text('복약주기 관리'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedGroup,
            decoration: const InputDecoration(
              labelText: '복약그룹',
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'group1', child: Text('아침약')),
              DropdownMenuItem(value: 'group2', child: Text('저녁약')),
            ],
            onChanged: (value) => setState(() => _selectedGroup = value),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('주기 시작일'),
            subtitle: Text(_cycleStart.toString().split(' ')[0]),
            trailing: Icon(Icons.calendar_today),
            onTap: _selectStartDate,
          ),
          ListTile(
            title: const Text('주기 종료일 (선택사항)'),
            subtitle: Text(_cycleEnd?.toString().split(' ')[0] ?? '설정하지 않음'),
            trailing: Icon(Icons.calendar_today),
            onTap: _selectEndDate,
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '새로운 주기는 같은 처방전을 공유하는 모든 그룹에 동시에 적용됩니다.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _saveMedicationCycle,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF20C997),
            foregroundColor: Colors.white,
          ),
          child: const Text('저장'),
        ),
      ],
    );
  }

  void _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _cycleStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() => _cycleStart = date);
    }
  }

  void _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _cycleEnd ?? DateTime.now().add(Duration(days: 30)),
      firstDate: _cycleStart,
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() => _cycleEnd = date);
    }
  }

  void _saveMedicationCycle() {
    // ERD 기반 MedicationCycle 저장
    final cycleData = {
      'group_id': _selectedGroup,
      'cycle_start': _cycleStart.toIso8601String(),
      'cycle_end': _cycleEnd?.toIso8601String(),
      'is_active': true,
    };

    // API 호출: POST /api/v1/bokyak/cycles/
    print('복약주기 저장: $cycleData');
    Navigator.pop(context);
  }
}

// 복약상세 다이얼로그
class _MedicationDetailDialog extends StatefulWidget {
  @override
  _MedicationDetailDialogState createState() => _MedicationDetailDialogState();
}

class _MedicationDetailDialogState extends State<_MedicationDetailDialog> {
  String? _selectedCycle;
  String? _selectedPrescriptionMedication;
  final _remainingQuantityController = TextEditingController();
  List<String> _actualDosageTimes = [];
  Map<String, dynamic> _patientAdjustments = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.tune, color: const Color(0xFFFD7E14)),
          const SizedBox(width: 8),
          const Text('복약상세 조정'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCycle,
              decoration: const InputDecoration(
                labelText: '복약주기',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'cycle1', child: Text('아침약 - 주기 1')),
                DropdownMenuItem(value: 'cycle2', child: Text('아침약 - 주기 2')),
              ],
              onChanged: (value) => setState(() => _selectedCycle = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedPrescriptionMedication,
              decoration: const InputDecoration(
                labelText: '처방약물',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'med1', child: Text('아스피린 100mg')),
                DropdownMenuItem(value: 'med2', child: Text('메트포르민 500mg')),
              ],
              onChanged: (value) => setState(() => _selectedPrescriptionMedication = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _remainingQuantityController,
              decoration: const InputDecoration(
                labelText: '현재 잔여량',
                hintText: '30',
                border: OutlineInputBorder(),
                suffixText: '정',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            const Text('복용 시간 조정 (기본값과 다른 경우만)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              children: ['아침(D)', '점심(A)', '저녁(E)', '취침전(N)', '필요시(P)']
                  .map((time) => FilterChip(
                label: Text(time),
                selected: _actualDosageTimes.contains(time.split('(')[1].split(')')[0]),
                onSelected: (selected) {
                  setState(() {
                    final code = time.split('(')[1].split(')')[0];
                    if (selected) {
                      _actualDosageTimes.add(code);
                    } else {
                      _actualDosageTimes.remove(code);
                    }
                  });
                },
              ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            ExpansionTile(
              title: const Text('환자별 조정사항'),
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: '용량 조정',
                    hintText: '의사 지시에 따라 0.5정으로 감량',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _patientAdjustments['dosage_note'] = value,
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    labelText: '복용 시간 조정',
                    hintText: '식사 30분 후로 변경',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _patientAdjustments['timing_note'] = value,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '템플릿과 다른 설정만 저장되어 데이터 중복을 방지합니다.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _saveMedicationDetail,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFD7E14),
            foregroundColor: Colors.white,
          ),
          child: const Text('저장'),
        ),
      ],
    );
  }

  void _saveMedicationDetail() {
    // ERD 기반 MedicationDetail 저장 (변화분만)
    final detailData = {
      'cycle_id': _selectedCycle,
      'prescription_medication_id': _selectedPrescriptionMedication,
      'actual_dosage_pattern': _actualDosageTimes.isNotEmpty ? _actualDosageTimes : null,
      'remaining_quantity': int.parse(_remainingQuantityController.text),
      'patient_adjustments': _patientAdjustments.isNotEmpty ? _patientAdjustments : {},
    };

    // API 호출: POST /api/v1/bokyak/details/
    print('복약상세 저장: $detailData');
    Navigator.pop(context);
  }
}

// 알림 설정 다이얼로그
class _AlertDialog extends StatefulWidget {
  @override
  _AlertDialogState createState() => _AlertDialogState();
}

class _AlertDialogState extends State<_AlertDialog> {
  String? _selectedMedicationDetail;
  String _alertType = 'DOSAGE';
  TimeOfDay _alertTime = TimeOfDay.now();
  bool _isActive = true;
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.notifications, color: const Color(0xFFFFC107)),
          const SizedBox(width: 8),
          const Text('알림 설정'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedMedicationDetail,
              decoration: const InputDecoration(
                labelText: '복약상세',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'detail1', child: Text('아스피린 100mg - 아침약')),
                DropdownMenuItem(value: 'detail2', child: Text('메트포르민 500mg - 아침약')),
              ],
              onChanged: (value) => setState(() => _selectedMedicationDetail = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _alertType,
              decoration: const InputDecoration(
                labelText: '알림 유형',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'DOSAGE', child: Text('복용 알림')),
                DropdownMenuItem(value: 'REFILL', child: Text('처방전 갱신 알림')),
                DropdownMenuItem(value: 'APPOINTMENT', child: Text('진료 예약 알림')),
              ],
              onChanged: (value) => setState(() => _alertType = value!),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('알림 시간'),
              subtitle: Text(_alertTime.format(context)),
              trailing: Icon(Icons.access_time),
              onTap: _selectTime,
            ),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: '알림 메시지 (선택사항)',
                hintText: '아침 약 복용 시간입니다.',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value!),
                ),
                const Text('알림 활성화'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _saveAlert,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFC107),
            foregroundColor: Colors.black,
          ),
          child: const Text('저장'),
        ),
      ],
    );
  }

  void _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _alertTime,
    );
    if (time != null) {
      setState(() => _alertTime = time);
    }
  }

  void _saveAlert() {
    // ERD 기반 MedicationAlert 저장
    final alertData = {
      'medication_detail_id': _selectedMedicationDetail,
      'alert_type': _alertType,
      'alert_time': '${_alertTime.hour.toString().padLeft(2, '0')}:${_alertTime.minute.toString().padLeft(2, '0')}',
      'is_active': _isActive,
      'message': _messageController.text,
    };

    // API 호출: POST /api/v1/bokyak/alerts/
    print('알림 저장: $alertData');
    Navigator.pop(context);
  }
}

// API Service 클래스 (참고용)
class ApiService {
  // User App APIs
  static Future<void> createHospital(Map<String, dynamic> data) async {
    // POST /api/v1/user/hospitals/
  }

  static Future<void> createIllness(Map<String, dynamic> data) async {
    // POST /api/v1/user/illnesses/
  }

  static Future<List<dynamic>> searchMedications(String query) async {
    // GET /api/v1/user/medications/search/?name=query
    return [];
  }

  static Future<List<dynamic>> getUserMedicalInfo() async {
    // GET /api/v1/user/medical-info/
    return [];
  }

  // Bokyak App APIs
  static Future<void> createPrescription(Map<String, dynamic> data) async {
    // POST /api/v1/bokyak/prescriptions/
  }

  static Future<void> updatePrescription(String id, Map<String, dynamic> data) async {
    // POST /api/v1/bokyak/prescriptions/{id}/update_prescription/
  }

  static Future<void> createMedicationGroup(Map<String, dynamic> data) async {
    // POST /api/v1/bokyak/groups/
  }

  static Future<void> createMedicationCycle(Map<String, dynamic> data) async {
    // POST /api/v1/bokyak/cycles/
  }

  static Future<void> createMedicationDetail(Map<String, dynamic> data) async {
    // POST /api/v1/bokyak/details/
  }

  static Future<void> createMedicationRecord(Map<String, dynamic> data) async {
    // POST /api/v1/bokyak/records/
  }

  static Future<void> createMedicationAlert(Map<String, dynamic> data) async {
    // POST /api/v1/bokyak/alerts/
  }

  // 복합 API 호출
  static Future<void> bulkRecordMedication(List<Map<String, dynamic>> records) async {
    // POST /api/v1/bokyak/records/bulk_record/
  }

  static Future<Map<String, dynamic>> getTodayMedications() async {
    // GET /api/v1/bokyak/details/today_medications/
    return {};
  }

  static Future<Map<String, dynamic>> getMedicationStatistics(int days) async {
    // GET /api/v1/bokyak/records/statistics/?days=days
    return {};
  }
}