import 'package:yakunstructuretest/core/api/api_service.dart';
import 'package:yakunstructuretest/data/models/medication_detail_model.dart';
import 'package:yakunstructuretest/data/models/medication_group_model.dart';
import 'package:yakunstructuretest/data/models/medication_item.dart';
import 'package:yakunstructuretest/presentation/providers/enhanced_medication_provider.dart';

class MedicationRecordModel {
  final int id;
  final int cycleId;
  final MedicationDetailModel medicationDetail;
  final String recordType;
  final DateTime recordDate;
  final double quantityTaken;
  final String notes;
  final String symptoms;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicationRecordModel({
    required this.id,
    required this.cycleId,
    required this.medicationDetail,
    required this.recordType,
    required this.recordDate,
    required this.quantityTaken,
    required this.notes,
    required this.symptoms,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicationRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicationRecordModel(
      id: json['id'],
      cycleId: json['cycle_id'],
      medicationDetail: MedicationDetailModel.fromJson(json['medication_detail']),
      recordType: json['record_type'],
      recordDate: DateTime.parse(json['record_date']),
      quantityTaken: json['quantity_taken'].toDouble(),
      notes: json['notes'] ?? '',
      symptoms: json['symptoms'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
