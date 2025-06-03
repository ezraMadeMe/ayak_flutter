import 'package:yakunstructuretest/data/models/medication_model.dart';

class MedicationDetailModel {
  final int id;
  final int cycleId;
  final MedicationModel medication;
  final String dosageInterval;
  final int frequencyPerInterval;
  final double quantityPerDose;
  final int totalPrescribed;
  final int remainingQuantity;
  final String unit;
  final String specialInstructions;
  final Map<String, dynamic>? actualDosagePattern;
  final Map<String, dynamic>? patientAdjustments;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicationDetailModel({
    required this.id,
    required this.cycleId,
    required this.medication,
    required this.dosageInterval,
    required this.frequencyPerInterval,
    required this.quantityPerDose,
    required this.totalPrescribed,
    required this.remainingQuantity,
    required this.unit,
    required this.specialInstructions,
    required this.actualDosagePattern,
    required this.patientAdjustments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicationDetailModel.fromJson(Map<String, dynamic> json) {
    return MedicationDetailModel(
      id: json['id'],
      cycleId: json['cycle_id'],
      medication: MedicationModel.fromJson(json['medication']),
      dosageInterval: json['dosage_interval'],
      frequencyPerInterval: json['frequency_per_interval'],
      quantityPerDose: json['quantity_per_dose'].toDouble(),
      totalPrescribed: json['total_prescribed'],
      remainingQuantity: json['remaining_quantity'],
      unit: json['unit'],
      specialInstructions: json['special_instructions'] ?? '',
      actualDosagePattern: json['actual_dosage_pattern'] ?? {},
      patientAdjustments: json['patient_adjustments'] ?? {},
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'cycle_id': cycleId,
    'medication': medication.toJson(),
    'dosage_interval': dosageInterval,
    'frequency_per_interval': frequencyPerInterval,
    'quantity_per_dose': quantityPerDose,
    'total_prescribed': totalPrescribed,
    'remaining_quantity': remainingQuantity,
    'unit': unit,
    'special_instructions': specialInstructions,
    'actual_dosage_pattern': actualDosagePattern,
    'patient_adjustments': patientAdjustments,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}