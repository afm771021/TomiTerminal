import 'dart:convert';

AuditDepartmentModel jobAuditDepartmentFromJson(String str) => AuditDepartmentModel.fromJson(json.decode(str));

String jobAuditDepartmentToJson(AuditDepartmentModel data) => json.encode(data.toJson());

class AuditDepartmentModel {
  AuditDepartmentModel({
    this.departmentId,
    this.sectionId,
    this.countSku,
  });

  String? departmentId;
  double? sectionId;
  double? countSku;

  factory AuditDepartmentModel.fromJson(Map<String, dynamic> json) => AuditDepartmentModel(
    departmentId: json["departmentId"] ?? "",
    sectionId : json["sectionId"] ?? "",
    countSku: json["countSku"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "departmentId": departmentId,
    "sectionId" : sectionId,
    "countSku": countSku,
  };
}
