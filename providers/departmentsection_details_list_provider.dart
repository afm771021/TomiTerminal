

import 'package:flutter/material.dart';
import '../models/jobAuditSkuVariationDept_model.dart';
import 'db_provider.dart';

class DepartmentSectionListProvider extends ChangeNotifier{
  List<jobAuditSkuVariationDept> jobAuditSkuVariationDepts = [];

  getJobAuditSkuVariationDept(int customerId, int storeId, DateTime stockDate, String department_id, int section_id) async{
    final jobAuditSkuVariationDept = await DBProvider.db.getJobAuditSkuVariationDeptToAudit( customerId,  storeId,  stockDate,  department_id,  section_id);
    this.jobAuditSkuVariationDepts = [...?jobAuditSkuVariationDept];
    //print('JobDetailsListProvider');
    notifyListeners();
  }


}
