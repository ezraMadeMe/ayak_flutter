
// 복약 사이클 모델
import 'package:yakunstructuretest/data/models/medication_detail_model.dart';
import 'package:yakunstructuretest/data/models/medication_group_model.dart';

class MedicationCycleModel {
  final int id;
  final MedicationGroupModel group;
  final int cycleNumber;
  final DateTime cycleStart;
  final DateTime? cycleEnd;
  final DateTime prescriptionDate;
  final DateTime? nextVisitDate;
  final String notes;
  final List<MedicationDetailModel> medicationDetails;

  MedicationCycleModel({
    required this.id,
    required this.group,
    required this.cycleNumber,
    required this.cycleStart,
    this.cycleEnd,
    required this.prescriptionDate,
    this.nextVisitDate,
    required this.notes,
    required this.medicationDetails,
  });

  factory MedicationCycleModel.fromJson(Map<String, dynamic> json) {
    return MedicationCycleModel(
      id: json['id'],
      group: MedicationGroupModel.fromJson(json['group']),
      cycleNumber: json['cycle_number'],
      cycleStart: DateTime.parse(json['cycle_start']),
      cycleEnd: json['cycle_end'] != null ? DateTime.parse(json['cycle_end']) : null,
      prescriptionDate: DateTime.parse(json['prescription_date']),
      nextVisitDate: json['next_visit_date'] != null ? DateTime.parse(json['next_visit_date']) : null,
      notes: json['notes'] ?? '',
      medicationDetails: (json['medication_details'] as List)
          .map((detail) => MedicationDetailModel.fromJson(detail))
          .toList(),
    );
  }
}