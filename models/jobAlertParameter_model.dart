// To parse this JSON data, do
//
//     final jobAlertParameter = jobAlertParameterFromJson(jsonString);

import 'dart:convert';

JobAlertParameter jobAlertParameterFromJson(String str) => JobAlertParameter.fromJson(json.decode(str));

String jobAlertParameterToJson(JobAlertParameter data) => json.encode(data.toJson());

class JobAlertParameter {
  JobAlertParameter({
    required this.customerId,
    required this.storeId,
    required this.stockDate,
    required this.parameterId,
    required this.value,
  });

  double customerId;
  double storeId;
  DateTime stockDate;
  String parameterId;
  String value;

  factory JobAlertParameter.fromJson(Map<String, dynamic> json) => JobAlertParameter(
    customerId: json["customerId"],
    storeId: json["storeId"],
    stockDate: DateTime.parse(json["stockDate"]),
    parameterId: json["parameterId"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "CUSTOMER_ID": customerId,
    "STORE_ID": storeId,
    "STOCK_DATE": "${stockDate.year.toString().padLeft(4, '0')}-${stockDate.month.toString().padLeft(2, '0')}-${stockDate.day.toString().padLeft(2, '0')}",
    "PARAMETER_ID": parameterId,
    "VALUE": value,
  };
}
