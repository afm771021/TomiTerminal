
import 'package:flutter/material.dart';
import 'package:tomi_terminal_audit2/screens/departmentsectionlistdetails_screen.dart';
import '../screens/screens.dart';

class AppRoutes{
  static const initialRoute = 'login';

  static Map<String, Widget Function(BuildContext)> routes = {
    'DepartmentSectionListDetails': ( BuildContext context) => const DepartmentSectionListDetailsScreen(),
    'TagListDetails'              : ( BuildContext context) => const TagListDetailsScreen(),
    'TagList'                     : ( BuildContext context) => const TagListScreen(),
    'TagSearch'                   : ( BuildContext context) => const TagSearchScreen(),
    'login'                       : ( BuildContext context) => const LoginScreen(),
    SettingsScreen.routerName     : ( _ ) => const SettingsScreen(),
  };

}
