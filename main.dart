
import 'package:flutter/services.dart';
import 'package:tomi_terminal_audit2/providers/department_list_provider.dart';
import 'package:tomi_terminal_audit2/providers/departmentsection_details_list_provider.dart';
import 'package:tomi_terminal_audit2/providers/job_details_list_provider.dart';
import 'package:tomi_terminal_audit2/providers/job_indicators_provider.dart';
import 'package:tomi_terminal_audit2/providers/tag_list_provider.dart';
import 'package:tomi_terminal_audit2/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tomi_terminal_audit2/share_preferences/preferences.dart';

import 'screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Preferences.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return  MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TagListProvider()),
        ChangeNotifierProvider(create: (_) => JobDetailsListProvider()),
        ChangeNotifierProvider(create: (_) => DepartmentSectionListProvider()),
        ChangeNotifierProvider(create: (_) => JobIndicatorsProvider()),
        ChangeNotifierProvider(create: (_) => DepartmentListProvider()),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Tomi terminal Audit',
          initialRoute: AppRoutes.initialRoute,
          routes:AppRoutes.routes
      ),
    );
  }
}
