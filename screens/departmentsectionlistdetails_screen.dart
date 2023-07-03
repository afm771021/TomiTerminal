import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tomi_terminal_audit2/screens/departmentsearch_screen.dart';
import 'package:http/http.dart' as http;
import '../models/jobAuditSkuVariationDept_model.dart';
import '../providers/db_provider.dart';
import '../providers/departmentsection_details_list_provider.dart';
import '../share_preferences/preferences.dart';
import '../util/globalvariables.dart';
import '../widgets/tomiterminal_menu.dart';
import 'departmentsectiondelete_screen.dart';
import 'departmentsectionedit_screen.dart';
import 'departmentsectionnew_screen.dart';
import 'package:path_provider/path_provider.dart';


class DepartmentSectionListDetailsScreen extends StatefulWidget {
  const DepartmentSectionListDetailsScreen({Key? key}) : super(key: key);

  @override
  State<DepartmentSectionListDetailsScreen> createState() => _DepartmentSectionListDetailsScreenState();
}

class _DepartmentSectionListDetailsScreenState extends State<DepartmentSectionListDetailsScreen> {
  var currencyFormatter = NumberFormat('#,##0.00', 'es_MX');
  bool isLoading = false;

  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

 /* @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }*/

  Future<void> writeToLog(String log) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/log${ DateFormat('yyyy-MM-dd').format(DateTime.now()).toString()}.txt');

    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final logWithTimestamp = '[$timestamp] $log\n';
    print('${directory.path}/log.txt');
    await file.writeAsString(logWithTimestamp, mode: FileMode.append);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final departmentSectionListProvider = Provider.of<DepartmentSectionListProvider>(context, listen: true);
    departmentSectionListProvider.getJobAuditSkuVariationDept(g_customerId, g_storeId, g_stockDate, g_departmentNumber, g_sectionNumber);
    final departmentSectionList = departmentSectionListProvider.jobAuditSkuVariationDepts;
    int contador = 0;
    String sku_inicial = "";
    bool hideinfo = false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Department $g_departmentNumber - Section $g_sectionNumber'),
        actions: [
          IconButton(
            iconSize: 40,
            onPressed: !isLoading ? () async {
              validaDepartments(departmentSectionList);
            }:null,
            icon: const Icon(Icons.cloud_done),
          ),
          IconButton(
            iconSize: 40,
            onPressed: !isLoading ? () async {
              showDialog(
                  barrierDismissible: false,
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
                          Text('Are you sure you want to send th whole section ?'),
                          SizedBox(height: 10),
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              var pendings = countDepartmentspending(departmentSectionList);
                              print(pendings);
                              showDialog(
                                  barrierDismissible: false,
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
                                          Text('$pendings record(s) missing to process, continue ?'),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              validaDepartments(departmentSectionList);
                                            },
                                            child: const Text('OK')),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              },

                                    child: const
                                     Text('Cancel'))
                                      ],
                                    );
                                  });
                            },
                            child: const Text('OK')),
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'))
                      ],
                    );
                  });
            }:null,
            icon: const Icon(Icons.bathtub_outlined),
          )
        ],
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
                          itemCount: departmentSectionList.length,
                          itemBuilder: (context, index) //=> ProductCard()
                          {
                            if (contador == 0)
                              {
                                sku_inicial = departmentSectionList[index].sku;
                                hideinfo = false;
                              }
                            else if( sku_inicial == departmentSectionList[index].sku)
                              {
                                  hideinfo = true;
                              }
                            else if( sku_inicial != departmentSectionList[index].sku)
                              {
                                sku_inicial = departmentSectionList[index].sku;
                                hideinfo = false;
                              }

                            String _sku = departmentSectionList[index].sku;
                            String _desc = departmentSectionList[index].description;

                            if (_sku.isEmpty)
                              _sku = " ---------- ";

                            if (_desc.isEmpty)
                              _desc = " ----------------------------------- ";


                            //print ('sku_inicial: ${sku_inicial} - contador: ${contador} - hideinfo:${hideinfo}');
                            contador++;

                            return Card(
                              color: (departmentSectionList[index].audit_Action == null ||
                                  departmentSectionList[index].audit_Action == 0) ? Colors.grey[200] :
                              (departmentSectionList[index].audit_Action == 1) ? Colors.green[200] :
                              (departmentSectionList[index].audit_Action == 2) ? Colors.amber[200] :
                              (departmentSectionList[index].audit_Action == 3) ? Colors.blue[200] :
                              (departmentSectionList[index].audit_Action == 5) ? Colors.purple[200] :
                              Colors.red[200],
                              child: ListTile(
                                onTap: () {

                                },
                                onLongPress: (){
                                  writeToLog('Undo action Record Code: ${departmentSectionList[index].code} last action: ${departmentSectionList[index].audit_Action} last new quantity: ${departmentSectionList[index].audit_New_Quantity} last reason code: ${departmentSectionList[index].audit_Reason_Code}');

                                  if (departmentSectionList[index].audit_Action != 3 && departmentSectionList[index].audit_Action != 4 && departmentSectionList[index].audit_Action != 5) {
                                    departmentSectionList[index].audit_New_Quantity = 0.0;
                                    departmentSectionList[index].audit_Action = 0;
                                    departmentSectionList[index].audit_Status = 2;
                                    departmentSectionList[index].audit_Reason_Code = 0;
                                    departmentSectionList[index].sent = 0;
                                    DBProvider.db.updateJobSkuVariationDeptAudit(departmentSectionList[index]);
                                  }
                                  else if (departmentSectionList[index].audit_Action == 3){
                                    DBProvider.db.deleteJobSkuVariationDeptAudit(departmentSectionList[index]);
                                  }
                                },
                                //leading: const Icon(Icons.person),
                                title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                        Column(
                                            children: [Text('${_sku} ',
                                              style: TextStyle(fontSize: 10, color: (!hideinfo && departmentSectionList[index].audit_Action == 0)?Colors.black
                                                  :(hideinfo && departmentSectionList[index].audit_Action == 0)?Colors.grey[200]
                                                  :(hideinfo && departmentSectionList[index].audit_Action == 1)?Colors.green[200]
                                                  :(!hideinfo && departmentSectionList[index].audit_Action == 1)?Colors.black
                                                  :(hideinfo && departmentSectionList[index].audit_Action == 2)?Colors.amber[200]
                                                  :(!hideinfo && departmentSectionList[index].audit_Action == 2)?Colors.black
                                                  :(!hideinfo && departmentSectionList[index].audit_Action == 3)?Colors.black
                                                  :(hideinfo && departmentSectionList[index].audit_Action == 3)?Colors.black
                                                  :(!hideinfo && departmentSectionList[index].audit_Action == 4)?Colors.black
                                                  :(hideinfo && departmentSectionList[index].audit_Action == 4)?Colors.red[200]
                                                  :(!hideinfo && departmentSectionList[index].audit_Action == 5)?Colors.black
                                                  :(hideinfo && departmentSectionList[index].audit_Action == 5)?Colors.purple[200]
                                                  :Colors.grey[200],
                                                fontWeight: FontWeight.bold,),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,),]
                                        ),


                                    Column(
                                        children: [Text('${_desc} ',
                                        style: TextStyle(fontSize: 10, color: (!hideinfo && departmentSectionList[index].audit_Action == 0)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 0)?Colors.grey[200]
                                            :(hideinfo && departmentSectionList[index].audit_Action == 1)?Colors.green[200]
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 1)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 2)?Colors.amber[200]
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 2)?Colors.black
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 3)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 3)?Colors.black
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 4)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 4)?Colors.red[200]
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 5)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 5)?Colors.purple[200]
                                            :Colors.grey[200], fontWeight: FontWeight.bold,),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,),]
                                    ),

                                    Column(
                                        children: [Text('${departmentSectionList[index].teorico.round()}',
                                        style: TextStyle(fontSize: 10, color: (!hideinfo && departmentSectionList[index].audit_Action == 0)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 0)?Colors.grey[200]
                                            :(hideinfo && departmentSectionList[index].audit_Action == 1)?Colors.green[200]
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 1)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 2)?Colors.amber[200]
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 2)?Colors.black
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 3)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 3)?Colors.black
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 4)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 4)?Colors.red[200]
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 5)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 5)?Colors.purple[200]
                                            :Colors.grey[200], fontWeight: FontWeight.bold,),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,),]
                                    ),
                                    Column(
                                        children: [Text('${departmentSectionList[index].contado.round()}',
                                        style: TextStyle(fontSize: 10, color: (!hideinfo && departmentSectionList[index].audit_Action == 0)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 0)?Colors.grey[200]
                                            :(hideinfo && departmentSectionList[index].audit_Action == 1)?Colors.green[200]
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 1)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 2)?Colors.amber[200]
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 2)?Colors.black
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 3)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 3)?Colors.black
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 4)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 4)?Colors.red[200]
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 5)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 5)?Colors.purple[200]
                                            :Colors.grey[200], fontWeight: FontWeight.bold,),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,),]
                                    ),

                                    Column(
                                        children: [Text('${departmentSectionList[index].dif.round()}',
                                        style: TextStyle(fontSize: 10, color: (!hideinfo && departmentSectionList[index].audit_Action == 0)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 0)?Colors.grey[200]
                                            :(hideinfo && departmentSectionList[index].audit_Action == 1)?Colors.green[200]
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 1)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 2)?Colors.amber[200]
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 2)?Colors.black
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 3)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 3)?Colors.black
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 4)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 4)?Colors.red[200]
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 5)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 5)?Colors.purple[200]
                                            :Colors.grey[200], fontWeight: FontWeight.bold,),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,),]
                                    ),

                                    Column(
                                        children: [Text('${departmentSectionList[index].sale_Price}',
                                        style: TextStyle(fontSize: 10, color: (!hideinfo && departmentSectionList[index].audit_Action == 0)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 0)?Colors.grey[200]
                                            :(hideinfo && departmentSectionList[index].audit_Action == 1)?Colors.green[200]
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 1)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 2)?Colors.amber[200]
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 2)?Colors.black
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 3)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 3)?Colors.black
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 4)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 4)?Colors.red[200]
                                            :(!hideinfo && departmentSectionList[index].audit_Action == 5)?Colors.black
                                            :(hideinfo && departmentSectionList[index].audit_Action == 5)?Colors.purple[200]
                                            :Colors.grey[200], fontWeight: FontWeight.bold,),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,),]
                                    ),

                                      Column(
                                          children: [Text('${departmentSectionList[index].valuacion}',
                                            style: TextStyle(fontSize: 10, color: (!hideinfo && departmentSectionList[index].audit_Action == 0)?Colors.black
                                                :(hideinfo && departmentSectionList[index].audit_Action == 0)?Colors.grey[200]
                                                :(hideinfo && departmentSectionList[index].audit_Action == 1)?Colors.green[200]
                                                :(!hideinfo && departmentSectionList[index].audit_Action == 1)?Colors.black
                                                :(hideinfo && departmentSectionList[index].audit_Action == 2)?Colors.amber[200]
                                                :(!hideinfo && departmentSectionList[index].audit_Action == 2)?Colors.black
                                                :(!hideinfo && departmentSectionList[index].audit_Action == 3)?Colors.black
                                                :(hideinfo && departmentSectionList[index].audit_Action == 3)?Colors.black
                                                :(!hideinfo && departmentSectionList[index].audit_Action == 4)?Colors.black
                                                :(hideinfo && departmentSectionList[index].audit_Action == 4)?Colors.red[200]
                                                :(!hideinfo && departmentSectionList[index].audit_Action == 5)?Colors.black
                                                :(hideinfo && departmentSectionList[index].audit_Action == 5)?Colors.purple[200]
                                                :Colors.grey[200], fontWeight: FontWeight.bold,),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,),]
                                      ),
                                      Column(
                                          children: [Text('${departmentSectionList[index].code}',
                                            style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold,),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,),]
                                      ),
                                      Column(
                                          children: [Text('${departmentSectionList[index].tag}',
                                            style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold,),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,),]
                                      ),
                                      Column(
                                          children: [Text('${departmentSectionList[index].pzas.round()}',
                                            style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold,),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,),]
                                      ),

                                      Column(
                                        children: [Text('${departmentSectionList[index].audit_New_Quantity.round()} REC: ${departmentSectionList[index].rec}',
                                          style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold,),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,),]
                                    ),
                                    ]
                                ),
                                //subtitle: Text('UPC: ${departmentSectionList[index].code} MARB. ${departmentSectionList[index].tag} PZAS ${departmentSectionList[index].pzas} VALUACION ${departmentSectionList[index].valuacion} REC# ${departmentSectionList[index].rec})}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Visibility(
                                      visible: (departmentSectionList[index].audit_Action == 0 && departmentSectionList[index].rec == 0)?true:false,
                                      child:
                                      IconButton(
                                          iconSize: 40,
                                          onPressed: () {
                                          },
                                          icon:  Icon(
                                            Icons.edit,
                                            color: Colors.grey[200],
                                          )),
                                    ),
                                    Visibility(
                                      visible: (departmentSectionList[index].audit_Action == 0 && departmentSectionList[index].rec == 0)?true:false,
                                      child:
                                      IconButton(
                                          iconSize: 40,
                                          onPressed: () {
                                          },
                                          icon:  Icon(
                                            Icons.edit,
                                            color: Colors.grey[200],
                                          )),
                                    ),
                                    Visibility(
                                      visible: (departmentSectionList[index].audit_Action == 0 && departmentSectionList[index].rec > 0)?true:false,
                                      child:
                                      IconButton(
                                          iconSize: 40,
                                          onPressed: () {
                                            final route = MaterialPageRoute(builder: (context) =>
                                                DepartmentSectionEditScreen(jAuditSkuVariationDept: departmentSectionList[index]));
                                            Navigator.pushReplacement(context, route);
                                          },
                                          icon:  Icon(
                                            Icons.edit,
                                            color: Colors.orange[200],
                                          )),
                                    ),
                                    Visibility(
                                      visible: (departmentSectionList[index].audit_Action == 0 && departmentSectionList[index].rec > 0)?true:false,
                                      child:IconButton(
                                          iconSize: 40,
                                          onPressed: () {
                                            final route = MaterialPageRoute(builder: (context) =>
                                                DepartmentSectionDeleteScreen(
                                                    jAuditSkuVariationDept: departmentSectionList[index]));
                                            Navigator.pushReplacement(context, route);
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          )
                                      ),
                                    ),
                                    Visibility(
                                        visible: (departmentSectionList[index].audit_Action == 0 )?true:false,
                                        child:IconButton(
                                            iconSize: 40,
                                            onPressed: () async {
                                              departmentSectionList[index].audit_New_Quantity = 0.0;
                                              departmentSectionList[index].audit_Action = 1;
                                              departmentSectionList[index].audit_Status = 2;
                                              departmentSectionList[index].audit_Reason_Code = 0;
                                              var tipoerror = await sendOKJobDetail(departmentSectionList[index]);

                                              if (tipoerror == 0){
                                                departmentSectionList[index].sent = 1;
                                              }

                                              DBProvider.db.updateJobSkuVariationDeptAudit(departmentSectionList[index]);
                                              //print('ok');
                                            },
                                            icon: const Icon(
                                              Icons.check_circle_outline,
                                              color: Colors.green,
                                            ))
                                    ),
                                    Visibility(
                                      visible: (departmentSectionList[index].audit_Action > 0)?true:false,
                                      child: const Text('                                                 '),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                      ),
                    )
                  ],
                ),
                ),
                if ( isLoading )
                  Positioned(
                      bottom: 40,
                      left: size.width * 0.5 - 40,
                      child: const _LoadingIcon()
                  )
              ],
            ),
          )
        /* */

      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, size: 40,),
        onPressed: () {
          final route = MaterialPageRoute(
              builder: (context) => DepartmentSectionNewScreen());
              Navigator.pushReplacement(context, route);
        },
      ),
    );
  }

  Future<int> sendOKJobDetail(jobAuditSkuVariationDept jAuditSkuVariationDetailsRecord) async {

    //Enviar a la base de TOMI los registros con los cambios auditados

    List<jobAuditSkuVariationDept> jAuditSkuVariationDetails = [];
    var i = 0;
    var tipoerror = 0;
    var url = Uri.parse('${Preferences.servicesURL}/api/Audit/GetSkuVariationDetailsAuditAsync'); // IOS

    jAuditSkuVariationDetails.add(jAuditSkuVariationDetailsRecord);
    writeToLog('Count Records to send: ${jAuditSkuVariationDetails.length}');

    for (i = 0; i < jAuditSkuVariationDetails.length; i++) {
      jAuditSkuVariationDetails[i].audit_Status = (jAuditSkuVariationDetails[i].audit_Action == 1)?jAuditSkuVariationDetails[i].audit_Status = 4:jAuditSkuVariationDetails[i].audit_Status = 3;
      print(jAuditSkuVariationDetails[i].toJson());
      //writeToLog('record: i - Json: ${jAuditSkuVariationDetails[i].toJson().toString()}');
    }

    try {
      List jsonTags = jAuditSkuVariationDetails.map((jAuditSkuVariationDetails) => jAuditSkuVariationDetails.toJson()).toList();
      var params = {
        'customerId':g_customerId,
        'storeId': g_storeId,
        'stockDate' : g_stockDate.toString(),
        'departmentId' : g_departmentNumber,
        'sectionId': g_sectionNumber,
        'closeSection' : 0,
        'skuVariationAuditModel' : jAuditSkuVariationDetails
      };
      print(' url: ${url}');
      print(' params:${json.encode(params)}');
      print(' jAuditSkuVariationDetails:${json.encode(jAuditSkuVariationDetails)}');
      var response = await http.post(
          url,
          headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
          body: json.encode(params)
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        print(' data .${data}');
        if (!data["success"]){
          tipoerror = 2;
        }
      }
    } on SocketException catch (e) {
      //print(' Error en servicio .${e.toString()}');
      tipoerror = 1;
    }
    catch(e){
      //print(' jAuditSkuVariationDetails already exist in TOMI .${e.toString()}');
      writeToLog('SendJobDetail: ${e.toString()}');
      tipoerror = 2;
    }

    return tipoerror;
  }

  int countDepartmentspending(
      List<jobAuditSkuVariationDept> jobSkuVariation)  {
      var i = 0;
      var noprocesados = 0;

      for (i = 0; i < jobSkuVariation.length; i++) {
        if (jobSkuVariation[i].audit_Action == 0) {
          noprocesados += 1;
        }
      }

    return noprocesados;
  }

  Future<void> validaDepartments(
      List<jobAuditSkuVariationDept> jobSkuVariation) async {
    var i = 0;
    var noprocesados = 0;

    if (g_auditType == 1) {
      for (i = 0; i < jobSkuVariation.length; i++) {
        if (jobSkuVariation[i].audit_Action == 0) {
          noprocesados += 1;
        }
      }
    }
      print('valida departamento');
    if (noprocesados > 0) {
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

      var tipoerror = await sendJobDetail(jobSkuVariation);

      if (tipoerror == 0){
        final route = MaterialPageRoute(
            builder: (context) => const DepartmentSearchScreen());
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
                    Text('Department - Section was restarted by tomi admin.!!'),
                    SizedBox(height: 10),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        final route = MaterialPageRoute(
                            builder: (context) => const DepartmentSearchScreen());
                        Navigator.pushReplacement(context, route);
                      },
                      child: const Text('OK')),
                ],
              );
            });
      }
    }
  }

  Future<int> sendJobDetail(
      List<jobAuditSkuVariationDept> jAuditSkuVariationDetails) async {

    if( isLoading ) return -1;
    isLoading = true;
    setState(() {});
    await Future.delayed(const Duration(seconds: 1));

    //Enviar a la base de TOMI los registros con los cambios auditados
    var i = 0;
    var tipoerror = 0;
    var url = Uri.parse('${Preferences.servicesURL}/api/Audit/GetSkuVariationDetailsAuditAsync'); // IOS

    //writeToLog('Count Records to send: ${jAuditSkuVariationDetails.length}');
    //print('Count Records to send: ${jAuditSkuVariationDetails.length}');

    List<jobAuditSkuVariationDept> jAuditSkuVariationDetailsTmp = [];

    for (i = 0; i < jAuditSkuVariationDetails.length; i++) {
      jAuditSkuVariationDetails[i].audit_Status = (jAuditSkuVariationDetails[i].audit_Action == 1)?jAuditSkuVariationDetails[i].audit_Status = 4:jAuditSkuVariationDetails[i].audit_Status = 3;
      //print('rec: ${jAuditSkuVariationDetails[i].rec} sent : ${jAuditSkuVariationDetails[i].sent}');
      //print(jAuditSkuVariationDetails[i].toJson());
      //writeToLog('record: i - Json: ${jAuditSkuVariationDetails[i].toJson().toString()}');
      if (jAuditSkuVariationDetails[i].sent == 0)
        {
          jAuditSkuVariationDetailsTmp.add(jAuditSkuVariationDetails[i]);
        }
    }
    print('Count Records not sended: ${jAuditSkuVariationDetailsTmp.length}');
    try {
      List jsonTags = jAuditSkuVariationDetails.map((jAuditSkuVariationDetails) => jAuditSkuVariationDetails.toJson()).toList();
      var params = {
        'customerId':g_customerId,
        'storeId': g_storeId,
        'stockDate' : g_stockDate.toString(),
        'departmentId' : g_departmentNumber,
        'sectionId': g_sectionNumber,
        'closeSection' : 1,
        'skuVariationAuditModel' : jAuditSkuVariationDetailsTmp
      };
      // print(' url: ${url}');
      // print(' params:${json.encode(params)}');
      // print(' jAuditSkuVariationDetails:${json.encode(jAuditSkuVariationDetails)}');
      var response = await http.post(
          url,
          headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
          body: json.encode(params)
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        //print(' data .${data}');
        if (!data["success"]){
          tipoerror = 2;
        }
        else{
          for (i = 0; i < jAuditSkuVariationDetailsTmp.length; i++) {
            jAuditSkuVariationDetailsTmp[i].sent = 1;
            DBProvider.db.updateJobSkuVariationDeptAudit(jAuditSkuVariationDetailsTmp[i]);
          }
        }
      }
    } on SocketException catch (e) {
      //print(' Error en servicio .${e.toString()}');
      tipoerror = 1;
    }
    catch(e){
      //print(' jAuditSkuVariationDetails already exist in TOMI .${e.toString()}');
      writeToLog('SendJobDetail: ${e.toString()}');
      tipoerror = 2;
    }
    isLoading = false;
    setState(() {});

    return tipoerror;
  }
}

class _HeaderScreen extends StatelessWidget {
   _HeaderScreen({Key? key}) : super(key: key){}

   final List<String> headers = ['SKU', 'DESCRIPCIÓN', 'TEOR.', 'CONT.','DIF.','PRECIO', 'VAL.', 'UPC','TAG', 'PZAS', 'UP PZAS','Edit','Delete','Ok'];
   @override
  Widget build(BuildContext context) {
    return Container(
      child:
            Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (String header in headers)
                      Expanded(
                        child: Text(
                          header,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
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
            Text('Dept: ${g_departmentNumber}',
              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                    children:const [Text('SKU      ',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('   DESCRIPCION               ',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('  TEOR.',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('CONT.',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('   DIF.',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('    PRECIO',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('  VAL.',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('       UPC   ',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('       Tag',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('     PZAS',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),

                Column(
                    children:const [Text('UP PZAS',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('Edit',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('Delete',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),]
                ),
                Column(
                    children:const [Text('OK',
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


