
// 복약 그룹 모델
import 'package:yakunstructuretest/data/models/user_model.dart';

class MedicationGroupModel {
  final String groupId;
  final String groupName;
  final UserMedicalInfoModel medicalInfo;
  final bool isActive;
  final DateTime createdAt;

  MedicationGroupModel({
    required this.groupId,
    required this.groupName,
    required this.medicalInfo,
    required this.isActive,
    required this.createdAt,
  });

  factory MedicationGroupModel.fromJson(Map<String, dynamic> json) {
    return MedicationGroupModel(
      groupId: json['group_id'],
      groupName: json['group_name'],
      medicalInfo: UserMedicalInfoModel.fromJson(json['medical_info']),
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}