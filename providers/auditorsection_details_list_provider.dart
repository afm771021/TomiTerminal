import 'package:flutter/material.dart';

import '../models/jobAuditSkuVariationDept_model.dart';
import 'db_provider.dart';

class AuditorSectionListProvider extends ChangeNotifier{
  List<jobAuditSkuVariationDept> auditorSkuVariationDepts = [];

  getAuditorSkuVariationDept(int customerId, int storeId, DateTime stockDate ) async{
    final auditorSkuVariationDept = await DBProvider.db.getAuditorSkuVariationDeptToAudit( customerId,  storeId,  stockDate);
    this.auditorSkuVariationDepts = [...?auditorSkuVariationDept];
    //print('JobDetailsListProvider');
    notifyListeners();
  }

}
