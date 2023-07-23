// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

jobDetailAudit jobDetailAuditFromJson(String str) => jobDetailAudit.fromJson(json.decode(str));

String jobDetailAuditToJson(jobDetailAudit data) => json.encode(data.toJson());

class jobDetailAudit {

  jobDetailAudit({
    required this.customer_Id,
    required this.store_Id,
    required this.stock_Date,
    required this.job_Details_Id,
    required this.tag_Number,
    required this.tag_Id,
    required this.shelf,
    required this.description,
    required this.code,
    required this.sale_Price,
    required this.quantity,
    required this.operation,
    required this.captured_date_time,
    required this.department_Id,
    required this.nof,
    required this.sku,
    required this.terminal,
    required this.emp_Id,
    required this.audit_Status,
    required this.audit_New_Quantity,
    required this.audit_Action,
    required this.audit_Reason_Code,
    required this.sent,
    required this.source_Action,
  });

  double customer_Id;
  double store_Id;
  DateTime stock_Date;
  double job_Details_Id;
  double tag_Number;
  double tag_Id;
  String shelf;
  String description;
  String code;
  double sale_Price;
  double quantity;
  double operation;
  String captured_date_time;
  String department_Id;
  int nof;
  String sku;
  String terminal;
  String emp_Id;
  double audit_Status;
  double audit_New_Quantity;
  double audit_Action;
  double audit_Reason_Code;
  double sent;
  double source_Action;

  factory jobDetailAudit.fromJson(Map<String, dynamic> json) => jobDetailAudit(
    customer_Id: json["CUSTOMER_ID"].toDouble(),
    store_Id: json["STORE_ID"].toDouble(),
    stock_Date: DateTime.parse(json["STOCK_DATE"]),
    job_Details_Id: json["JOB_DETAILS_ID"].toDouble(),
    tag_Number: json["TAG_NUMBER"].toDouble(),
    tag_Id: json["TAG_ID"].toDouble(),
    shelf: json["SHELF"],
    description: json["DESCRIPTION"],
    code: json["CODE"],
    sale_Price: json["SALE_PRICE"],
    quantity: json["QUANTITY"],
    captured_date_time: json["CAPTURED_DATE_TIME"],
    department_Id: json["DEPARTMENT_ID"],
    nof: json["NOF"],
    sku: json["SKU"],
    terminal: json["TERMINAL"],
    emp_Id: json["EMP_ID"],
    operation: json["OPERATION"].toDouble(),
    audit_Status: json["AUDIT_STATUS"].toDouble(),
    audit_New_Quantity: (json["AUDIT_NEW_QUANTITY"]==null)?0:json["AUDIT_NEW_QUANTITY"],
    audit_Action: (json["AUDIT_ACTION"])==null?0:json["AUDIT_ACTION"].toDouble(),
    audit_Reason_Code: (json["AUDIT_REASON_CODE"])==null?0:json["AUDIT_REASON_CODE"].toDouble(),
    sent: json["SENT"].toDouble(),
    source_Action: json["SOURCE_ACTION"].toDouble(),
  );

  factory jobDetailAudit.fromTomiDBJson(Map<String, dynamic> json) => jobDetailAudit(
    customer_Id: json["customerId"],
    store_Id: json["storeId"],
    stock_Date: DateTime.parse(json["stockDate"]),
    job_Details_Id: json["jobDetailsId"],
    tag_Number: json["tagNumber"],
    tag_Id: json["tagId"],
    shelf: json["shelf"],
    description: json["description"] ?? "",
    code: json["code"],
    sale_Price: json["salePrice"],
    quantity: json["quantity"],
    captured_date_time: json["capturedDateTime"] ?? "" ,
    department_Id: json["departmentId"],
    nof: (json["nof"])?1:0,
    sku: json["sku"] ?? "",
    terminal: json["terminal"] ?? "",
    emp_Id: json["empId"] ?? "",
    operation: json["operation"],
    audit_Status: json["auditStatus"],
    audit_New_Quantity: json["auditNewQuantity"] ?? 0,
    audit_Action: json["auditAction"] ?? 0,
    audit_Reason_Code: json["auditReasonCode"] ?? 0,
    sent: json["sent"] ?? 0,
    source_Action: json["SOURCE_ACTION"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "customer_Id": customer_Id,
    "store_Id": store_Id,
    "stock_Date": "${stock_Date.year.toString().padLeft(4, '0')}-${stock_Date.month.toString().padLeft(2, '0')}-${stock_Date.day.toString().padLeft(2, '0')}",
    "job_Details_Id": job_Details_Id,
    "tag_Number": tag_Number,
    "tag_Id": tag_Id,
    "shelf": shelf,
    "description": description,
    "code": code,
    "sale_price": sale_Price,
    "quantity": quantity,
    "captured_date_time": captured_date_time,
    "department_Id": department_Id,
    "nof":nof,
    "sku":sku,
    "terminal":terminal,
    "emp_Id":emp_Id,
    "operation": operation,
    "audit_Status": audit_Status,
    "audit_New_Quantity": audit_New_Quantity,
    "audit_Action": audit_Action,
    "audit_Reason_Code": audit_Reason_Code,
    "sent": sent,
    "source_Action": source_Action,
  };
}
