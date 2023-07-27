import 'package:flutter/material.dart';
import 'package:tomi_terminal_audit2/screens/auditorlistdetails_screen.dart';
import 'package:tomi_terminal_audit2/util/globalvariables.dart';
import 'dart:math' as math;
import '../screens/screens.dart';

class TomiTerminalMenu extends StatelessWidget {
  const TomiTerminalMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child:ListView(
        padding: EdgeInsets.zero,
        children:  [
          const _DrawerHeader(),
          Visibility(
            visible: (g_login)?true:false,
            child: ListTile(
              leading:  const Icon( Icons.dashboard, color: Colors.indigo,),
              title:  const Text('Dashboard'),
              onTap: (){
                final route = MaterialPageRoute(builder: (context) => const JobDashboardScreen());
                Navigator.pushReplacement(context, route);
              },
            ),
          ),
          Visibility(
            visible: (g_login && g_auditType == 1)?true:false,
            child: ListTile(
              leading:  const Icon( Icons.search, color: Colors.indigo,),
              title:  const Text('Search Tags'),
              onTap: (){
                final route = MaterialPageRoute(builder: (context) => const TagSearchScreen());
                Navigator.pushReplacement(context, route);
              },
            ),
          ),
          Visibility(
            visible: (g_login && g_auditType == 2 && g_user_rol == 'SUPERVISOR')?true:false,
            child: ListTile(
              leading:  const Icon( Icons.search, color: Colors.indigo,),
              title:  const Text('Search Department'),
              onTap: (){
                final route = MaterialPageRoute(builder: (context) => const DepartmentSearchScreen());
                Navigator.pushReplacement(context, route);
              },
            ),
          ),
          Visibility(
            visible: (g_login && g_auditType == 2 && g_user_rol == 'AUDITOR')?true:false,
            child: ListTile(
              leading:  const Icon( Icons.search, color: Colors.indigo,),
              title:  const Text('Auditor'),
              onTap: (){
                final route = MaterialPageRoute(builder: (context) => const AuditorListDetailsScreen());
                Navigator.pushReplacement(context, route);
              },
            ),
          ),
          ListTile(
            leading:  const Icon( Icons.settings_suggest_outlined, color: Colors.indigo,),
            title:  const Text('Settings'),
            onTap: (){
             // Navigator.pop(context);
              Navigator.pushReplacementNamed(context, SettingsScreen.routerName);
            },
          ),
          Visibility(
            visible: (g_login)?true:false,
            child: ListTile(
                leading:  const Icon( Icons.logout,color: Colors.indigo,),
                title:  const Text('Exit'),
                onTap: (){
                  g_login = false;
                  final route = MaterialPageRoute(builder: (context) => const LoginScreen());
                  Navigator.pushReplacement(context, route);
                },
              )
          ),
          Visibility(
              visible: (!g_login)?true:false,
              child: ListTile(
                leading:  const Icon( Icons.login,color: Colors.indigo,),
                title:  const Text('Login'),
                onTap: (){
                  g_user = '';
                  final route = MaterialPageRoute(builder: (context) => const LoginScreen());
                  Navigator.pushReplacement(context, route);
                },
              )
          )
        ],
      )
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
        decoration: const BoxDecoration(
        color: Colors.blue,
        image: DecorationImage(
          image: AssetImage('assets/tomi_logo_white.png'),
        )
        ),
        child: Container(
          alignment: Alignment.topCenter,
          child: Text('    User: ${g_user}    Rol: ${g_user_rol}',
          style: TextStyle(fontSize: 12,color: Colors.white,),),
        ),
    );
  }
}
