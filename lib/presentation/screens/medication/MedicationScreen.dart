import 'package:flutter/material.dart';
import 'package:yakunstructuretest/data/models/medication_detail_model.dart';
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
}
