// To parse this JSON data, do
//
//     final jobAudit = jobAuditFromJson(jsonString);

import 'dart:convert';

JobAudit jobAuditFromJson(String str) => JobAudit.fromJson(json.decode(str));

String jobAuditToJson(JobAudit data) => json.encode(data.toJson());

class JobAudit {
  JobAudit({
    required this.userName,
    required this.inventoryKey,
    required this.created_At,
  });

  String userName;
  String inventoryKey;
  DateTime created_At;

  factory JobAudit.fromJson(Map<String, dynamic> json) => JobAudit(
    userName: json["userName"],
    inventoryKey: json["inventoryKey"],
    created_At: DateTime.parse(json["created_At"]),
  );

  Map<String, dynamic> toJson() => {
    "userName": userName,
    "inventoryKey": inventoryKey,
    "created_At": "${created_At.year.toString().padLeft(4, '0')}-${created_At.month.toString().padLeft(2, '0')}-${created_At.day.toString().padLeft(2, '0')}",
  };
}
