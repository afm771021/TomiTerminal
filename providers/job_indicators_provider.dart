
import 'package:flutter/foundation.dart';
import 'package:tomi_terminal_audit2/providers/db_provider.dart';
import '../models/jobGetIndicators_model.dart';

class JobIndicatorsProvider extends ChangeNotifier{
  JobGetIndicators? jobGetIndicators;

  loadIndicators () async{
    //print ('JobIndicatorsProvider');
    final indicators = await DBProvider.db.getIndicators();
    jobGetIndicators = indicators;
    notifyListeners();
  }

}
