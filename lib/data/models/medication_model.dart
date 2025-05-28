class MedicationModel {
  final int itemSeq;
  final String itemName;
  final String entpName;
  final String? itemImage;
  final String className;
  final String dosageForm;
  final bool isPrescription;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicationModel({
    required this.itemSeq,
    required this.itemName,
    required this.entpName,
    this.itemImage,
    required this.className,
    required this.dosageForm,
    required this.isPrescription,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      itemSeq: json['item_seq'],
      itemName: json['item_name'],
      entpName: json['entp_name'],
      itemImage: json['item_image'],
      className: json['class_name'] ?? '',
      dosageForm: json['dosage_form'] ?? '',
      isPrescription: json['is_prescription'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}


class TodayMedicationStatus {
  final int taken;
  final int missed;
  final int pending;
  final double completionRate;

  TodayMedicationStatus({
    required this.taken,
    required this.missed,
    required this.pending,
    required this.completionRate,
  });
}