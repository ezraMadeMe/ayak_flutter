class PrescriptionRenewalRequest {
  final String userId;
  final String hospitalId;
  final String illnessId;
  final String? oldPrescriptionId;
  final DateTime prescriptionDate;
  final List<MedicationData> medications;

  PrescriptionRenewalRequest({
    required this.userId,
    required this.hospitalId,
    required this.illnessId,
    this.oldPrescriptionId,
    required this.prescriptionDate,
    required this.medications,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'hospital_id': hospitalId,
      'illness_id': illnessId,
      'old_prescription_id': oldPrescriptionId,
      'prescription_date': prescriptionDate.toIso8601String().split('T')[0],
      'medications': medications.map((med) => med.toJson()).toList(),
    };
  }
}

class MedicationData {
  final String medicationId;
  final Map<String, dynamic> dosagePattern;
  final int totalQuantity;
  final int durationDays;

  MedicationData({
    required this.medicationId,
    required this.dosagePattern,
    required this.totalQuantity,
    required this.durationDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'medication_id': medicationId,
      'dosage_pattern': dosagePattern,
      'total_quantity': totalQuantity,
      'duration_days': durationDays,
    };
  }
}

class CycleExpirationInfo {
  final List<ExpiringCycle> expiringSoon;
  final List<ExpiringCycle> expired;
  final bool needsRenewal;

  CycleExpirationInfo({
    required this.expiringSoon,
    required this.expired,
    required this.needsRenewal,
  });

  factory CycleExpirationInfo.fromJson(Map<String, dynamic> json) {
    return CycleExpirationInfo(
      expiringSoon: (json['expiring_soon'] as List)
          .map((item) => ExpiringCycle.fromJson(item))
          .toList(),
      expired: (json['expired'] as List)
          .map((item) => ExpiringCycle.fromJson(item))
          .toList(),
      needsRenewal: json['needs_renewal'] ?? false,
    );
  }
}

class ExpiringCycle {
  final int cycleId;
  final String groupId;
  final String groupName;
  final DateTime cycleEnd;
  final int? daysRemaining;
  final int? daysOverdue;
  final String hospitalName;
  final String prescriptionId;

  ExpiringCycle({
    required this.cycleId,
    required this.groupId,
    required this.groupName,
    required this.cycleEnd,
    this.daysRemaining,
    this.daysOverdue,
    required this.hospitalName,
    required this.prescriptionId,
  });

  factory ExpiringCycle.fromJson(Map<String, dynamic> json) {
    return ExpiringCycle(
      cycleId: json['cycle_id'],
      groupId: json['group_id'],
      groupName: json['group_name'],
      cycleEnd: DateTime.parse(json['cycle_end']),
      daysRemaining: json['days_remaining'],
      daysOverdue: json['days_overdue'],
      hospitalName: json['hospital_name'],
      prescriptionId: json['prescription_id'],
    );
  }

  bool get isExpired => daysOverdue != null && daysOverdue! > 0;
  bool get isExpiringSoon => daysRemaining != null && daysRemaining! <= 7;
}
