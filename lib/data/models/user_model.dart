
// 사용자 모델
import 'package:yakunstructuretest/data/models/hospital_model.dart';
import 'package:yakunstructuretest/data/models/illness_model.dart';

class UserModel {
  final String userId;
  final String userName;
  final DateTime joinDate;
  final bool pushAgree;
  final bool isActive;

  UserModel({
    required this.userId,
    required this.userName,
    required this.joinDate,
    required this.pushAgree,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      userName: json['user_name'],
      joinDate: DateTime.parse(json['join_date']),
      pushAgree: json['push_agree'],
      isActive: json['is_active'],
    );
  }
}

class UserMedicalInfoModel {
  final int id;
  final String userId;
  final Hospital hospital;
  final Illness illness;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserMedicalInfoModel({
    required this.id,
    required this.userId,
    required this.hospital,
    required this.illness,
    required this.isPrimary,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserMedicalInfoModel.fromJson(Map<String, dynamic> json) {
    return UserMedicalInfoModel(
      id: json['id'],
      userId: json['user_id'],
      hospital: Hospital.fromJson(json['hospital']),
      illness: Illness.fromJson(json['illness']),
      isPrimary: json['is_primary'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
