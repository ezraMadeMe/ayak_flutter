class HospitalModel {
  final String hospitalId;
  final String userId;
  final String hospCode;
  final String hospName;
  final String hospType;
  final String doctorName;
  final String address;
  final String phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  HospitalModel({
    required this.hospitalId,
    required this.userId,
    required this.hospCode,
    required this.hospName,
    required this.hospType,
    required this.doctorName,
    required this.address,
    required this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      hospitalId: json['hospital_id'],
      userId: json['user_id'],
      hospCode: json['hosp_code'] ?? '',
      hospName: json['hosp_name'] ?? '',
      hospType: json['hosp_type'] ?? '',
      doctorName: json['doctor_name'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}