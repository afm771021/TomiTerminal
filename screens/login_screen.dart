import 'dart:convert';
import 'package:tomi_terminal_audit2/models/jobAudit_model.dart';
import 'package:tomi_terminal_audit2/share_preferences/preferences.dart';
import 'package:tomi_terminal_audit2/util/globalvariables.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../providers/db_provider.dart';
import '../widgets/tomiterminal_menu.dart';
import 'screens.dart';

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
                            labelText: 'Enter your name',
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
                      const Center(child: Text ('(Ver. 1.0.1)', style: TextStyle(fontSize: 10),)),
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
    await Future.delayed(const Duration(seconds: 2));

    if (_errorText == null && _errorTextik == null) {
      // notify the parent widget via the onSubmit callback
      onSubmit(nameController.value.text, passwordController.value.text);
    }

    isLoading = false;
    setState(() {});
  }

  Future<void> onSubmit(String name, String inventorykey) async {

    try {
      var url = Uri.parse('${Preferences.servicesURL}/api/Audit/auditauthenticate');
      //print(url);
      var respuesta = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'name': name,
            'inventorykey': inventorykey
          }));
      //print(respuesta.statusCode);
      //print(respuesta.body);
      if (respuesta.statusCode == 200) {
        var loginResponseBody = (jsonDecode(respuesta.body));

        if (loginResponseBody['inventorykey'] == null) {
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
                      Text('Inventory key not found !!'),
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
        else {
          //print('totalalerts');
          int totalDepartments = await DBProvider.db.downloadDepartments();
          int totalalerts = await DBProvider.db.downloadAlerts();
          //print(totalalerts);
          if (totalDepartments > 0 && totalalerts > 0){
            JobAudit ja = JobAudit(userName: name,
                inventoryKey: inventorykey,
                created_At: DateTime.now());
            // Insertar usuario en la BD
            DBProvider.db.nuevoJobAudit(ja);

            setState(() {
              g_login = true;
              g_user = name;
              g_inventorykey = inventorykey;
              g_customerId = loginResponseBody['customerId'].round();
              g_storeId = loginResponseBody['storeId'].round();
              g_stockDate = DateTime.parse(loginResponseBody['stockDate']);
            });
            final route = MaterialPageRoute(builder: (context) => const TagSearchScreen());
            Navigator.pushReplacement(context, route);
          //print('totalalerts');
          }
          else
            {
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
                          Text('Can not load catalogs (Departments, Alerts) !!'),
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
                children:  const [
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

