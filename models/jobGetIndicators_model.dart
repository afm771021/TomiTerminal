// To parse this JSON data, do
//
//     final jobGetIndicators = jobGetIndicatorsFromJson(jsonString);

import 'dart:convert';

JobGetIndicators jobGetIndicatorsFromJson(String str) => JobGetIndicators.fromJson(json.decode(str));

String jobGetIndicatorsToJson(JobGetIndicators data) => json.encode(data.toJson());

class JobGetIndicators {
  JobGetIndicators({
    required this.totalTags,
    required this.countedTags,
    required this.missingTags,
    required this.totalAmount,
    required this.totalQuantity,
    required this.totalHours,
    required this.totalAuditedTags,
    required this.auditInProgressTags,
    required this.employeeProductivity,
    required this.departments,
    required this.totalDepartments,
    required this.releasedDepartments,
    required this.inProgressDepartments,
    required this.completedDepartments,
  });

  double totalTags;
  double countedTags;
  double missingTags;
  double totalAmount;
  double totalQuantity;
  double totalHours;
  double totalAuditedTags;
  double auditInProgressTags;
  EmployeeProductivity employeeProductivity;
  List<Department> departments;
  double totalDepartments;
  double releasedDepartments;
  double inProgressDepartments;
  double completedDepartments;

  factory JobGetIndicators.fromJson(Map<String, dynamic> json) => JobGetIndicators(
    totalTags: json["totalTags"],
    countedTags: json["countedTags"],
    missingTags: json["missingTags"],
    totalAmount: json["totalAmount"].toDouble(),
    totalQuantity: json["totalQuantity"],
    totalHours: json["totalHours"].toDouble(),
    totalAuditedTags: json["totalAuditedTags"],
    auditInProgressTags: json["auditInProgressTags"],
    employeeProductivity: EmployeeProductivity.fromJson(json["employeeProductivity"]),
    departments: List<Department>.from(json["departments"].map((x) => Department.fromJson(x))),
    totalDepartments: json["totalDepartments"] ?? 0,
    releasedDepartments: json["releasedDepartments"] ?? 0,
    inProgressDepartments: json["inProgressDepartments"] ?? 0,
    completedDepartments: json["completedDepartments"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "totalTags": totalTags,
    "countedTags": countedTags,
    "missingTags": missingTags,
    "totalAmount": totalAmount,
    "totalQuantity": totalQuantity,
    "totalHours": totalHours,
    "totalAuditedTags": totalAuditedTags,
    "auditInProgressTags": auditInProgressTags,
    "employeeProductivity": employeeProductivity.toJson(),
    "departments": List<dynamic>.from(departments.map((x) => x.toJson())),
    "totalDepartments": totalDepartments,
    "releasedDepartments": releasedDepartments,
    "inProgressDepartments": inProgressDepartments,
    "completedDepartments": completedDepartments,
  };
}

class Department {
  Department({
    required this.customerId,
    required this.storeId,
    required this.stockDate,
    required this.departmentId,
    required this.departmentName,
    required this.countedQty,
    required this.stockQty,
    required this.advance,
  });

  double customerId;
  double storeId;
  DateTime stockDate;
  String departmentId;
  String departmentName;
  double countedQty;
  double stockQty;
  double advance;

  factory Department.fromJson(Map<String, dynamic> json) => Department(
    customerId: json["customerId"],
    storeId: json["storeId"],
    stockDate: DateTime.parse(json["stockDate"]),
    departmentId: json["departmentId"],
    departmentName: json["departmentName"],
    countedQty: json["countedQty"],
    stockQty: json["stockQty"].toDouble(),
    advance: json["advance"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "customerId": customerId,
    "storeId": storeId,
    "stockDate": stockDate.toIso8601String(),
    "departmentId": departmentId,
    "departmentName": departmentName,
    "countedQty": countedQty,
    "stockQty": stockQty,
    "advance": advance,
  };
}

class EmployeeProductivity {
  EmployeeProductivity({
    required this.labels,
    required this.series,
  });

  List<String> labels;
  List<List<double>> series;

  factory EmployeeProductivity.fromJson(Map<String, dynamic> json) => EmployeeProductivity(
    labels: List<String>.from(json["labels"].map((x) => x == null ? 'null' : x)),
    series: List<List<double>>.from(json["series"].map((x) => List<double>.from(x.map((x) => x.toDouble())))),
  );

  Map<String, dynamic> toJson() => {
    "labels": List<dynamic>.from(labels.map((x) => x == null ? null : x)),
    "series": List<dynamic>.from(series.map((x) => List<dynamic>.from(x.map((x) => x)))),
  };
}
