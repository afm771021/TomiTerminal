import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/jobDetailAudit_model.dart';
import '../providers/db_provider.dart';
import '../providers/job_details_list_provider.dart';
import '../share_preferences/preferences.dart';
import '../util/globalvariables.dart';
import '../widgets/tomiterminal_menu.dart';

class AuditorListDetailsScreen extends StatefulWidget {
  const AuditorListDetailsScreen({Key? key}) : super(key: key);

  @override
  State<AuditorListDetailsScreen> createState() => _AuditorListDetailsScreenState();
}

class _AuditorListDetailsScreenState extends State<AuditorListDetailsScreen> {
  bool isLoading = false;
  var currencyFormatter = NumberFormat('#,##0.00', 'es_MX');

  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    DBProvider.db.downloadAuditorDepartmentSectionSkuToAudit();//Descarga los registros a Auditar
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final jobDetailsListProvider = Provider.of<JobDetailsListProvider>(context, listen: true);
    jobDetailsListProvider.getAuditorJobDetails(g_customerId, g_storeId, g_stockDate);
    final jobDetails = jobDetailsListProvider.jobDetails;

    return Scaffold(
        appBar: AppBar(
        title: const Text('Auditor'),
          actions: [
                IconButton(
                  iconSize: 40,
                  onPressed: !isLoading ? () async {
                    DBProvider.db.downloadAuditorDepartmentSectionSkuToAudit();
                  }:null,
                  icon: const Icon(Icons.downloading),
                ),
                IconButton(
                    iconSize: 40,
                    onPressed: !isLoading ? () async {
                      validaJobDetail(context, jobDetails);
                    }:null,
                    icon: const Icon(Icons.cloud_done),
                  ),
          ]
        ),
      drawer: const TomiTerminalMenu(),
    body: Container(
          color: Colors.white,
          height: double.infinity,
          width: double.infinity,
          child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                children: [
                  const SizedBox(height: 3,),
                  //_HeaderScreen(),
                  _ProductDetails(),
                  Expanded(
                      child: ListView(
                          children: [
                            const SizedBox(height: 3,),
                            SingleChildScrollView(
                                child:
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: jobDetails.length,
                                  itemBuilder: (context, index) //=> ProductCard()
                                  {
                                      if (jobDetails[index].audit_Status != 4 && jobDetails[index].sent == 0){ //(jobDetails[index].audit_Action == 4 || jobDetails[index].audit_Action == 5)){
                                        //if (jobDetails[index].audit_Action == 4 || jobDetails[index].audit_Action == 5) {
                                        return Card(
                                          color: (jobDetails[index].audit_Action == null || jobDetails[index].audit_Action == 7)
                                              ? Colors.tealAccent
                                              :
                                          (jobDetails[index].audit_Action == 8) ? Colors.tealAccent
                                              :
                                          (jobDetails[index].audit_Action == 2) ? Colors.amber[200]
                                              :
                                          (jobDetails[index].audit_Action == 3) ? Colors.blue[200]
                                              :
                                          (jobDetails[index].audit_Action == 5) ? Colors.purple[200]
                                              :
                                          (jobDetails[index].audit_Action == 0) ? Colors.grey[200]
                                              :
                                          Colors.red[200],
                                          child: ListTile(
                                            onTap: () {

                                            },
                                            onLongPress: () {

                                            },
                                            //leading: const Icon(Icons.person),
                                            title: Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Column(
                                                  children: [
                                                    Text(
                                                      '${jobDetails[index].job_Details_Id.round()}', maxLines: 1, overflow: TextOverflow.ellipsis,)
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      '${jobDetails[index].audit_Action == 5 ||
                                                          jobDetails[index].audit_Action == 2 ? 'UPD' : jobDetails[index].audit_Action == 3 ? ' ADD' : ' DEL'}', maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,)
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      ' ${jobDetails[index].audit_New_Quantity.round()}     ', maxLines: 1, overflow: TextOverflow.ellipsis,)
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      '${jobDetails[index].tag_Number.round()} ', maxLines: 1, overflow: TextOverflow
                                                        .ellipsis,)
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      '${jobDetails[index].code} ', maxLines: 1, overflow: TextOverflow.ellipsis,)
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      '${jobDetails[index].sku} ', maxLines: 1, overflow: TextOverflow.ellipsis,)
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      '${jobDetails[index].nof} ', maxLines: 1, overflow: TextOverflow.ellipsis,)
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      '${jobDetails[index].department_Id} ', maxLines: 1, overflow: TextOverflow.ellipsis,)
                                                  ]
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      '${jobDetails[index].quantity.round()} ', maxLines: 1, overflow: TextOverflow.ellipsis,)
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      '${jobDetails[index].sale_Price} ', maxLines: 1, overflow: TextOverflow.ellipsis,)
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      '${jobDetails[index].description}', maxLines: 1, overflow: TextOverflow.ellipsis,) //AAC:${jobDetails[index].audit_Action.round()} ASTA: ${jobDetails[index].audit_Status.round()} SEN:${jobDetails[index].sent.round()} SAC:${jobDetails[index].source_Action.round()}
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      '${(jobDetails[index].audit_Reason_Code)==1?"T":"P"}', maxLines: 1, overflow: TextOverflow.ellipsis,)
                                                  ],
                                                ),
                                              ],
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Visibility(
                                                    visible:true,
                                                    child:
                                                    IconButton(
                                                        iconSize: 40,
                                                        onPressed: () async {
                                                          //print('IM:');

                                                          //${jobDetails[index].job_Details_Id}');
                                                          // jobDetails[index].audit_Action = 8;

                                                          _mostrarVentanaEmergente(context, jobDetails[index]);

                                                          //int ProcesOk = await DBProvider.db.AuditProcesOneChange(jobDetails[index], 1, 8);
                                                          //if (ProcesOk == 0) {
                                                          //  DBProvider.db.updateJobDetailAudit(jobDetails[index]);
                                                          //}
                                                        },
                                                        icon: const Icon(Icons.lock_person, color: Colors.red,
                                                        )
                                                    )
                                                ),

                                                Visibility(
                                                    visible: (jobDetails[index].audit_Action < 7) ? true : false,
                                                    child:
                                                    IconButton(
                                                        iconSize: 40,
                                                        onPressed: () async {
                                                          //print('CANCEL:${jobDetails[index].job_Details_Id}');
                                                          jobDetails[index].audit_Status = 5;
                                                          jobDetails[index].audit_Action = 5;
                                                          jobDetails[index].source_Action = 5;

                                                          DBProvider.db.updateJobDetailAudit(jobDetails[index]);

                                                          int ProcesOk = await DBProvider.db.AuditProcesOneChange(jobDetails[index], 2, 5);
                                                          //print('CancelOK: ${ProcesOk}');

                                                        },
                                                        icon: const Icon(Icons.cancel, color: Colors.red,
                                                        )
                                                    )
                                                ),
                                                Visibility(
                                                    visible: (jobDetails[index].audit_Action == 8) ? true : false,
                                                    child:
                                                    IconButton(
                                                        iconSize: 40,
                                                        onPressed: () {},
                                                        icon: const Icon(Icons.delete, color: Colors.purpleAccent,
                                                        )
                                                    )
                                                ),
                                                Visibility(
                                                    visible: (jobDetails[index].audit_Action < 7) ? true : false,
                                                    child: IconButton(
                                                        iconSize: 40,
                                                        onPressed: () async {
                                                          //print('PROCESS:${jobDetails[index].job_Details_Id}');
                                                          jobDetails[index].audit_Action = 7;
                                                          jobDetails[index].source_Action = 9;

                                                          DBProvider.db.updateJobDetailAudit(jobDetails[index]);

                                                          int ProcesOk = await DBProvider.db.AuditProcesOneChange(jobDetails[index], 1,9);

                                                          //print('ProcesOk: ${ProcesOk}');

                                                        },
                                                        icon: const Icon(
                                                          Icons.check_circle_outline, color: Colors.green,
                                                        )
                                                    )
                                                ),
                                                Visibility(
                                                    visible: (jobDetails[index].audit_Action == 7) ? true : false,
                                                    child: IconButton(
                                                        iconSize: 40,
                                                        onPressed: () async {},
                                                        icon: const Icon(
                                                          Icons.check_circle_outline, color: Colors.tealAccent,
                                                        )
                                                    )
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                      else {
                                        return Container(); // Opcionalmente, puedes devolver un contenedor vacío o null para omitir el elemento
                                      }
                                  }
                                )
                            )
                          ]
                      )
                  )
                ]
                )
          )
    )
    );
  }

  Future<void> validaJobDetail(BuildContext context,
      List<jobDetailAudit> jobDetails) async {
    var i = 0;
    var noprocesados = 0;
    List<jobDetailAudit> jobDetailsAudit = [];

    for (i = 0; i < jobDetails.length; i++) {
      if (jobDetails[i].source_Action == 0){
        jobDetails[i].source_Action = 7;
      }
      //print('validaJobDetail: Id:${jobDetails[i].job_Details_Id} Action: ${jobDetails[i].audit_Action} source_Action:${jobDetails[i].source_Action}');

      if (jobDetails[i].audit_Status != 4 && (jobDetails[i].audit_Action == 4 || jobDetails[i].audit_Action == 5 ||
          jobDetails[i].audit_Action == 7 || jobDetails[i].audit_Action == 8 || jobDetails[i].audit_Action == 9)
          && jobDetails[i].sent == 0){
        jobDetailsAudit.add(jobDetails[i]);
      }
    }
    //print('validaJobDetail jobDetails -> : ${jobDetailsAudit}');

    var error = 0;
    var iserror = 0;

    for (i = 0; i < jobDetailsAudit.length; i++) {
      List<double> jobDetailsAudittmp = [];
      jobDetailsAudittmp.add(jobDetailsAudit[i].job_Details_Id);
      //print('AuditProcess: ${jobDetailsAudit[i].job_Details_Id} source action: ${jobDetailsAudit[i].source_Action.toInt()}');

      iserror = await AuditProcess(jobDetailsAudittmp,1,jobDetailsAudit[i].source_Action.toInt());

      if (iserror == 0) {
        jobDetailsAudit[i].sent = 1;
        DBProvider.db.updateJobDetailAudit(jobDetailsAudit[i]);
      }
      else{
        error = error + iserror;
      }

    }

    //tipoerror = await AuditProcess(jobDetailsAudit,1,7);

    if (error > 0) {
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
                  Text('Tomi services not available !!'),
                  SizedBox(height: 10),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK')),
              ],
            );
          }
        );
      }
    else{
      for (i = 0; i < jobDetails.length; i++) {
        if (jobDetails[i].audit_Status != 4 && (jobDetails[i].audit_Action == 4 || jobDetails[i].audit_Action == 5)){
          jobDetails[i].audit_Status = 4;
          DBProvider.db.updateJobDetailAudit(jobDetails[i]);
        }
      }
    }

    /*if (noprocesados > 0) {
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
                children: [
                  Text('$noprocesados record(s) missing to process !!'),
                  const SizedBox(height: 10),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK')),
              ],
            );
          });
    }
    else {
      var tipoerror = await sendJobDetail(context, jobDetails);

      if (tipoerror == 0){
        final route = MaterialPageRoute(
            builder: (context) => const TagSearchScreen());
        Navigator.pushReplacement(context, route);
      }
      else if (tipoerror == 1){
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
                    Text('Tomi services not available !!'),
                    SizedBox(height: 10),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK')),
                ],
              );
            });
      } // else if
      else if (tipoerror == 2){
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
                    Text('Tag was restarted by tomi admin.!!'),
                    SizedBox(height: 10),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        final route = MaterialPageRoute(
                            builder: (context) => const TagSearchScreen());
                        Navigator.pushReplacement(context, route);
                      },
                      child: const Text('OK')),
                ],
              );
            });
      }
    }
    */
  }

  Future<int> AuditProcess(List<double> jobDetailsAudit, int action, int sourceAction) async{
    var tipoerror = 0;
    var url = Uri.parse('${Preferences.servicesURL}/api/Audit/AuditMassChange'); // IOS
    //print (url);
    try {
      var params = {
        'customerId':g_customerId,
        'storeId': g_storeId,
        'stockDate' : g_stockDate.toString(),
        'operation' : 1,
        'action': action,
        'sourceAction' : sourceAction,
        'jobDetailsIds' : jobDetailsAudit,
        'auditorId' : g_user
      };
      //print(' params:${json.encode(params)}');
      var response = await http.post(
          url,
          headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
          body: json.encode(params)
      );
      //print(jobDetailsAudit);
      //print(response.statusCode);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (!data["success"]){
          tipoerror = 2;
        }
      }
    } on SocketException catch (e) {
      //print(' Error en servicio .${e.toString()}');
      tipoerror = 1;
    }
    catch(e){
      tipoerror = 2;
    }

    return tipoerror;
  }

  final String _contrasena = g_im_password; // Valor de la variable con la contraseña

  void _mostrarVentanaEmergente(BuildContext context, jobDetailAudit jda) {
    String _contrasenaIngresada = ""; // Variable local para almacenar la contraseña ingresada

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ingresa una contraseña'),
          content: TextField(
            decoration: InputDecoration(hintText: 'Contraseña'),
            obscureText: true, // Oculta los caracteres ingresados
            onChanged: (value) {
              _contrasenaIngresada = value; // Actualiza la variable local con la contraseña ingresada
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Aceptar'),
              onPressed: () async {
                // Compara la contraseña ingresada con el valor de la variable
                //print('_contrasenaIngresada: ${_contrasenaIngresada} _contrasena: ${_contrasena}');

                if (_contrasenaIngresada == _contrasena) {
                   //print('Contraseña Correcta');
                   jda.audit_Action = 8;
                   jda..source_Action = 8;
                   DBProvider.db.updateJobDetailAudit(jda);

                   int ProcesOk = await DBProvider.db.AuditProcesOneChange(jda, 1, 8);

                   //print('IM ProcessOk: ${ProcesOk}');

                  Navigator.of(context).pop();
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Contraseña incorrecta'),
                        content: Text('La contraseña ingresada es incorrecta.'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Aceptar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

}


class _ProductDetails extends StatelessWidget {
  _ProductDetails({
    Key? key
  }) : super(key: key){
  }

  int lineas = 0;
  double cantidad = 0.0;
  double valor = 0.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(right: 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: double.infinity,
        height: size.height * 0.10,
        decoration: _buildBoxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                    children:const [Text('Rec.',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text(' Oper. ',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text(' Qty new',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text(' Tag   ',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('CODE             ',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('SKU      ',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text(' nof  ',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),

                Column(
                    children:const [Text('Dept  ',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('Qty ',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('Price',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text(' Desc                                               ',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text(' Reason ',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('  IM ',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text(' Cancel ',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('  Ok',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => const BoxDecoration(
      gradient: LinearGradient(
          colors: [
            Color.fromRGBO(63, 63, 156, 1),
            Color.fromRGBO(90,70, 178, 1)
          ]
      ),
      //color: Colors.indigo,
      borderRadius: BorderRadius.only( topLeft: Radius.circular(25),topRight: Radius.circular(25), bottomRight: Radius.circular(25), bottomLeft:Radius.circular(25) )
  );
}
