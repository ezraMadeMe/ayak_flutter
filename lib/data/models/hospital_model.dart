// models/hospital_model.dart
import 'package:xml/xml.dart';

class Hospital {
  final String? hospitalId;
  final String? userId;
  final String? hospCode;
  final String hospName;
  final String? hospType;
  final String? doctorName;
  final String? address;
  final String? phoneNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Hospital({
    this.hospitalId,
    this.userId,
    this.hospCode,
    required this.hospName,
    this.hospType,
    this.doctorName,
    this.address,
    this.phoneNumber,
    this.createdAt,
    this.updatedAt,
  });

  factory Hospital.fromXml(XmlElement xml) {
    String? getValue(String tag) {
      final element = xml.getElement(tag);
      final text = element?.innerText;
      return (text != null && text.isNotEmpty) ? text : null;
    }

    return Hospital(
      hospName: getValue('yadmNm') ?? '',
      address: getValue('addr'),
      phoneNumber: getValue('telno'),
      hospType: getValue('clCdNm'),
      hospCode: getValue('ykiho'), // 병원 고유 코드
    );
  }

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      hospitalId: json['hospital_id'],
      userId: json['user_id'],
      hospCode: json['hosp_code'],
      hospName: json['hosp_name'] ?? '',
      hospType: json['hosp_type'],
      doctorName: json['doctor_name'],
      address: json['address'],
      phoneNumber: json['phone_number'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hospital_id': hospitalId,
      'user_id': userId,
      'hosp_code': hospCode,
      'hosp_name': hospName,
      'hosp_type': hospType,
      'doctor_name': doctorName,
      'address': address,
      'phone_number': phoneNumber?.replaceAll('-', ''),
    };
  }
}