
import 'package:yakunstructuretest/data/models/medication_detail_model.dart';
import 'package:yakunstructuretest/data/models/medication_group_model.dart';
import 'package:yakunstructuretest/data/models/medication_item.dart';
import 'package:yakunstructuretest/presentation/providers/enhanced_medication_provider.dart';

class MedicationRecordModel {
  final int id;
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'medication_detail': medicationDetail.toJson(),
    'record_type': recordType,
    'record_date': recordDate.toIso8601String(),
    'quantity_taken': quantityTaken,
    'notes': notes,
    'symptoms': symptoms,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
