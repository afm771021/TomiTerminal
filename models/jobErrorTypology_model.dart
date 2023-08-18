// To parse this JSON data, do
//
import 'dart:convert';

JobErrorTypology jobErrorTypologyFromJson(String str) => JobErrorTypology.fromJson(json.decode(str));

String jobErrorTypologyToJson(JobErrorTypology data) => json.encode(data.toJson());

class JobErrorTypology {
  JobErrorTypology({
    required this.customerId,
    required this.storeId,
    required this.stockDate,
    required this.errorId,
    required this.description,
    required this.isProcessError,
    required this.isEligible
  });

  double customerId;
  double storeId;
  DateTime stockDate;
  double errorId;
  String description;
  double isProcessError;
  double isEligible;

  factory JobErrorTypology.fromJson(Map<String, dynamic> json) => JobErrorTypology(
    customerId: json["customerId"],
    storeId: json["storeId"],
    stockDate: DateTime.parse(json["stockDate"]),
    errorId: json["errorId"],
    description: json["description"],
    isProcessError: json["isProcessError"],
    isEligible: json["isEligible"],
  );

  Map<String, dynamic> toJson() => {
    "CUSTOMER_ID": customerId,
    "STORE_ID": storeId,
    "STOCK_DATE": "${stockDate.year.toString().padLeft(4, '0')}-${stockDate.month.toString().padLeft(2, '0')}-${stockDate.day.toString().padLeft(2, '0')}",
    "ERROR_ID": errorId,
    "DESCRIPTION": description,
    "IS_PROCESS_ERROR":isProcessError,
    "IS_ELIGIBLE":isEligible
  };
}
