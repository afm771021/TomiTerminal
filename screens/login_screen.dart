import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tomi_terminal_audit2/models/jobAudit_model.dart';
import 'package:tomi_terminal_audit2/share_preferences/preferences.dart';
import 'package:tomi_terminal_audit2/util/globalvariables.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../providers/db_provider.dart';
import '../widgets/tomiterminal_menu.dart';
import 'auditorlistdetails_screen.dart';
import 'screens.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LoginScreen extends StatefulWidget
{
  const LoginScreen({Key? key}) :super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  static const String  _title = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }


  /*void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }*/

  Future<void> writeToLog(String log) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/log${ DateFormat('yyyy-MM-dd').format(DateTime.now()).toString()}.txt');
    g_logpath = file.path;
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final logWithTimestamp = '[$timestamp] $log\n';
    await file.writeAsString(logWithTimestamp, mode: FileMode.append);
  }


  /*@override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController.text = 'antonio';
    passwordController.text =  '0729';
  }*/

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    DBProvider.db.database;

    return Scaffold(
        appBar: AppBar(title: const Text(_title)),
        drawer: const TomiTerminalMenu(),
        body:  Padding(
          padding: const EdgeInsets.fromLTRB(40,40,40,0),
          child: Stack(
                children: [
                  ListView(
                    children: <Widget>[
                      const Image(image: AssetImage('assets/top+bar.png'),),
                      Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          child: const Text(
                            'Tomi Audit',
                            style: TextStyle(fontSize: 25, fontStyle: FontStyle.normal),
                          )),
                      Container(
                        padding: const EdgeInsets.fromLTRB(40, 30, 40, 0),
                        child: TextField(

                          autocorrect: false,
                          controller: nameController,
                          decoration:   InputDecoration(
                            border:  const OutlineInputBorder(),
                            labelText: 'Enter your user',
                            prefixIcon: const Icon(Icons.person),
                            errorText: _errorText,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                        child: TextField(
                          autocorrect: false,
                          obscureText: true,
                          controller: passwordController,
                          decoration:  InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Enter valid inventorykey',
                              prefixIcon: const Icon(Icons.shopping_cart_rounded),
                            errorText: _errorTextik,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      Container(
                          height: 60,
                          padding: const EdgeInsets.fromLTRB(90, 10, 90, 0),
                          child: ElevatedButton(
                            child: const Text('Start audit'),
                            onPressed: nameController.value.text.isNotEmpty && passwordController.value.text.isNotEmpty && !isLoading
                                ? _submit
                                : null,
                          )
                      ),
                      const SizedBox(height: 50,),
                      const Center(child: Text ('(Ver. 2.3.7)', style: TextStyle(fontSize: 10),)),
                    ],
                  ),
                   if ( isLoading )
                   Positioned(
                      bottom: 40,
                      left: size.width * 0.5 - 40,
                      child: const _LoadingIcon()
                  )
                ],
              ),
        ),


    );
  }


  String? get _errorText {
    // at any time, we can get the text from _controller.value.text
    final text = nameController.value.text;
    // Note: you can do your own custom validation here
    // Move this logic this outside the widget for more testable code
    if (text.isEmpty) {
      return 'Can\'t be empty';
    }
    if (text.length < 4) {
      return 'Too short';
    }
    // return null if the text is valid
    return null;
  }

  String? get _errorTextik {
    // at any time, we can get the text from _controller.value.text
    final text = passwordController.value.text;
    // Note: you can do your own custom validation here
    // Move this logic this outside the widget for more testable code
    if (text.isEmpty) {
      return 'Can\'t be empty';
    }
    // return null if the text is valid
    return null;
  }

  Future _submit() async{
    if( isLoading ) return;

    isLoading = true;
    setState(() {});
    await Future.delayed(const Duration(seconds: 1));

    if (_errorText == null && _errorTextik == null) {
      // notify the parent widget via the onSubmit callback
      onSubmit(nameController.value.text, passwordController.value.text);
    }

    isLoading = false;
    setState(() {});
  }

  Future<void> onSubmit(String name, String inventorykey) async {
    //print('onSubmit:');
    try {
      var url = Uri.parse('${Preferences.servicesURL}/api/Audit/auditauthenticate');
      //print('url: ${url}');
      //var url = Uri.parse('https://localhost:8085/api/Audit/auditauthenticate');
      var respuesta = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'name': name,
            'inventorykey': inventorykey
          }));

      if (respuesta.statusCode == 200) {
        var loginResponseBody = (jsonDecode(respuesta.body));
        //print('statusCode: ${respuesta.body}');
        if (!loginResponseBody['success']) {
          showDialog(
              barrierDismissible: true,
              context: context,
              builder: (context) {
                return AlertDialog(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.circular(10)),
                  title: const Text('Alert'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:  [
                      Text(loginResponseBody['error']),
                      const SizedBox(height: 10),
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('OK')),
                  ],
                );
              });
        }
        else {
          setState(() {
            g_login = true;
            g_user = name;
            g_inventorykey = inventorykey;
            g_customerId = loginResponseBody['customerId'].round();
            g_storeId = loginResponseBody['storeId'].round();
            g_auditType = loginResponseBody['auditType'].round();
            g_stockDate = DateTime.parse(loginResponseBody['stockDate']);
            g_user_rol = loginResponseBody['rol'];
            print('g_user_rol: ${g_user_rol}');
            print('g_auditType: ${g_auditType}');
          });

          writeToLog('Login a registrar: ${g_user} - TipoAuditoria: ${g_auditType} - JOB: ${g_customerId}, ${g_storeId}, ${g_stockDate}');

          int totalDepartments = await DBProvider.db.downloadDepartments();
          int totalalerts = await DBProvider.db.downloadAlerts();
          int ErrorTypologies = await DBProvider.db.downloadErrorTypology();
          int? inventoryManager = await DBProvider.db.downloadInventoryManager();

          //print('totalDepartments: ${totalDepartments}');
          //print('totalalerts: ${totalalerts}');
          //print('inventoryManager: ${inventoryManager}');

          if (g_auditType == 1) { // Si el tipo de auditoria es para Sodimac
            if (totalDepartments > 0 && totalalerts > 0) {
              JobAudit ja = JobAudit(userName: name,
                  inventoryKey: inventorykey,
                  created_At: DateTime.now());
              // Insertar usuario en la BD
              DBProvider.db.nuevoJobAudit(ja);
              // Seleccionar la pantalla de busqueda según el tipo de auditoría.
              final tagSearchroute = MaterialPageRoute(
                  builder: (context) => const TagSearchScreen());
              final auditor_route = MaterialPageRoute(
                  builder: (context) => const AuditorListDetailsScreen());

              if(g_user_rol == 'SUPERVISOR')
                Navigator.pushReplacement(context, tagSearchroute);
              else if(g_user_rol == 'AUDITOR'){
                Navigator.pushReplacement(context, auditor_route);
              }

            }
            else {
              showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusDirectional.circular(10)),
                      title: const Text('Alert'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                              'Can not load catalogs (Departments, Alerts, Inventory Manager) !!'),
                          SizedBox(height: 10),
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK')),
                      ],
                    );
                  });
            }
          }
          else if (g_auditType == 2){
            if (totalDepartments > 0) {
              JobAudit ja = JobAudit(userName: name,
                  inventoryKey: inventorykey,
                  created_At: DateTime.now());
              // Insertar usuario en la BD
              DBProvider.db.nuevoJobAudit(ja);

              // Seleccionar la pantalla de busqueda según el tipo de auditoría.

              final route = MaterialPageRoute(
                  builder: (context) => const TagSearchScreen());
              final department_route = MaterialPageRoute(
                  builder: (context) => const DepartmentSearchScreen());
              final auditor_route = MaterialPageRoute(
                  builder: (context) => const AuditorListDetailsScreen());

              //if (g_auditType == 1)
              //  Navigator.pushReplacement(context, route);
              if(g_user_rol == 'SUPERVISOR')
                Navigator.pushReplacement(context, department_route);
              else if(g_user_rol == 'AUDITOR'){
                //print('cargar pantalla AUDITOR');
                //DBProvider.db.downloadAuditorDepartmentSectionSkuToAudit();
                Navigator.pushReplacement(context, auditor_route);
              }
              //print('totalalerts');
            }
            else {
              showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusDirectional.circular(10)),
                      title: const Text('Alert'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                              'Can not load catalogs (Departments) !!'),
                          SizedBox(height: 10),
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK')),
                      ],
                    );
                  });
            }
          }
        }
      }
    }
    catch(e) {
      //print('Error ${e}');
      showDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return AlertDialog(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusDirectional.circular(10)),
              title: const Text('Alert'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children:  [
                  Text('Tomi services not available !!'),
                  SizedBox(height: 10),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK')),
              ],
            );
          });
    } //catch
  }
}

class _LoadingIcon extends StatelessWidget {
  const _LoadingIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle
      ),
      child: const CircularProgressIndicator(),
    );
  }
}

