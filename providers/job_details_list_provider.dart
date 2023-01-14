
import 'package:flutter/material.dart';
import '../models/jobDetailAudit_model.dart';
import 'db_provider.dart';

class JobDetailsListProvider extends ChangeNotifier{
  List<jobDetailAudit> jobDetails = [];

  getJobDetails(int customerId, int storeId, DateTime stockDate, int tagNumber, int operation) async{
    final jobDetails = await DBProvider.db.getJobDetailsToAudit( customerId,  storeId,  stockDate,  tagNumber,  operation);
    this.jobDetails = [...?jobDetails];
    //print('JobDetailsListProvider');
    notifyListeners();
  }
}
