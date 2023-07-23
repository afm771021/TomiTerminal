import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tomi_terminal_audit2/util/globalvariables.dart';
import 'package:flutter/material.dart';
import '../models/jobAuditSkuVariationDept_model.dart';
import '../providers/db_provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:device_info/device_info.dart';

import '../share_preferences/preferences.dart';

class DepartmentSectionNewScreen extends StatefulWidget {
  DepartmentSectionNewScreen({Key? key,}) : super(key: key);

  @override
  State<DepartmentSectionNewScreen> createState() => _DepartmentSectionNewScreenState();
}

class _DepartmentSectionNewScreenState extends State<DepartmentSectionNewScreen> {
  late bool existInMasterfile = false;
  late bool existDepartment = false;
  /*late JobDepartment dropdownValue;
   List<JobDepartment> departmentsItemList = [];*/

  /*void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }*/

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

  var jAuditSkuVariationDept = jobAuditSkuVariationDept(
      customer_Id: g_customerId.toDouble(),
      store_Id: g_storeId.toDouble(),
      stock_Date: g_stockDate,
      valdep: 0,
      department: '',
      department_Id: g_departmentNumber,
      section_Id: g_sectionNumber.toDouble(),
      sku: '',
      description: '',
      teorico: 0,
      contado: 0,
      dif: 0,
      sale_Price: 0 ,
      code: '',
      tag: '',
      pzas: 0,
      valuacion: 0,
      rec: 0,
      audit_User: g_user,
      audit_Status: 2,
      audit_New_Quantity: 0,
      audit_Action: 3,
      audit_Reason_Code: 0,
      sent: 0,
      captured_Date_Time: DateTime.now().toString(),
      terminal: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Record'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.backspace_outlined),
          onPressed: () => Navigator.pushReplacementNamed(context, 'DepartmentSectionListDetails'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AddForm(jAuditSkuVariationDept: jAuditSkuVariationDept ,),
            Visibility(
              visible: (existInMasterfile)?false:true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.home_filled),
                    labelText: 'Tag ',
                  ),
                  onChanged: (String? value){
                    jAuditSkuVariationDept.tag = value!;
                  },
                ),
              ),
            ),

            Visibility(
                visible: (existInMasterfile)?false:true,
                child: const SizedBox(height: 10,)
            ),
            Visibility(
              visible: (existInMasterfile)?false:true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.monetization_on_outlined),
                    labelText: 'Sale Price (>0)',
                  ),
                  onChanged: (String? value){
                    try{
                      jAuditSkuVariationDept.sale_Price = double.parse(value!) ;}
                    catch (e){ jAuditSkuVariationDept.sale_Price = 0;}
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save, size: 40,),
        onPressed: () async {
          if ((jAuditSkuVariationDept.code == null || jAuditSkuVariationDept.code.isEmpty ||
              //jAuditSkuVariationDept.sku == null || jAuditSkuVariationDept.sku.isEmpty ||
              jAuditSkuVariationDept.tag == null || jAuditSkuVariationDept.tag.isEmpty ||
              jAuditSkuVariationDept.pzas== null || jAuditSkuVariationDept.pzas <= 0 ||
              jAuditSkuVariationDept.sale_Price == null || jAuditSkuVariationDept.sale_Price < 0 ||
              jAuditSkuVariationDept.audit_Reason_Code == null || jAuditSkuVariationDept.audit_Reason_Code <=0)
             ){
            /*print ('department_Id: ${jdetailaudit.department_Id}');
                print ('sale_Price ${jdetailaudit.sale_Price}');
                print ('description ${jdetailaudit.description}');
                print ('department ${jdetailaudit.department_Id}');*/
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
                        Text('All fields are necessary !!'),
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
          }
          else {
            //writeToLog('Add Record Code: ${jAuditSkuVariationDept.code} Add Record pzas: ${jAuditSkuVariationDept.pzas}');
            try
            {
              DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
              AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
              jAuditSkuVariationDept.terminal = androidInfo.model.substring(0,10);
            }
            catch (e) {
              jAuditSkuVariationDept.terminal = 'NoNameDev';
            }
            //var tipoerror = await sendAddJobDetail(jAuditSkuVariationDept);

            DBProvider.db.nuevoJobAuditSkuVariationDept(jAuditSkuVariationDept);
            Navigator.pushReplacementNamed(context, 'DepartmentSectionListDetails');
            //print(jAuditSkuVariationDept);
          }
        },
      ),
    );
  }

  Future<int> sendAddJobDetail(jobAuditSkuVariationDept jAuditSkuVariationDetailsRecord) async {

    //Enviar a la base de TOMI los registros con los cambios auditados

    List<jobAuditSkuVariationDept> jAuditSkuVariationDetails = [];
    var i = 0;
    var tipoerror = 0;
    var url = Uri.parse('${Preferences.servicesURL}/api/Audit/GetSkuVariationDetailsAuditAsync'); // IOS

    final auditorSkuVariationDept = await DBProvider.db.getAuditorSkuVariationDeptAuditedandPendingtosend();
    jAuditSkuVariationDetails = [...?auditorSkuVariationDept];

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
        else {
          for (i = 0; i < jAuditSkuVariationDetails.length; i++) {
            jAuditSkuVariationDetails[i].sent = 1;
            DBProvider.db.updateJobSkuVariationDeptAudit(
                jAuditSkuVariationDetails[i]);
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

    return tipoerror;
  }
}

class AddForm extends StatelessWidget {
  const AddForm({
    Key? key, required this.jAuditSkuVariationDept,
  }) : super(key: key);

  final jobAuditSkuVariationDept jAuditSkuVariationDept;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        //width: double.infinity,
        // height: 200,
          decoration: _buildBoxDecoration(),
          child: Form(
            child: Column(
              children: [
                /*const SizedBox(height: 10,),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.qr_code),
                    labelText: 'SKU',
                  ),
                  onChanged: (String? value){
                    jAuditSkuVariationDept.sku = value!;
                  },
                ),*/
                const SizedBox(height: 10,),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.qr_code),
                    labelText: 'UPC',
                  ),
                  onChanged: (String? value){
                    jAuditSkuVariationDept.code = value!;
                  },
                ),
                const SizedBox(height: 10,),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.production_quantity_limits),
                    //hintText: 'What do people call you?',
                    labelText: 'Quantity ',
                  ),
                  onChanged: (String? value){
                    try{
                      jAuditSkuVariationDept.pzas = int.parse(value!) * 1.0;
                      jAuditSkuVariationDept.audit_New_Quantity = int.parse(value!) * 1.0;
                    }
                    catch (e){ jAuditSkuVariationDept.pzas = 0; }
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),
                // const SizedBox(height: 10,),
                // TextFormField(
                //   decoration: const InputDecoration(
                //     icon: Icon(Icons.store),
                //     labelText: 'Shelf ',
                //   ),
                //   onChanged: (String? value){
                //     //jdetailaudit.shelf = value!;
                //   },
                // ),
                const SizedBox(height: 10,),
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.swipe_up),
                    labelText: 'Reason Change',
                  ),

                  items: <String>['Error preparación tienda',
                    'Error conteo proveedor'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        //style: TextStyle(fontSize: 20),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value == 'Error preparación tienda'){
                      jAuditSkuVariationDept.audit_Reason_Code = 1.0;
                    }
                    else if (value == 'Error conteo proveedor'){
                      jAuditSkuVariationDept.audit_Reason_Code = 2.0;
                    }

                    /*if (value == 'Preconteo Tienda erróneo.'){
                      jAuditSkuVariationDept.audit_Reason_Code = 1.0;
                    }
                    else if (value == 'Conteo Inicial Accurats erróneo'){
                      jAuditSkuVariationDept.audit_Reason_Code = 2.0;
                    }
                    else if (value == 'Sku no corresponde.'){
                      jAuditSkuVariationDept.audit_Reason_Code = 3.0;
                    }
                    else if (value == 'Caja en altillo sin SKU (QR)'){
                      jAuditSkuVariationDept.audit_Reason_Code = 4.0;
                    }
                    else if (value == 'Caja en Altillos sin cantidad o cantidad errónea.'){
                      jAuditSkuVariationDept.audit_Reason_Code = 5.0;
                    }
                    else if (value == 'Cantidad no corresponde.'){
                      jAuditSkuVariationDept.audit_Reason_Code = 6.0;
                    }
                    else if (value == 'SKU no existe, se cambió por similar.'){
                      jAuditSkuVariationDept.audit_Reason_Code = 7.0;
                    }
                    else if (value == 'Error en Unidad de medida.'){
                      jAuditSkuVariationDept.audit_Reason_Code = 8.0;
                    }
                    else if (value == 'corrección por Tablet, errónea en cantidad'){
                      jAuditSkuVariationDept.audit_Reason_Code = 9.0;
                    }
                    else if (value == 'corrección por Tablet, errónea en Sku.'){
                      jAuditSkuVariationDept.audit_Reason_Code = 10.0;
                    }*/
                  },
                )
              ],
            ),
          )
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => const BoxDecoration(
    color:Colors.white,
    borderRadius: BorderRadius.only(bottomRight: Radius.circular(25),
        bottomLeft: Radius.circular(25)),
  );
}
