
import 'package:flutter/foundation.dart';
import 'package:tomi_terminal_audit2/providers/db_provider.dart';
import '../models/jobGetIndicators_model.dart';

class JobIndicatorsProvider extends ChangeNotifier{
  JobGetIndicators jobGetIndicators = JobGetIndicators(
                                      totalTags: 0,
                                      countedTags: 0,
                                      missingTags: 0,
                                      totalAmount: 0,
                                      totalQuantity: 0,
                                      totalHours: 0,
                                      totalAuditedTags: 0,
                                      auditInProgressTags: 0,
                                      employeeProductivity: EmployeeProductivity(labels: [], series: []
                                      ),
                                      departments: [],
                                      groupsAdvances: [],
                                      totalDepartments: 0,
                                      releasedDepartments: 0,
                                      inProgressDepartments: 0,
                                      completedDepartments: 0,
                                      );

  loadIndicators () async{
    //print ('JobIndicatorsProvider');
    final indicators = await DBProvider.db.getIndicators();
    jobGetIndicators = indicators;
    notifyListeners();
  }

}
