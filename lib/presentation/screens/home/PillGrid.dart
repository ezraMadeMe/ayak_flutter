import 'package:flutter/material.dart';
import 'package:yakunstructuretest/core/constants/app_colors.dart';

// 알약 데이터 모델
class PillData {
  final String name;
  final Color color;
  final String shape; // 'round', 'oval', 'capsule'
  final String? imageUrl;

  PillData({
    required this.name,
    required this.color,
    required this.shape,
    this.imageUrl,
  });
}

// 알약 그리드 위젯
class MedicationGridWidget extends StatefulWidget {
  final List<String> medicationSequence;
  final int columnsPerRow;
  final Function(String medication, int index)? onPillTap;

  const MedicationGridWidget({
    Key? key,
    required this.medicationSequence,
    this.columnsPerRow = 6,
    this.onPillTap,
  }) : super(key: key);

  @override
  State<MedicationGridWidget> createState() => _MedicationGridWidgetState();
}

class _MedicationGridWidgetState extends State<MedicationGridWidget>
    with TickerProviderStateMixin {
  int? selectedIndex;
  late AnimationController _animationController;

  // 알약 데이터 맵
  static final Map<String, PillData> medicationData = {
    '낙센': PillData(
      name: '낙센',
      imageUrl: Image.asset('assets/images/IMG_20201202_001106.png').toString(),
      color: Color(0xFF4ECDC4),
      shape: 'oval',
    ),
    '아스피린': PillData(
      name: '아스피린',
      color: Color(0xFF96CEB4),
      shape: 'round',
    ),
    '애드빌': PillData(
      name: '애드빌',
      color: Color(0xFFFF6B35),
      shape: 'oval',
    ),
    '타이레놀': PillData(
      name: '타이레놀',
      color: Colors.white,
      shape: 'round',
    ),
    '펜잘큐': PillData(
      name: '펜잘큐',
      color: Color(0xFF45B7D1),
      shape: 'round',
    ),
    '오메프라졸': PillData(
      name: '오메프라졸',
      color: Color(0xFFDDA0DD),
      shape: 'capsule',
    ),
  };

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
      //margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGrid(),
          if (selectedIndex != null) ...[
            SizedBox(height: 16),
            _buildSelectedPillInfo(),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '복약 시각화',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              '8×2 그리드 배열',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '총 ${widget.medicationSequence.length}개',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    final medicationCounts = <String, int>{};
    for (String med in widget.medicationSequence) {
      medicationCounts[med] = (medicationCounts[med] ?? 0) + 1;
    }

    final sortedMedications = medicationCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '약품별 개수',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sortedMedications.map((entry) {
              final pillData = medicationData[entry.key];
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: pillData?.color.withOpacity(0.3) ?? Colors.grey,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMiniPill(pillData),
                    SizedBox(width: 6),
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: pillData?.color.withOpacity(0.2) ?? Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${entry.value}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: pillData?.color == Colors.white
                              ? Colors.black87
                              : pillData?.color.withOpacity(0.8) ?? Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPill(PillData? pillData) {
    if (pillData == null) return SizedBox(width: 12, height: 12);

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: pillData.color,
        border: pillData.color == Colors.white
            ? Border.all(color: Colors.grey.withOpacity(0.5))
            : null,
        borderRadius: BorderRadius.circular(
          pillData.shape == 'round' ? 6 :
          pillData.shape == 'capsule' ? 6 :
          3, // oval
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final rows = <List<String>>[];
    for (int i = 0; i < widget.medicationSequence.length; i += widget.columnsPerRow) {
      final endIndex = (i + widget.columnsPerRow > widget.medicationSequence.length)
          ? widget.medicationSequence.length
          : i + widget.columnsPerRow;
      rows.add(widget.medicationSequence.sublist(i, endIndex));
    }

    return Container(
      //padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Column(
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
          ),
        ],
      ),
    );
  }

  Widget _buildPillWidget(String medication, int index) {
    final pillData = medicationData[medication];
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = isSelected ? null : index;
        });

        if (widget.onPillTap != null) {
          widget.onPillTap!(medication, index);
        }

        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
        decoration: BoxDecoration(
          color: pillData?.color ?? Colors.grey,
          border: pillData?.color == Colors.white
              ? Border.all(color: Colors.grey.withOpacity(0.5), width: 1.5)
              : isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
          borderRadius: BorderRadius.circular(
            pillData?.shape == 'round' ? 50 :
            pillData?.shape == 'capsule' ? 12 :
            8, // oval
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                medication,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: pillData?.color == Colors.white
                      ? Colors.black87
                      : Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 8,
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
        border: Border.all(color: Colors.grey.withOpacity(0.3), style: BorderStyle.solid),
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

  Widget _buildSelectedPillInfo() {
    if (selectedIndex == null) return SizedBox.shrink();

    final medication = widget.medicationSequence[selectedIndex!];
    final pillData = medicationData[medication];

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: pillData?.color ?? Colors.grey,
              border: pillData?.color == Colors.white
                  ? Border.all(color: Colors.grey.withOpacity(0.5))
                  : null,
              borderRadius: BorderRadius.circular(
                pillData?.shape == 'round' ? 20 :
                pillData?.shape == 'capsule' ? 8 :
                10, // oval
              ),
            ),
            child: Center(
              child: Text(
                medication,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: pillData?.color == Colors.white
                      ? Colors.black87
                      : Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '위치: ${selectedIndex! + 1}번째 • 형태: ${pillData?.shape ?? "알 수 없음"}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                selectedIndex = null;
              });
            },
            icon: Icon(Icons.close, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// 사용 예시 화면
class MedicationGridScreen extends StatefulWidget {
  @override
  _MedicationGridScreenState createState() => _MedicationGridScreenState();
}

class _MedicationGridScreenState extends State<MedicationGridScreen> {
  List<String> medicationSequence = [
    '낙센', '낙센', '아스피린', '애드빌', '애드빌', '애드빌', '타이레놀', '타이레놀',
    '타이레놀', '타이레놀', '펜잘큐', '오메프라졸'
  ];

  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = medicationSequence.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('알약 그리드 시스템'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 입력 섹션
              Container(
                margin: EdgeInsets.all(16),
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
                      '약품 시퀀스 입력',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _textController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: '약품명을 공백으로 구분하여 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _updateSequence,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('그리드 업데이트'),
                    ),
                  ],
                ),
              ),

              // 그리드 위젯
              MedicationGridWidget(
                medicationSequence: medicationSequence,
                columnsPerRow: 8,
                onPillTap: (medication, index) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$medication (${index + 1}번째) 선택됨'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _updateSequence() {
    final newSequence = _textController.text
        .split(RegExp(r'\s+'))
        .where((med) => med.isNotEmpty && _MedicationGridWidgetState.medicationData.containsKey(med))
        .toList();

    setState(() {
      medicationSequence = newSequence;
    });

    if (newSequence.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('유효한 약품명이 없습니다'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}