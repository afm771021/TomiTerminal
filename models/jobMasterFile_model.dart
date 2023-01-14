// To parse this JSON data, do
//
//     final jobMasterFile = jobMasterFileFromJson(jsonString);

import 'dart:convert';

JobMasterFile jobMasterFileFromJson(String str) => JobMasterFile.fromJson(json.decode(str));

String jobMasterFileToJson(JobMasterFile data) => json.encode(data.toJson());

class JobMasterFile {
  JobMasterFile({
    required this.department,
    required this.code,
    required this.salePrice,
    required this.inventoryKey,
    required this.description,
  });

  String department;
  String code;
  double salePrice;
  String inventoryKey;
  String description;

  factory JobMasterFile.fromJson(Map<String, dynamic> json) => JobMasterFile(
    department: json["department"],
    code: json["code"] ?? '',
    salePrice: json["salePrice"],
    inventoryKey: json["inventoryKey"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "Department": department,
    "Code": code,
    "SalePrice": salePrice,
    "InventoryKey": inventoryKey,
    "Description": description,
  };
}
