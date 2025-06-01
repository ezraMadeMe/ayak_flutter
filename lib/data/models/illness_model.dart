// models/illness_model.dart
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class Illness {
  final String? illnessId;
  final String? userId;
  final String illType; // DISEASE 또는 SYMPTOM
  final String illName;
  final String? illCode; // ICD-10 코드
  final DateTime? illStart;
  final DateTime? illEnd;
  final bool isChronic;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Illness({
    this.illnessId,
    this.userId,
    required this.illType,
    required this.illName,
    this.illCode,
    this.illStart,
    this.illEnd,
    this.isChronic = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Illness.fromXml(XmlElement xml) {
    String? getValue(String tag) {
      final element = xml.getElement(tag);
      final text = element?.innerText;
      return (text != null && text.isNotEmpty) ? text : null;
    }

    return Illness(
      illType: 'DISEASE', // API에서 가져온 것은 질병으로 분류
      illName: getValue('sickNm') ?? '',
      illCode: getValue('sickCd'),
    );
  }

  factory Illness.fromJson(Map<String, dynamic> json) {
    return Illness(
      illnessId: json['illness_id'],
      userId: json['user_id'],
      illType: json['ill_type'] ?? 'DISEASE',
      illName: json['ill_name'] ?? '',
      illCode: json['ill_code'],
      illStart: json['ill_start'] != null ? DateTime.parse(json['ill_start']) : null,
      illEnd: json['ill_end'] != null ? DateTime.parse(json['ill_end']) : null,
      isChronic: json['is_chronic'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'illness_id': illnessId,
      'user_id': userId,
      'ill_type': illType,
      'ill_name': illName,
      'ill_code': illCode,
      'ill_start': illStart?.toIso8601String().split('T')[0],
      'ill_end': illEnd?.toIso8601String().split('T')[0],
      'is_chronic': isChronic,
    };
  }

  bool get isDisease => illType == 'DISEASE';
  bool get isSymptom => illType == 'SYMPTOM';

  String get displayType => isDisease ? '질병' : '증상';

  IconData get iconData => isDisease ? Icons.local_hospital : Icons.healing;
}
