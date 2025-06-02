
// screens/prescription_renewal_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yakunstructuretest/data/models/prescription_renewal_model.dart';
import 'package:yakunstructuretest/presentation/providers/auth_provider.dart';
import 'package:yakunstructuretest/presentation/providers/enhanced_medication_provider.dart';
import 'package:yakunstructuretest/presentation/providers/prescription_provider.dart';
import 'package:yakunstructuretest/presentation/screens/home/PillGrid.dart';

class PrescriptionRenewalScreen extends StatefulWidget {
  final ExpiringCycle? expiringCycle;

  const PrescriptionRenewalScreen({
    Key? key,
    this.expiringCycle,
  }) : super(key: key);

  @override
  State<PrescriptionRenewalScreen> createState() => _PrescriptionRenewalScreenState();
}

class _PrescriptionRenewalScreenState extends State<PrescriptionRenewalScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _prescriptionDate = DateTime.now();
  final List<MedicationData> _medications = [];
  bool _isSubmitting = false;
  Map<String, bool> _selectedMedications = {};

  @override
  Widget build(BuildContext context) {
    // 알약 데이터 맵
    List<String> medicationSequence = [
      '낙센', '낙센', '아스피린', '애드빌', '애드빌', '애드빌', '타이레놀', '타이레놀',
      '타이레놀', '타이레놀', '펜잘큐', '오메프라졸'
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('처방전 갱신'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 만료 정보 표시
              if (widget.expiringCycle != null) _buildExpirationAlert(),

              SizedBox(height: 20),

              // 처방일 선택
              _buildDateSelector(),

              SizedBox(height: 12),

              _buildMedicationSelector(),

              MedicationGridWidget(
                groupId: 'group_001',
                cycleId: 1,
                dosagePattern: '아침',
                medications: medications,
                columnsPerRow: 6,
                onRecordSubmitted: (selectedMedications, action) {
                  print('기록 완료: ${selectedMedications.length}개 약물, 액션: ${action.displayName}');
                  // 여기서 UI 새로고침이나 추가 로직 수행
                },
              ),

              SizedBox(height: 20),

              // 약물 리스트
              _buildMedicationSection(),

              SizedBox(height: 30),

              // 갱신 버튼
              _buildRenewalButton(),
            ],
          ),
        ),
      ),
    );
  }
  List<PillData> medications = [
    PillData(name: '낙센', color: Color(0xFF4ECDC4), shape: 'oval', medicationDetailId: 1),
    PillData(name: '아스피린', color: Color(0xFF96CEB4), shape: 'round', medicationDetailId: 2),
    PillData(name: '애드빌', color: Color(0xFFFF6B35), shape: 'oval', medicationDetailId: 3),
    PillData(name: '타이레놀', color: Colors.white, shape: 'round', medicationDetailId: 4),
    PillData(name: '펜잘큐', color: Color(0xFF45B7D1), shape: 'round', medicationDetailId: 5),
    PillData(name: '오메프라졸', color: Color(0xFFDDA0DD), shape: 'capsule', medicationDetailId: 6),
  ];

  Widget _buildMedicationSelector() {
    List<String> _getFrequencyMedications() {
      return ['아침', "저녁", "필요시"];
    }
    final medications = _getFrequencyMedications();

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
                  '변화한 처방약',
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
                          for (String med in medications) med: true
                        };
                      }),
                      child: Text(
                        '전체선택',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _selectedMedications = {
                          for (String med in medications) med: false
                        };
                      }),
                      child: Text(
                        '전체해제',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: medications.map((med) => _buildMedicationChip(med)).toList(),
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

  Widget _buildExpirationAlert() {
    final cycle = widget.expiringCycle!;
    final isExpired = cycle.isExpired;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isExpired ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpired ? Colors.red : Colors.orange,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isExpired ? Icons.error : Icons.warning,
                color: isExpired ? Colors.red : Colors.orange,
              ),
              SizedBox(width: 8),
              Text(
                isExpired ? '처방전 만료됨' : '처방전 만료 예정',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isExpired ? Colors.red : Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('복약그룹: ${cycle.groupName}'),
          Text('병원: ${cycle.hospitalName}'),
          Text('만료일: ${cycle.cycleEnd.toString().split(' ')[0]}'),
          if (isExpired)
            Text('${cycle.daysOverdue}일 지남', style: TextStyle(color: Colors.red))
          else
            Text('${cycle.daysRemaining}일 남음', style: TextStyle(color: Colors.orange)),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '새 처방일',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_prescriptionDate.toString().split(' ')[0]),
                Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '처방 약물',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _addMedication,
              icon: Icon(Icons.add),
              label: Text('약물 추가'),
            ),
          ],
        ),
        SizedBox(height: 12),
        if (_medications.isEmpty)
          Container(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                '처방 약물을 추가해주세요',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          ..._medications.asMap().entries.map((entry) {
            final index = entry.key;
            final medication = entry.value;
            return _buildMedicationCard(medication, index);
          }).toList(),
      ],
    );
  }

  Widget _buildMedicationCard(MedicationData medication, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '약물 ${index + 1}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => _removeMedication(index),
                  icon: Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            Text('약물 ID: ${medication.medicationId}'),
            Text('총량: ${medication.totalQuantity}'),
            Text('처방일수: ${medication.durationDays}일'),
          ],
        ),
      ),
    );
  }

  Widget _buildRenewalButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitRenewal,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        child: _isSubmitting
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
          '처방전 갱신',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _prescriptionDate,
      firstDate: DateTime.now().subtract(Duration(days: 30)),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        _prescriptionDate = picked;
      });
    }
  }

  void _addMedication() {
    // 약물 추가 모달 또는 화면으로 이동
    showDialog(
      context: context,
      builder: (context) => _MedicationAddDialog(
        onAdd: (medication) {
          setState(() {
            _medications.add(medication);
          });
        },
      ),
    );
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  Future<void> _submitRenewal() async {
    if (!_formKey.currentState!.validate() || _medications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 올바르게 입력해주세요')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다');
      }

      final request = PrescriptionRenewalRequest(
        userId: currentUser.userId,
        hospitalId: 'HOSPITAL_ID', // 실제 병원 ID로 교체
        illnessId: 'ILLNESS_ID', // 실제 질병 ID로 교체
        oldPrescriptionId: widget.expiringCycle?.prescriptionId,
        prescriptionDate: _prescriptionDate,
        medications: _medications,
      );

      final prescriptionProvider = context.read<PrescriptionProvider>();
      final success = await prescriptionProvider.renewPrescription(request);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('처방전이 성공적으로 갱신되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(prescriptionProvider.error ?? '갱신에 실패했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}

// 약물 추가 다이얼로그
class _MedicationAddDialog extends StatefulWidget {
  final Function(MedicationData) onAdd;

  const _MedicationAddDialog({required this.onAdd});

  @override
  State<_MedicationAddDialog> createState() => _MedicationAddDialogState();
}

class _MedicationAddDialogState extends State<_MedicationAddDialog> {
  final _medicationIdController = TextEditingController();
  final _totalQuantityController = TextEditingController();
  final _durationDaysController = TextEditingController();

  final Map<String, dynamic> _dosagePattern = {
    'morning': 0,
    'afternoon': 0,
    'evening': 0,
    'before_bed': 0,
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('약물 추가'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _medicationIdController,
              decoration: InputDecoration(
                labelText: '약물 ID',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _totalQuantityController,
              decoration: InputDecoration(
                labelText: '총 처방량',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _durationDaysController,
              decoration: InputDecoration(
                labelText: '처방일수',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Text(
              '복용 패턴',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildDosageRow('아침', 'morning'),
            _buildDosageRow('점심', 'afternoon'),
            _buildDosageRow('저녁', 'evening'),
            _buildDosageRow('취침전', 'before_bed'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('취소'),
        ),
        ElevatedButton(
          onPressed: _addMedication,
          child: Text('추가'),
        ),
      ],
    );
  }

  Widget _buildDosageRow(String label, String key) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  if (_dosagePattern[key] > 0) {
                    _dosagePattern[key]--;
                  }
                });
              },
              icon: Icon(Icons.remove_circle_outline),
            ),
            Container(
              width: 40,
              child: Text(
                '${_dosagePattern[key]}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _dosagePattern[key]++;
                });
              },
              icon: Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }

  void _addMedication() {
    if (_medicationIdController.text.isEmpty ||
        _totalQuantityController.text.isEmpty ||
        _durationDaysController.text.isEmpty) {
      return;
    }

    final medication = MedicationData(
      medicationId: _medicationIdController.text,
      dosagePattern: Map.from(_dosagePattern),
      totalQuantity: int.parse(_totalQuantityController.text),
      durationDays: int.parse(_durationDaysController.text),
    );

    widget.onAdd(medication);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _medicationIdController.dispose();
    _totalQuantityController.dispose();
    _durationDaysController.dispose();
    super.dispose();
  }
}

// HomeScreen에 추가할 만료 알림 위젯
class ExpirationNotificationWidget extends StatelessWidget {
  const ExpirationNotificationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PrescriptionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircularProgressIndicator(strokeWidth: 2),
                SizedBox(width: 16),
                Text('만료 정보 확인 중...'),
              ],
            ),
          );
        }

        if (!provider.hasExpiredCycles && !provider.hasExpiringSoon) {
          return SizedBox.shrink();
        }

        return Container(
          margin: EdgeInsets.all(16),
          child: Column(
            children: [
              // 만료된 처방전들
              if (provider.hasExpiredCycles) ...[
                ...provider.expirationInfo!.expired.map(
                      (cycle) => _buildExpiredNotification(context, cycle),
                ),
              ],
              // 만료 예정 처방전들
              if (provider.hasExpiringSoon) ...[
                ...provider.expirationInfo!.expiringSoon.map(
                      (cycle) => _buildExpiringSoonNotification(context, cycle),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpiredNotification(BuildContext context, ExpiringCycle cycle) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '처방전 만료됨',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
              Text(
                '${cycle.daysOverdue}일 지남',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('복약그룹: ${cycle.groupName}'),
          Text('병원: ${cycle.hospitalName}'),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _navigateToRenewal(context, cycle),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('지금 갱신'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpiringSoonNotification(BuildContext context, ExpiringCycle cycle) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '처방전 만료 예정',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
              Text(
                '${cycle.daysRemaining}일 남음',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('복약그룹: ${cycle.groupName}'),
          Text('병원: ${cycle.hospitalName}'),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _navigateToRenewal(context, cycle),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: Text('미리 갱신'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToRenewal(BuildContext context, ExpiringCycle cycle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PrescriptionRenewalScreen(
          expiringCycle: cycle,
        ),
      ),
    );
  }
}