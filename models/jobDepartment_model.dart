// To parse this JSON data, do
//
//     final jobDepartment = jobDepartmentFromJson(jsonString);

import 'dart:convert';

JobDepartment jobDepartmentFromJson(String str) => JobDepartment.fromJson(json.decode(str));

String jobDepartmentToJson(JobDepartment data) => json.encode(data.toJson());

class JobDepartment {
  JobDepartment({
     this.depId,
     this.inventoryKey,
  });

  String? depId;
  String? inventoryKey;

  factory JobDepartment.fromJson(Map<String, dynamic> json) => JobDepartment(
    depId: json["depId"] ?? "",
    inventoryKey: json["inventoryKey"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "depId": depId,
    "inventoryKey": inventoryKey,
  };
}
