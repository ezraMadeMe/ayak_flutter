import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yakunstructuretest/core/constants/app_colors.dart';
import 'package:yakunstructuretest/data/models/pill_data_model.dart';
import 'package:yakunstructuretest/presentation/providers/enhanced_medication_provider.dart';
import 'package:yakunstructuretest/presentation/providers/medication_provider.dart';

// 복약 기록 타입
enum MedicationRecordAction {
  taken,    // 복용함
  missed,   // 누락
  skipped,  // 건너뜀
  sideEffect, // 부작용
}

extension MedicationRecordActionExtension on MedicationRecordAction {
  String get displayName {
    switch (this) {
      case MedicationRecordAction.taken:
        return '복용함';
      case MedicationRecordAction.missed:
        return '누락';
      case MedicationRecordAction.skipped:
        return '건너뜀';
      case MedicationRecordAction.sideEffect:
        return '부작용';
    }
  }

  String get apiValue {
    switch (this) {
      case MedicationRecordAction.taken:
        return 'TAKEN';
      case MedicationRecordAction.missed:
        return 'MISSED';
      case MedicationRecordAction.skipped:
        return 'SKIPPED';
      case MedicationRecordAction.sideEffect:
        return 'SIDE_EFFECT';
    }
  }

  Color get color {
    switch (this) {
      case MedicationRecordAction.taken:
        return Color(0xFF28A745);
      case MedicationRecordAction.missed:
        return Color(0xFFDC3545);
      case MedicationRecordAction.skipped:
        return Color(0xFFFFC107);
      case MedicationRecordAction.sideEffect:
        return Color(0xFFFF6B35);
    }
  }

  IconData get icon {
    switch (this) {
      case MedicationRecordAction.taken:
        return Icons.check_circle;
      case MedicationRecordAction.missed:
        return Icons.cancel;
      case MedicationRecordAction.skipped:
        return Icons.skip_next;
      case MedicationRecordAction.sideEffect:
        return Icons.warning;
    }
  }
}

// 알약 그리드 위젯
class MedicationGridWidget extends StatefulWidget {
  final String groupId; // 복약그룹 ID
  final int cycleId; // 주기 ID
  final String dosagePattern; // 복약패턴 (아침/점심/저녁/취침전/PRN)
  final List<PillData> medications; // 약물 리스트
  final int columnsPerRow;
  final Function(List<PillData> selectedMedications, MedicationRecordAction action)? onRecordSubmitted;

  const MedicationGridWidget({
    Key? key,
    required this.groupId,
    required this.cycleId,
    required this.dosagePattern,
    required this.medications,
    this.columnsPerRow = 6,
    this.onRecordSubmitted,
  }) : super(key: key);

  @override
  State<MedicationGridWidget> createState() => _MedicationGridWidgetState();
}

class _MedicationGridWidgetState extends State<MedicationGridWidget>
    with TickerProviderStateMixin {
  Set<int> selectedIndices = {};
  bool _isSubmitting = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 16),
          _buildGrid(),
          if (selectedIndices.isNotEmpty) ...[
            SizedBox(height: 16),
            _buildActionButtons(),
          ],
          if (_isSubmitting) ...[
            SizedBox(height: 8),
            _buildLoadingIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '복약그룹 - ${widget.dosagePattern}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '총 ${widget.medications.length}개',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _toggleSelectAll,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isAllSelected
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isAllSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 16,
                  color: _isAllSelected ? Colors.white : AppColors.primary,
                ),
                SizedBox(width: 4),
                Text(
                  '전체 선택',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isAllSelected ? Colors.white : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool get _isAllSelected => selectedIndices.length == widget.medications.length;

  void _toggleSelectAll() {
    setState(() {
      if (_isAllSelected) {
        selectedIndices.clear();
      } else {
        selectedIndices = Set.from(
            List.generate(widget.medications.length, (i) => i)
        );
      }
    });
  }

  Widget _buildGrid() {
    final rows = <List<PillData>>[];
    for (int i = 0; i < widget.medications.length; i += widget.columnsPerRow) {
      final endIndex = (i + widget.columnsPerRow > widget.medications.length)
          ? widget.medications.length
          : i + widget.columnsPerRow;
      rows.add(widget.medications.sublist(i, endIndex));
    }

    return Column(
      children: rows.asMap().entries.map((rowEntry) {
        final rowIndex = rowEntry.key;
        final row = rowEntry.value;

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          child: Row(
            children: List.generate(widget.columnsPerRow, (colIndex) {
              final globalIndex = rowIndex * widget.columnsPerRow + colIndex;
              final medication = colIndex < row.length ? row[colIndex] : null;

              return Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: EdgeInsets.all(2),
                    child: medication != null
                        ? _buildPillWidget(medication, globalIndex)
                        : _buildEmptySlot(),
                  ),
                ),
              );
            }),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPillWidget(PillData medication, int index) {
    final isSelected = selectedIndices.contains(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedIndices.remove(index);
          } else {
            selectedIndices.add(index);
          }
        });

        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: medication.color,
          border: medication.color == Colors.white
              ? Border.all(color: Colors.grey.withOpacity(0.5))
              : null,
          borderRadius: BorderRadius.circular(
            medication.shape == 'round' ? 8 :
            medication.shape == 'capsule' ? 8 :
            4, // oval
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 2,
            )
          ] : null,
        ),
        child: Stack(
          children: [
            if (isSelected)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            Center(
              child: Text(
                medication.name,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: medication.color == Colors.white
                      ? Colors.black87
                      : Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySlot() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          Icons.add,
          size: 16,
          color: Colors.grey.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
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
          Text(
            '선택된 약물 ${selectedIndices.length}개',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: MedicationRecordAction.values.map((action) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  child: _buildActionButton(action),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(MedicationRecordAction action) {
    return GestureDetector(
      onTap: _isSubmitting ? null : () => _submitMedicationRecord(action),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: action.color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(action.icon, color: action.color, size: 24),
            SizedBox(height: 4),
            Text(
              action.displayName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: action.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(width: 12),
          Text(
            '복약 기록을 저장하는 중...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitMedicationRecord(MedicationRecordAction action) async {
    if (selectedIndices.isEmpty || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final selectedMedications = selectedIndices
          .map((index) => widget.medications[index])
          .toList();

      final medicationProvider = context.read<MedicationProvider>();

      // 선택된 각 약물에 대해 복약 기록 생성
      for (final medication in selectedMedications) {
        await medicationProvider.createMedicationRecord(
          cycleId: widget.cycleId,
          medicationDetailId: medication.medicationDetailId,
          recordType: action.apiValue,
          recordDate: DateTime.now(),
          quantityTaken: action == MedicationRecordAction.taken ? 1.0 : 0.0,
          notes: '${widget.dosagePattern} - ${action.displayName}',
          symptoms: action == MedicationRecordAction.sideEffect ? '부작용 보고됨' : '',
        );
      }

      // 성공 시 UI 상태 업데이트
      setState(() {
        selectedIndices.clear();
      });

      // 성공 메시지 표시
      _showSuccessMessage(action, selectedMedications.length);

      // 콜백 호출
      if (widget.onRecordSubmitted != null) {
        widget.onRecordSubmitted!(selectedMedications, action);
      }

    } catch (e) {
      // 에러 처리
      _showErrorMessage(e.toString());
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessMessage(MedicationRecordAction action, int count) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('${action.displayName} 기록이 완료되었습니다 ($count개)'),
          ],
        ),
        backgroundColor: action.color,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text('기록 저장 실패: $error')),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

// 사용 예시
class EnhancedMedicationGridScreen extends StatefulWidget {
  @override
  _EnhancedMedicationGridScreenState createState() => _EnhancedMedicationGridScreenState();
}

class _EnhancedMedicationGridScreenState extends State<EnhancedMedicationGridScreen> {
  List<PillData> medications = [
    PillData(name: '낙센', color: Color(0xFF4ECDC4), shape: 'oval', medicationDetailId: 1),
    PillData(name: '아스피린', color: Color(0xFF96CEB4), shape: 'round', medicationDetailId: 2),
    PillData(name: '애드빌', color: Color(0xFFFF6B35), shape: 'oval', medicationDetailId: 3),
    PillData(name: '타이레놀', color: Colors.white, shape: 'round', medicationDetailId: 4),
    PillData(name: '펜잘큐', color: Color(0xFF45B7D1), shape: 'round', medicationDetailId: 5),
    PillData(name: '오메프라졸', color: Color(0xFFDDA0DD), shape: 'capsule', medicationDetailId: 6),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('복약 기록 시스템'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
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
            ],
          ),
        ),
      ),
    );
  }
}