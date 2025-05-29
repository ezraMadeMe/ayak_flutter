import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yakunstructuretest/data/models/medication_detail_model.dart';
import 'package:yakunstructuretest/data/models/medication_record_model.dart';
import 'package:yakunstructuretest/presentation/providers/medication_provider.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicationProvider>().loadTodayMedications();
      context.read<MedicationProvider>().loadMedicationRecords();
    });
  }

  Widget _buildMedicationHistoryTab() {
    return Consumer<MedicationProvider>(
      builder: (context, provider, _) {
        final allRecords = provider.getAllMedicationRecords();
        if (allRecords.isEmpty) {
          return Center(
            child: Text(
              '복약 기록이 없습니다.',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          );
        }
        Map<DateTime, List<MedicationRecordModel>> groupedRecords = {}; // Assuming MedicationRecordModel
        for (var record in allRecords) {
          DateTime recordDate = DateTime(record.recordDate.year, record.recordDate.month, record.recordDate.day);
          if (groupedRecords[recordDate] == null) {
            groupedRecords[recordDate] = [];
          }
          groupedRecords[recordDate]!.add(record);
        }

        // Sort dates in descending order (most recent first)
        List<DateTime> sortedDates = groupedRecords.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            DateTime date = sortedDates[index];
            List<MedicationRecordModel> recordsForDate = groupedRecords[date]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(date),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                  ),
                ),
                ...recordsForDate.map((record) {
                  // You'll need to fetch medication details if your record only has an ID
                  // For simplicity, I'm assuming the record or provider can give the name.
                  // This part heavily depends on your data model.
                  // Let's assume provider.getMedicationDetailsById(record.medicationId).medication.itemName
                  // Or that your MedicationRecordModel has enough info.

                  // Placeholder: Try to get medication name
                  String medicationName = "알 수 없는 약"; // Default
                  MedicationDetailModel? medDetail = provider.getMedicationDetailById(record.id);
                  if (medDetail != null) {
                    medicationName = medDetail.medication.itemName;
                  }


                  String statusText = "";
                  Color statusColor = Colors.grey;
                  IconData statusIcon = Icons.help_outline;

                  switch (record.recordType) {
                    case RecordType.taken:
                      statusText = '복용 완료';
                      statusColor = Colors.green;
                      statusIcon = Icons.check_circle_outline;
                      break;
                    case RecordType.missed:
                      statusText = '복용 누락';
                      statusColor = Colors.red;
                      statusIcon = Icons.highlight_off;
                      break;
                    case RecordType.skipped: // Example of another type
                      statusText = '건너뜀';
                      statusColor = Colors.orange;
                      statusIcon = Icons.skip_next_outlined;
                      break;
                    default:
                      statusText = '상태 알 수 없음';
                  }

                  return Card(
                    margin: EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      leading: Icon(statusIcon, color: statusColor, size: 28),
                      title: Text(medicationName),
                      subtitle: Text(
                          '시간: ${DateFormat('HH:mm').format(record.updatedAt)} \n상태: $statusText'
                        // Add more details if needed, e.g., record.notes
                      ),
                      trailing: Text(
                        DateFormat('HH:mm').format(record.updatedAt), // Or record.time if stored separately
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      // You could add an onTap to view more details if needed
                    ),
                  );
                }).toList(),
                if (index < sortedDates.length - 1) Divider(thickness: 1.0),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTodayMedicationSummary(MedicationProvider provider) {
    // Get the medications for the selected date
    final medicationsForSelectedDate = provider.getTodayMedications(_selectedDate);

    if (medicationsForSelectedDate.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '오늘은 복용할 약이 없습니다.',
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      );
    }

    int totalMedications = medicationsForSelectedDate.length;
    int takenCount = 0;
    int missedCount = 0;

    for (var medDetail in medicationsForSelectedDate) {
      final record = provider.getMedicationRecord(_selectedDate, medDetail.id);
      if (record != null) {
        if (record.recordType == RecordType.taken) { // Assuming RecordType.taken
          takenCount++;
        } else if (record.recordType == RecordType.missed) { // Assuming RecordType.missed
          missedCount++;
        }
      }
    }

    int pendingCount = totalMedications - takenCount - missedCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '오늘의 복약 현황',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryItem('총 예정', totalMedications, Colors.blueGrey),
                  _buildSummaryItem('복용 완료', takenCount, Colors.green),
                  _buildSummaryItem('복용 예정', pendingCount, Colors.orange),
                  _buildSummaryItem('누락', missedCount, Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(Duration(days: 1));
              });
              // You might want to call a method on your provider here
              // to update data based on the new _selectedDate
            },
          ),
          TextButton(
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000), // Or some other appropriate start date
                lastDate: DateTime(2101),  // Or some other appropriate end date
              );
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                });
                // You might want to call a method on your provider here
                // to update data based on the new _selectedDate
              }
            },
            child: Text(
              DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(_selectedDate), // Example: 2023년 10월 27일 (금)
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(Duration(days: 1));
              });
              // You might want to call a method on your provider here
              // to update data based on the new _selectedDate
            },
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('복약 관리'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '오늘 복약'),
            Tab(text: '복약 기록'),
            Tab(text: '통계'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayMedicationTab(),
          _buildMedicationHistoryTab(),
          _buildMedicationStatisticsTab(),
        ],
      ),
    );
  }

  Widget _buildTodayMedicationTab() {
    return Consumer<MedicationProvider>(
      builder: (context, provider, _) => Column(
        children: [
          // 날짜 선택기
          _buildDateSelector(),

          // 오늘의 복약 현황 요약
          _buildTodayMedicationSummary(provider),

          // 복약 체크리스트
          Expanded(
            child: _buildMedicationChecklist(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationChecklist(MedicationProvider provider) {
    final todayMedications = provider.getTodayMedications(_selectedDate);

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: todayMedications.length,
      itemBuilder: (context, index) {
        final medication = todayMedications[index];
        return _buildMedicationCheckItem(medication, provider);
      },
    );
  }

  Widget _buildMedicationCheckItem(MedicationDetailModel medication, MedicationProvider provider) {
    final record = provider.getMedicationRecord(_selectedDate, medication.id);
    final isCompleted = record?.recordType == RecordType.taken;
    final isMissed = record?.recordType == RecordType.missed;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.withOpacity(0.1) :
        isMissed ? Colors.red.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? Colors.green :
          isMissed ? Colors.red : Colors.grey[300]!,
        ),
      ),
      child: ListTile(
        leading: GestureDetector(
          onTap: () => _toggleMedicationStatus(medication, provider),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green :
              isMissed ? Colors.red : Colors.transparent,
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(6),
            ),
            child: isCompleted ? Icon(Icons.check, color: Colors.white, size: 16) :
            isMissed ? Icon(Icons.close, color: Colors.white, size: 16) : null,
          ),
        ),
        title: Text(medication.medication.itemName),
        subtitle: Text('${medication.quantityPerDose}${medication.unit} • ${medication.specialInstructions}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => _markAsTaken(medication, provider),
              child: Text('복용', style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () => _markAsMissed(medication, provider),
              child: Text('누락', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }


  // 누락된 메서드 1: 복약 통계 탭
  Widget _buildMedicationStatisticsTab() {
    return Consumer<MedicationProvider>(
      builder: (context, provider, _) => SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 전체 통계 카드
            _buildOverallStatisticsCard(provider),
            SizedBox(height: 16),

            // 복용률 차트
            _buildAdherenceChart(provider),
            SizedBox(height: 16),

            // 약물별 통계
            _buildMedicationWiseStatistics(provider),
            SizedBox(height: 16),

            // 주간/월간 트렌드
            _buildTrendAnalysis(provider),
          ],
        ),
      ),
    );
  }


  Widget _buildOverallStatisticsCard(MedicationProvider provider) {
    final status = provider.todayMedicationStatus;
    final totalRecords = provider.getAllMedicationRecords().length;
    final thisWeekRecords = provider.getAllMedicationRecords().where((record) {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      return record.recordDate.isAfter(weekStart);
    }).length;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('전체 복약 통계', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('총 복약 횟수', totalRecords.toString(), Colors.blue, Icons.medication)),
              SizedBox(width: 12),
              Expanded(child: _buildStatCard('이번 주', thisWeekRecords.toString(), Colors.green, Icons.calendar_month)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('복용률', '${(status.completionRate * 100).toInt()}%', Colors.orange, Icons.trending_up)),
              SizedBox(width: 12),
              Expanded(child: _buildStatCard('연속 복용일', '12일', Colors.purple, Icons.local_fire_department)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600]), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildAdherenceChart(MedicationProvider provider) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('최근 7일 복용률', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final rate = [0.8, 0.9, 0.7, 1.0, 0.85, 0.6, 0.95][index];
                return _buildChartBar(rate, '${index + 1}일전');
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(double rate, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: 100 * rate,
          decoration: BoxDecoration(
            color: rate >= 0.8 ? Colors.green : rate >= 0.6 ? Colors.orange : Colors.red,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildMedicationWiseStatistics(MedicationProvider provider) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('약물별 복용 현황', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          ...provider.todayMedications.map((med) => Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.medication, color: Colors.blue),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(med.medication.itemName, style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('최근 7일 복용률: 85%', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Text('85%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysis(MedicationProvider provider) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('트렌드 분석', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          _buildTrendItem('복용률 개선', '지난주 대비 12% 향상', Icons.trending_up, Colors.green),
          _buildTrendItem('규칙성 향상', '정시 복용률이 증가하고 있습니다', Icons.schedule, Colors.blue),
          _buildTrendItem('주의 필요', '주말 복용률이 평일보다 낮습니다', Icons.warning, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildTrendItem(String title, String description, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 누락된 메서드 2: 복약 상태 토글
  void _toggleMedicationStatus(MedicationDetailModel medication, MedicationProvider provider) {
    final record = provider.getMedicationRecord(_selectedDate, medication.id);

    if (record == null || record.recordType != 'TAKEN') {
      _markAsTaken(medication, provider);
    } else {
      _markAsMissed(medication, provider);
    }
  }

  // 누락된 메서드 3: 복용 완료 처리
  void _markAsTaken(MedicationDetailModel medication, MedicationProvider provider) {
    provider.createMedicationRecord(
      cycleId: medication.cycleId,
      medicationDetailId: medication.id,
      recordType: 'TAKEN',
      recordDate: _selectedDate,
      quantityTaken: medication.quantityPerDose,
      notes: '정시 복용 완료',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${medication.medication.itemName} 복용이 기록되었습니다.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // 누락된 메서드 4: 복용 누락 처리
  void _markAsMissed(MedicationDetailModel medication, MedicationProvider provider) {
    provider.createMedicationRecord(
      cycleId: medication.cycleId,
      medicationDetailId: medication.id,
      recordType: 'MISSED',
      recordDate: _selectedDate,
      quantityTaken: 0.0,
      notes: '복용 누락',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${medication.medication.itemName} 복용 누락이 기록되었습니다.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // 기록 타입 표시명 변환
  String _getRecordTypeDisplayName(String recordType) {
    switch (recordType) {
      case 'TAKEN':
        return '복용 완료';
      case 'MISSED':
        return '복용 누락';
      case 'SKIPPED':
        return '건너뜀';
      case 'DELAYED':
        return '지연 복용';
      case 'PARTIAL':
        return '부분 복용';
      default:
        return '알 수 없음';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
