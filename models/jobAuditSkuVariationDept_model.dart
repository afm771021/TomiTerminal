// To parse this JSON data, do
//
//     final jobAuditSkuVariationDept = jobAuditSkuVariationDeptFromJson(jsonString);

import 'dart:convert';

jobAuditSkuVariationDept jobAuditSkuVariationDeptFromJson(String str) => jobAuditSkuVariationDept.fromJson(json.decode(str));

String jobAuditSkuVariationDeptToJson(jobAuditSkuVariationDept data) => json.encode(data.toJson());

class jobAuditSkuVariationDept {

  jobAuditSkuVariationDept({
    required this.customer_Id,
    required this.store_Id,
    required this.stock_Date,
    required this.valdep,
    required this.department,
    required this.department_Id,
    required this.section_Id,
    required this.sku,
    required this.description,
    required this.teorico,
    required this.contado,
    required this.dif,
    required this.sale_Price,
    required this.code,
    required this.tag,
    required this.pzas,
    required this.valuacion,
    required this.rec,
    required this.audit_User,
    required this.audit_Status,
    required this.audit_New_Quantity,
    required this.audit_Action,
    required this.audit_Reason_Code,
    required this.sent,
    required this.captured_Date_Time,
    required this.terminal,
  });

  double customer_Id;
  double store_Id;
  DateTime stock_Date;
  double valdep;
  String department;
  String department_Id;
  double section_Id;
  String sku;
  String description;
  double teorico;
  double contado;
  double dif;
  double sale_Price;
  String code;
  String tag;
  double pzas;
  double valuacion;
  double rec;
  String audit_User;
  double audit_Status;
  double audit_New_Quantity;
  double audit_Action;
  double audit_Reason_Code;
  double sent;
  String captured_Date_Time;
  String terminal;


  factory jobAuditSkuVariationDept.fromJson(Map<String, dynamic> json) => jobAuditSkuVariationDept(
    customer_Id: json["CUSTOMER_ID"].toDouble(),
    store_Id: json["STORE_ID"].toDouble(),
    stock_Date: DateTime.parse(json["STOCK_DATE"]),
    valdep: json["VALDEP"].toDouble(),
    department: json["DEPARTMENT"],
    department_Id: json["DEPARTMENT_ID"],
    section_Id: json["SECTION_ID"].toDouble(),
    sku: json["SKU"],
    description: json["DESCRIPTION"],
    teorico: json["TEORICO"].toDouble(),
    contado: json["CONTADO"].toDouble(),
    dif: json["DIF"].toDouble(),
    sale_Price: json["SALE_PRICE"].toDouble(),
    code: json["CODE"],
    tag: json["TAG"],
    pzas: json["PZAS"].toDouble(),
    valuacion: json["VALUACION"].toDouble(),
    rec: json["REC"].toDouble(),
    audit_User: json["AUDIT_USER"],
    audit_Status: json["AUDIT_STATUS"].toDouble(),
    audit_New_Quantity: json["AUDIT_NEW_QUANTITY"].toDouble(),
    audit_Action: json["AUDIT_ACTION"].toDouble(),
    audit_Reason_Code: json["AUDIT_REASON_CODE"].toDouble(),
    sent: json["SENT"].toDouble(),
    captured_Date_Time: json["CAPTURED_DATE_TIME"],
    terminal:json["TERMINAL"],
  );

  factory jobAuditSkuVariationDept.fromTOMIDBJson(Map<String, dynamic> json) => jobAuditSkuVariationDept(
    customer_Id: json["customerId"].toDouble(),
    store_Id: json["storeId"].toDouble(),
    stock_Date: DateTime.parse(json["stockDate"]),
    valdep: json["valdep"].toDouble(),
    department: json["department"] ?? "",
    department_Id: json["departmentId"],
    section_Id: json["sectionId"].toDouble(),
    sku: json["sku"],
    description: json["description"],
    teorico: json["teorico"].toDouble(),
    contado: json["contado"].toDouble(),
    dif: json["dif"].toDouble(),
    sale_Price: json["salePrice"].toDouble(),
    code: json["code"],
    tag: json["tag"],
    pzas: json["pzas"].toDouble(),
    valuacion: json["valuacion"].toDouble(),
    rec: json["rec"].toDouble(),
    audit_User: json["auditUser"],
    audit_Status: json["auditStatus"].toDouble(),
    audit_New_Quantity: json["auditNewQuantity"] ?? 0,
    audit_Action: json["auditAction"] ?? 0,
    audit_Reason_Code: json["auditReasonCode"] ?? 0,
    sent: json["sent"] ?? 0,
    captured_Date_Time: json["capturedDateTime"] ?? "",
    terminal:json["terminal"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "customer_Id": customer_Id,
    "store_Id": store_Id,
    "stock_Date": "${stock_Date.year.toString().padLeft(4, '0')}-${stock_Date.month.toString().padLeft(2, '0')}-${stock_Date.day.toString().padLeft(2, '0')}",
    "valdep": valdep,
    "department": department,
    "department_Id": department_Id,
    "section_Id": section_Id,
    "sku": sku,
    "description": description,
    "teorico": teorico,
    "contado": contado,
    "dif": dif,
    "sale_Price": sale_Price,
    "code": code,
    "tag": tag,
    "pzas": pzas,
    "valuacion": valuacion,
    "rec": rec,
    "audit_User": audit_User,
    "audit_Status": audit_Status,
    "audit_New_Quantity": audit_New_Quantity,
    "audit_Action": audit_Action,
    "audit_Reason_Code": audit_Reason_Code,
    "sent": sent,
    "captured_Date_Time":captured_Date_Time,
    "terminal":terminal,
  };
}
