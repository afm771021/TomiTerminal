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
                  //DBProvider.db.downloadAuditorDepartmentSectionSkuToAudit();
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
                                      if (jobDetails[index].audit_Status != 4 && (jobDetails[index].audit_Action == 4 || jobDetails[index].audit_Action == 5)){
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
                                                      '         ${jobDetails[index].audit_Action == 5 ||
                                                          jobDetails[index].audit_Action == 2 ? '   UPDATE' : jobDetails[index].audit_Action == 3 ? '    ADD' : '   DELETE'}', maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,)
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      '          ${jobDetails[index].audit_New_Quantity}     ', maxLines: 1, overflow: TextOverflow.ellipsis,)
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      '  ${jobDetails[index].tag_Number} ', maxLines: 1, overflow: TextOverflow
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
                                                      '${jobDetails[index].quantity} ', maxLines: 1, overflow: TextOverflow.ellipsis,)
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
                                                      '${jobDetails[index].description} ', maxLines: 1, overflow: TextOverflow.ellipsis,)
                                                  ],
                                                ),
                                              ],
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Visibility(
                                                    visible: (jobDetails[index].audit_Action < 7) ? true : false,
                                                    child:
                                                    IconButton(
                                                        iconSize: 40,
                                                        onPressed: () async {
                                                          print('CANCEL:${jobDetails[index].job_Details_Id}');jobDetails[index].audit_Action = 8;
                                                          int ProcesOk = await DBProvider.db.AuditProcesOneChange(jobDetails[index], 2);
                                                          if (ProcesOk == 0) {
                                                            DBProvider.db.updateJobDetailAudit(jobDetails[index]);
                                                          }
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
                                                          print('PROCESS:${jobDetails[index].job_Details_Id}');
                                                          jobDetails[index].audit_Action = 7;
                                                          int ProcesOk = await DBProvider.db.AuditProcesOneChange(jobDetails[index],
                                                              1);
                                                          if (ProcesOk == 0) {
                                                            DBProvider.db.updateJobDetailAudit(jobDetails[index]);
                                                          }
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
    List<double> jobDetailsAudit = [];

    print('validaJobDetail ___________________');
    for (i = 0; i < jobDetails.length; i++) {
      print('validaJobDetail: Id:${jobDetails[i].job_Details_Id} Action: ${jobDetails[i].audit_Action}');
      if (jobDetails[i].audit_Status != 4 && (jobDetails[i].audit_Action == 4 || jobDetails[i].audit_Action == 5)){
        jobDetailsAudit.add(jobDetails[i].job_Details_Id);
      }
    }
    print('validaJobDetail jobDetails -> : ${jobDetailsAudit}');

    var tipoerror = 0;

    //tipoerror = await AuditProcess(jobDetailsAudit,1);

    if (tipoerror == 0) {
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

  Future<int> AuditProcess(List<double> jobDetailsAudit, int action) async{
    var tipoerror = 0;
    var url = Uri.parse('${Preferences.servicesURL}/api/Audit/AuditMassChange'); // IOS

    try {
      var params = {
        'customerId':g_customerId,
        'storeId': g_storeId,
        'stockDate' : g_stockDate.toString(),
        'operation' : 1,
        'action': action,
        'jobDetailsIds' : jobDetailsAudit
      };
      print(' params:${json.encode(params)}');
      var response = await http.post(
          url,
          headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
          body: json.encode(params)
      );
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
                    children:const [Text('RECORD#',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('   Change Type',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('     Qty new',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('    Tag       ',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('   SKU           ',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('        SKU2   ',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('         nof   ',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),

                Column(
                    children:const [Text(' Dept  ',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('Qty Orig',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('  Price',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('       Desc                                        ',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('Cancel  ',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('Process',
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
