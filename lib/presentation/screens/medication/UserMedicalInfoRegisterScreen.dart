import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_medical_info_provider.dart';

class RegisterUserMedicalInfoScreen extends StatelessWidget {
  const RegisterUserMedicalInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AYAK 복약관리',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NotoSans',
      ),
      home: const HomePage(),
    );
  }
}

// 홈 화면
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _isQuickActionsVisible = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleQuickActions() {
    setState(() {
      _isQuickActionsVisible = !_isQuickActionsVisible;
    });

    if (_isQuickActionsVisible) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // 메인 콘텐츠
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더 카드
                  _buildHeaderCard(),
                  const SizedBox(height: 24),

                  // 긴급 일정
                  _buildUrgentSchedules(),
                  const SizedBox(height: 24),

                  // 오늘의 복약
                  _buildTodayMedications(),
                  const SizedBox(height: 100), // 플로팅 버튼 공간
                ],
              ),
            ),
          ),

          // 플로팅 액션 버튼
          _buildFloatingActionButton(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTimeGreeting(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '김건강님, 오늘도 건강한 하루 되세요! 💊',
                    style: TextStyle(
                      color: Color(0xFFBFDBFE),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text(
                    '4/6',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '오늘 복용',
                    style: TextStyle(
                      color: Color(0xFFBFDBFE),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 진행률 바
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '오늘 진행률',
                    style: TextStyle(
                      color: Color(0xFFBFDBFE),
                      fontSize: 14,
                    ),
                  ),
                  const Text(
                    '67%',
                    style: TextStyle(
                      color: Color(0xFFBFDBFE),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.67,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentSchedules() {
    final urgentSchedules = [
      {
        'title': '처방전 갱신 필요',
        'subtitle': '서울대병원 내분비내과 - 김의사',
        'daysLeft': 5,
        'color': Colors.red,
        'icon': Icons.description,
      },
      {
        'title': '아모잘탄정 재고 부족',
        'subtitle': '5일분 남음 - 처방전 갱신 필요',
        'daysLeft': 5,
        'color': Colors.orange,
        'icon': Icons.medication,
      },
      {
        'title': '연세병원 내원 예정',
        'subtitle': '소화기내과 - 박의사',
        'daysLeft': 10,
        'color': Colors.blue,
        'icon': Icons.local_hospital,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '긴급 확인 필요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('전체보기'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...urgentSchedules.map((schedule) => _buildScheduleCard(schedule)),
      ],
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: schedule['color'] as Color,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (schedule['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                schedule['icon'] as IconData,
                color: schedule['color'] as Color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule['title'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    schedule['subtitle'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'D-${schedule['daysLeft']}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: schedule['color'] as Color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayMedications() {
    final medicationGroups = [
      {
        'groupName': '아침약',
        'time': '08:00',
        'medications': [
          {'name': '아모잘탄정', 'quantity': 1, 'taken': true},
          {'name': '아스피린정', 'quantity': 1, 'taken': true},
          {'name': '비타민D', 'quantity': 1, 'taken': false},
        ],
      },
      {
        'groupName': '점심약',
        'time': '12:30',
        'medications': [
          {'name': '소화제', 'quantity': 1, 'taken': false},
        ],
      },
      {
        'groupName': '저녁약',
        'time': '19:00',
        'medications': [
          {'name': '메트포민정', 'quantity': 2, 'taken': false},
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '오늘의 복약',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('상세보기'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...medicationGroups.map((group) => _buildMedicationGroup(group)),
      ],
    );
  }

  Widget _buildMedicationGroup(Map<String, dynamic> group) {
    final medications = group['medications'] as List<Map<String, dynamic>>;
    final takenCount = medications.where((med) => med['taken'] == true).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      group['groupName'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${group['time']})',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                Text(
                  '$takenCount/${medications.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 약물 그리드 (6열)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: medications.length,
              itemBuilder: (context, index) {
                final medication = medications[index];
                return _buildMedicationCard(medication);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    final bool taken = medication['taken'];

    return Container(
      decoration: BoxDecoration(
        color: taken ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
        border: Border.all(
          color: taken ? const Color(0xFFBBF7D0) : const Color(0xFFE5E7EB),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.medication,
                    size: 16,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  medication['name'],
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${medication['quantity']}정',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          if (taken)
            const Positioned(
              top: -2,
              right: -2,
              child: Icon(
                Icons.check_circle,
                color: Color(0xFF10B981),
                size: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: 24,
      right: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 퀵 액션 메뉴
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: _animation.value,
                child: Opacity(
                  opacity: _animation.value,
                  child: _isQuickActionsVisible
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildQuickActionItem(
                        '의료정보 추가',
                        '병원-질병-처방전 생성',
                        Icons.add,
                        Colors.blue,
                        isPrimary: true,
                        onTap: () => _navigateToMedicalInfoFlow(),
                      ),
                      const SizedBox(height: 12),
                      _buildQuickActionItem(
                        '복용 기록',
                        '놓친 약물 기록하기',
                        Icons.check_circle,
                        Colors.green,
                        onTap: () => _showRecordDialog(),
                      ),
                      const SizedBox(height: 12),
                      _buildQuickActionItem(
                        '빠른 설정',
                        '알림/그룹 관리',
                        Icons.settings,
                        Colors.grey,
                        onTap: () => _showQuickSettings(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  )
                      : const SizedBox.shrink(),
                ),
              );
            },
          ),

          // 메인 플로팅 버튼
          FloatingActionButton(
            onPressed: _toggleQuickActions,
            backgroundColor: const Color(0xFF3B82F6),
            child: AnimatedRotation(
              turns: _isQuickActionsVisible ? 0.125 : 0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(
      String title,
      String subtitle,
      IconData icon,
      Color color, {
        bool isPrimary = false,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary
              ? Border.all(color: const Color(0xFF3B82F6), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
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

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '좋은 아침입니다';
    if (hour < 18) return '좋은 오후입니다';
    return '좋은 저녁입니다';
  }

  void _navigateToMedicalInfoFlow() {
    setState(() {
      _isQuickActionsVisible = false;
    });
    _animationController.reverse();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserMedicalInfoFlow(),
      ),
    );
  }

  void _showRecordDialog() {
    setState(() {
      _isQuickActionsVisible = false;
    });
    _animationController.reverse();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('복용 기록'),
        content: const Text('복용 기록 기능이 구현될 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showQuickSettings() {
    setState(() {
      _isQuickActionsVisible = false;
    });
    _animationController.reverse();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('빠른 설정'),
        content: const Text('빠른 설정 기능이 구현될 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

// 의료정보 생성 플로우
class UserMedicalInfoFlow extends StatefulWidget {
  const UserMedicalInfoFlow({Key? key}) : super(key: key);

  @override
  State<UserMedicalInfoFlow> createState() => _UserMedicalInfoFlowState();
}

class _UserMedicalInfoFlowState extends State<UserMedicalInfoFlow> {
  int currentStep = 0;
  Map<String, dynamic>? selectedHospital;
  Map<String, dynamic>? selectedIllness;
  Map<String, dynamic>? selectedPrescription;
  DateTime? prescriptionDate;
  bool isCreatingNew = false;
  String searchQuery = '';

  final List<Map<String, dynamic>> steps = [
    {
      'title': '의료정보 만들기',
      'subtitle': '새로운 의료정보를 생성합니다',
      'icon': Icons.description,
    },
    {
      'title': '병원 선택',
      'subtitle': '진료받을 병원을 선택해주세요',
      'icon': Icons.local_hospital,
    },
    {
      'title': '질병 선택',
      'subtitle': '진료받을 질병을 선택해주세요',
      'icon': Icons.favorite,
    },
    {
      'title': '처방전 설정',
      'subtitle': '처방전을 설정해주세요',
      'icon': Icons.calendar_today,
    },
    {
      'title': '완료',
      'subtitle': '의료정보가 생성되었습니다',
      'icon': Icons.check_circle,
    },
  ];

  final List<Map<String, dynamic>> existingHospitals = [
    {
      'hospital_id': 'HOSP_001',
      'hosp_name': '서울대학교병원',
      'hosp_type': '종합병원',
      'address': '서울특별시 종로구 대학로 101',
      'phone_number': '02-2072-2114',
      'doctor_name': '김의사',
    },
    {
      'hospital_id': 'HOSP_002',
      'hosp_name': '연세세브란스병원',
      'hosp_type': '종합병원',
      'address': '서울특별시 서대문구 연세로 50-1',
      'phone_number': '02-2228-5800',
      'doctor_name': '박의사',
    },
  ];

  final List<Map<String, dynamic>> existingIllnesses = [
    {
      'illness_id': 'ILL_001',
      'ill_name': '고혈압',
      'ill_code': 'I10',
      'ill_type': 'DISEASE',
      'is_chronic': true,
    },
    {
      'illness_id': 'ILL_002',
      'ill_name': '당뇨병',
      'ill_code': 'E11',
      'ill_type': 'DISEASE',
      'is_chronic': true,
    },
    {
      'illness_id': 'ILL_003',
      'ill_name': '위염',
      'ill_code': 'K29.7',
      'ill_type': 'DISEASE',
      'is_chronic': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // appBar: AppBar(
      //   title: const Text('의료정보 생성'),
      //   backgroundColor: Colors.white,
      //   foregroundColor: Colors.black,
      //   elevation: 0,
      // ),
      body: Column(
        children: [
          // 진행률 헤더
          _buildProgressHeader(),

          // 메인 콘텐츠
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStepContent(),
            ),
          ),

          // 네비게이션 버튼
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '의료정보 생성',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${currentStep + 1} / ${steps.length}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 진행률 바
          LinearProgressIndicator(
            value: (currentStep + 1) / steps.length,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
          ),
          const SizedBox(height: 16),

          // 단계 인디케이터
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isActive = currentStep == index;
              final isCompleted = currentStep > index;

              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFF10B981)
                          : isActive
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFFE5E7EB),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : step['icon'],
                      color: isCompleted || isActive ? Colors.white : const Color(0xFF9CA3AF),
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 60,
                    child: Text(
                      step['title'],
                      style: TextStyle(
                        fontSize: 10,
                        color: isActive ? const Color(0xFF3B82F6) : const Color(0xFF6B7280),
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildHospitalSelectionStep();
      case 2:
        return _buildIllnessSelectionStep();
      case 3:
        return _buildPrescriptionStep();
      case 4:
        return _buildCompletionStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWelcomeStep() {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.description,
            color: Colors.white,
            size: 48,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '의료정보 만들기',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          '새로운 병원-질병 연결 정보를 생성합니다',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildFeatureCard(
          icon: Icons.local_hospital,
          title: '병원 정보',
          description: '진료받을 병원과 담당의를 선택합니다',
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.favorite,
          title: '질병 정보',
          description: '진단받은 질병을 선택합니다',
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.calendar_today,
          title: '처방전 설정',
          description: '처방전 정보와 복용 일정을 설정합니다',
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3B82F6),
              size: 24,
            ),
          ),
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
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalSelectionStep() {
    final provider = Provider.of<UserMedicalInfoProvider>(context);
    final hospitals = provider.searchHospitals(provider.searchQuery);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 검색 필드
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: (value) => provider.setSearchQuery(value),
                  decoration: const InputDecoration(
                    hintText: '병원 또는 의사 이름으로 검색',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 병원 목록
        ...hospitals.map((hospital) => _buildHospitalCard(hospital)),
      ],
    );
  }

  Widget _buildHospitalCard(Map<String, dynamic> hospital) {
    final provider = Provider.of<UserMedicalInfoProvider>(context);
    final isSelected = provider.selectedHospital?['hospital_id'] == hospital['hospital_id'];

    return GestureDetector(
      onTap: () => provider.selectHospital(hospital),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_hospital,
                color: Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hospital['hosp_name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hospital['address'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          hospital['hosp_type'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '담당의: ${hospital['doctor_name']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF3B82F6),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllnessSelectionStep() {
    final provider = Provider.of<UserMedicalInfoProvider>(context);
    final illnesses = provider.searchIllnesses(provider.searchQuery);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 검색 필드
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: (value) => provider.setSearchQuery(value),
                  decoration: const InputDecoration(
                    hintText: '질병 이름 또는 코드로 검색',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 질병 목록
        ...illnesses.map((illness) => _buildIllnessCard(illness)),
      ],
    );
  }

  Widget _buildIllnessCard(Map<String, dynamic> illness) {
    final provider = Provider.of<UserMedicalInfoProvider>(context);
    final isSelected = provider.selectedIllness?['illness_id'] == illness['illness_id'];

    return GestureDetector(
      onTap: () => provider.selectIllness(illness),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.favorite,
                color: Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        illness['ill_name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: illness['is_chronic']
                              ? const Color(0xFFFEF3C7)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          illness['is_chronic'] ? '만성질환' : '일반질환',
                          style: TextStyle(
                            fontSize: 12,
                            color: illness['is_chronic']
                                ? const Color(0xFFD97706)
                                : const Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '질병코드: ${illness['ill_code']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    illness['description'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF3B82F6),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionStep() {
    final provider = Provider.of<UserMedicalInfoProvider>(context);
    if (provider.selectedIllness == null) {
      return const Center(
        child: Text('먼저 질병을 선택해주세요'),
      );
    }

    final templates = provider.getPrescriptionTemplatesForIllness(
      provider.selectedIllness!['illness_id'],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 처방일 선택
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '처방일 선택',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    provider.setPrescriptionDate(date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        provider.prescriptionDate != null
                            ? '${provider.prescriptionDate!.year}년 ${provider.prescriptionDate!.month}월 ${provider.prescriptionDate!.day}일'
                            : '처방일을 선택해주세요',
                        style: TextStyle(
                          color: provider.prescriptionDate != null
                              ? const Color(0xFF1F2937)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Color(0xFF6B7280),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 처방전 템플릿 목록
        const Text(
          '처방전 템플릿',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        ...templates.map((template) => _buildPrescriptionCard(template)),
      ],
    );
  }

  Widget _buildPrescriptionCard(Map<String, dynamic> template) {
    final provider = Provider.of<UserMedicalInfoProvider>(context);
    final isSelected = provider.selectedPrescription?['template_id'] == template['template_id'];

    return GestureDetector(
      onTap: () => provider.selectPrescription(template),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  template['template_name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${template['duration_weeks']}주',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...template['medications'].map<Widget>((medication) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.medication,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication['med_name'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          '${medication['dosage']} - ${medication['frequency']} (${medication['timing']})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionStep() {
    final provider = Provider.of<UserMedicalInfoProvider>(context);
    
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 48,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '의료정보 생성 완료',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '새로운 의료정보가 성공적으로 생성되었습니다',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildCompletionCard(
          '병원 정보',
          provider.selectedHospital?['hosp_name'] ?? '',
          Icons.local_hospital,
        ),
        const SizedBox(height: 16),
        _buildCompletionCard(
          '질병 정보',
          provider.selectedIllness?['ill_name'] ?? '',
          Icons.favorite,
        ),
        const SizedBox(height: 16),
        _buildCompletionCard(
          '처방전',
          provider.selectedPrescription?['template_name'] ?? '',
          Icons.description,
        ),
      ],
    );
  }

  Widget _buildCompletionCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3B82F6),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final provider = Provider.of<UserMedicalInfoProvider>(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (currentStep > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  currentStep--;
                });
              },
              child: const Text('이전'),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton(
            onPressed: () async {
              if (currentStep == steps.length - 1) {
                // 완료 처리
                Navigator.pop(context);
              } else if (currentStep == steps.length - 2) {
                // 저장 처리
                final success = await provider.saveMedicalInfo();
                if (success) {
                  setState(() {
                    currentStep++;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('의료정보 저장에 실패했습니다'),
                    ),
                  );
                }
              } else {
                bool canProceed = true;
                switch (currentStep) {
                  case 1: // 병원 선택
                    canProceed = provider.selectedHospital != null;
                    break;
                  case 2: // 질병 선택
                    canProceed = provider.selectedIllness != null;
                    break;
                  case 3: // 처방전 설정
                    canProceed = provider.selectedPrescription != null &&
                        provider.prescriptionDate != null;
                    break;
                }

                if (canProceed) {
                  setState(() {
                    currentStep++;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('필수 정보를 선택해주세요'),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              currentStep == steps.length - 1
                  ? '완료'
                  : currentStep == steps.length - 2
                      ? '저장'
                      : '다음',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}