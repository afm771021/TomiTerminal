
import 'package:flutter/foundation.dart';
import 'package:tomi_terminal_audit2/providers/db_provider.dart';
import '../models/jobAuditDepartment_model.dart';

class DepartmentListProvider extends ChangeNotifier{

 List<AuditDepartmentModel> departments = [];

 loadDepartments(String searchDepartment) async{
   final departments = await DBProvider.db.getDepartmentsToAudit(searchDepartment);
   this.departments = [...departments];
   notifyListeners();
 }
}
