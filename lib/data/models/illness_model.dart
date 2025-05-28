class IllnessModel {
  final String illnessId;
  final String userId;
  final String illType;
  final String illName;
  final String illCode;
  final DateTime? illStart;
  final DateTime? illEnd;
  final bool isChronic;
  final DateTime createdAt;
  final DateTime updatedAt;

  IllnessModel({
    required this.illnessId,
    required this.userId,
    required this.illType,
    required this.illName,
    required this.illCode,
    this.illStart,
    this.illEnd,
    required this.isChronic,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IllnessModel.fromJson(Map<String, dynamic> json) {
    return IllnessModel(
      illnessId: json['illness_id'],
      userId: json['user_id'],
      illType: json['ill_type'],
      illName: json['ill_name'],
      illCode: json['ill_code'] ?? '',
      illStart: json['ill_start'] != null ? DateTime.parse(json['ill_start']) : null,
      illEnd: json['ill_end'] != null ? DateTime.parse(json['ill_end']) : null,
      isChronic: json['is_chronic'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}